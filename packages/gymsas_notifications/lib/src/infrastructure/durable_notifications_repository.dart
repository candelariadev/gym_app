import 'dart:async';
import 'dart:math';
import 'package:gymsas_offline/gymsas_offline.dart';
import '../domain/notification_models.dart';
import '../domain/notification_repository.dart';
import 'notification_codec.dart';
import 'graphql_notification_remote.dart';

class DurableNotificationsRepository implements NotificationsRepository {
  DurableNotificationsRepository({
    required this.store,
    required this.remote,
    required this.account,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;
  final OfflineDocumentStore store;
  final NotificationRemote remote;
  final NotificationAccount? Function() account;
  final DateTime Function() _now;
  final _events = StreamController<void>.broadcast(sync: true);
  Future<void>? _flight;
  Future<void>? _removalFlight;
  int? _flightEpoch;
  int _epoch = 0, _failures = 0, _watchCursor = 0;
  bool _disposed = false, _authBlocked = false;
  DateTime? _nextAttempt;
  @override
  Stream<void> get changes => _events.stream;
  void accountChanged() {
    _epoch++;
    _failures = 0;
    _nextAttempt = null;
    _authBlocked = false;
    _watchCursor = 0;
    if (!_disposed) _events.add(null);
  }

  void dispose() {
    _disposed = true;
    _epoch++;
    unawaited(_events.close());
  }

  NotificationAccount _session() =>
      account() ??
      (throw const NotificationException(NotificationErrorCode.unauthorized));
  void _check(String scope, int epoch) {
    if (_disposed || _epoch != epoch || account()?.scope != scope) {
      throw const NotificationException(NotificationErrorCode.unauthorized);
    }
  }

  String _key() {
    final r = Random.secure();
    return List.generate(
      16,
      (_) => r.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
  }

  Map<String, dynamic> _section(Map<String, dynamic> d) {
    final raw = d['notifications'];
    if (raw == null) return {'version': 1, 'records': <String, dynamic>{}};
    final section = Map<String, dynamic>.from(raw as Map);
    if (section['version'] != 1 || section['records'] is! Map) {
      throw const FormatException(
        'Unsupported notifications schema; preserve data',
      );
    }
    return section;
  }

  Map<String, dynamic> _records(Map<String, dynamic> section) =>
      Map<String, dynamic>.from(section['records'] as Map);
  Future<Map<String, dynamic>> _read(NotificationAccount a, int epoch) async {
    try {
      final d = await store.read(a.scope);
      _check(a.scope, epoch);
      return _section(d);
    } on NotificationException {
      rethrow;
    } on Object {
      throw const NotificationException(NotificationErrorCode.storage);
    }
  }

  Future<void> _write(
    String scope,
    int epoch,
    void Function(Map<String, dynamic>) update,
  ) async {
    try {
      await store.update(scope, (d) {
        _check(scope, epoch);
        final s = _section(d);
        update(s);
        d['notifications'] = s;
      });
      _check(scope, epoch);
      _events.add(null);
    } on NotificationException {
      rethrow;
    } on Object {
      throw const NotificationException(NotificationErrorCode.storage);
    }
  }

  Future<void> _patch(
    String scope,
    int epoch,
    String key,
    void Function(Map<String, dynamic>) update,
  ) => _write(scope, epoch, (s) {
    final rows = _records(s);
    if (!rows.containsKey(key)) {
      throw const NotificationException(NotificationErrorCode.conflict);
    }
    final row = Map<String, dynamic>.from(rows[key] as Map);
    update(row);
    rows[key] = row;
    s['records'] = rows;
  });
  @override
  Future<List<RoutineNotification>> history() async {
    final a = account();
    if (a == null) return [];
    final s = await _read(a, _epoch);
    try {
      return _records(s).values
          .map(
            (v) => NotificationCodec.read(Map<String, dynamic>.from(v as Map)),
          )
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } on Object {
      throw const NotificationException(NotificationErrorCode.storage);
    }
  }

  @override
  Future<void> rememberConfirmed(ConfirmedRoutineTarget target) async {
    final a = _session(), epoch = _epoch;
    if (!a.isTrainer || !target.isValid) {
      throw const NotificationException(NotificationErrorCode.invalidInput);
    }
    await _write(a.scope, epoch, (s) {
      final rows = _records(s);
      if (rows.containsKey(target.key)) return;
      if (rows.length >= 200) {
        final removable =
            rows.entries.where((e) {
              final n = NotificationCodec.read(
                Map<String, dynamic>.from(e.value as Map),
              );
              return (n.isTerminal && n.retryBaseUpdatedAt == null) ||
                  n.confirmedAt == null;
            }).toList()..sort(
              (a, b) => (a.value['createdAt'] as String).compareTo(
                b.value['createdAt'] as String,
              ),
            );
        if (removable.isEmpty) {
          throw const NotificationException(NotificationErrorCode.storage);
        }
        rows.remove(removable.first.key);
      }
      rows[target.key] = NotificationCodec.write(
        RoutineNotification(
          target: target,
          idempotencyKey: _key(),
          state: NotificationDeliveryState.ready,
          language: 'es',
          createdAt: _now().toUtc(),
        ),
      );
      s['records'] = rows;
    });
  }

  @override
  Future<void> confirm(String targetKey, String language) async {
    final a = _session(), epoch = _epoch;
    if (!a.isTrainer || !{'es', 'en'}.contains(language)) {
      throw const NotificationException(NotificationErrorCode.invalidInput);
    }
    await _patch(a.scope, epoch, targetKey, (row) {
      if (row['confirmedAt'] != null) return;
      row['confirmedAt'] = _now().toUtc().toIso8601String();
      row['language'] = language;
      row['state'] = NotificationDeliveryState.queued.name;
      row['error'] = null;
    });
    _nextAttempt = null;
    _kick();
  }

  @override
  Future<void> retry(
    String key, {
    bool acknowledgeDuplicateRisk = false,
  }) async {
    final a = _session(), epoch = _epoch;
    await _patch(a.scope, epoch, key, (row) {
      final n = NotificationCodec.read(row);
      if (n.confirmedAt == null) {
        throw const NotificationException(NotificationErrorCode.invalidInput);
      }
      if (n.serverId != null) {
        if (n.state != NotificationDeliveryState.definitivelyFailed &&
            n.state != NotificationDeliveryState.uncertain) {
          return;
        }
        if (n.state == NotificationDeliveryState.uncertain &&
            !acknowledgeDuplicateRisk) {
          throw const NotificationException(NotificationErrorCode.conflict);
        }
        row['retryBaseUpdatedAt'] = n.serverUpdatedAt;
        row['retryRisk'] = acknowledgeDuplicateRisk;
      }
      row['error'] = null;
    });
    _authBlocked = false;
    _nextAttempt = null;
    _kick();
  }

  void _kick() {
    unawaited(synchronize().catchError((Object _) {}));
  }

  @override
  Future<NotificationQuota?> cachedQuota() async {
    final a = account();
    if (a == null) return null;
    final s = await _read(a, _epoch);
    try {
      return s['quota'] == null
          ? null
          : NotificationCodec.readQuota(
              Map<String, dynamic>.from(s['quota'] as Map),
            );
    } on Object {
      throw const NotificationException(NotificationErrorCode.storage);
    }
  }

  NotificationAccount _online() {
    final a = _session();
    if (!a.canRequest) {
      throw const NotificationException(NotificationErrorCode.unauthorized);
    }
    return a;
  }

  @override
  Future<NotificationQuota> refreshQuota() async {
    final a = _online(), epoch = _epoch;
    if (!a.isTrainer) {
      throw const NotificationException(NotificationErrorCode.forbidden);
    }
    final q = await remote.quota(a.accessToken);
    _check(a.scope, epoch);
    await _write(
      a.scope,
      epoch,
      (s) => s['quota'] = NotificationCodec.writeQuota(q),
    );
    return q;
  }

  @override
  Future<void> synchronize() {
    final epoch = _epoch, existing = _flight;
    if (existing != null) {
      if (_flightEpoch == epoch) return existing;
      return existing
          .then<void>((_) {}, onError: (Object _, StackTrace _) {})
          .then((_) async {
            if (_epoch == epoch && !_disposed) await synchronize();
          });
    }
    final a = account();
    // Una comprobación sin sesión/red no debe ocupar un vuelo de sincronización.
    if (a == null || !a.canRequest || !a.isTrainer || _disposed) {
      return Future.value();
    }
    _flightEpoch = epoch;
    late final Future<void> operation;
    operation = _synchronize().whenComplete(() {
      if (identical(_flight, operation)) _flight = null;
    });
    _flight = operation;
    return operation;
  }

  bool _blocked(NotificationErrorCode? error) =>
      error != null &&
      !{
        NotificationErrorCode.network,
        NotificationErrorCode.unavailable,
        NotificationErrorCode.unauthorized,
      }.contains(error);
  Future<void> _apply(
    String scope,
    int epoch,
    String key,
    RemoteNotification result,
  ) => _patch(scope, epoch, key, (row) {
    final old = row['serverId'];
    if (old != null && old != result.id) {
      throw const NotificationException(NotificationErrorCode.invalidResponse);
    }
    row['serverId'] = result.id;
    row['serverUpdatedAt'] = result.updatedAt;
    row['state'] = result.state.name;
    row['providerAccepted'] = result.providerAccepted;
    row['failureCode'] = result.failureCode;
    row['error'] = null;
    row['retryBaseUpdatedAt'] = null;
    row['retryRisk'] = false;
  });
  Future<void> _synchronize() async {
    final a = account();
    if (a == null ||
        !a.canRequest ||
        !a.isTrainer ||
        _disposed ||
        _authBlocked ||
        (_nextAttempt != null && _now().isBefore(_nextAttempt!))) {
      return;
    }
    final epoch = _epoch, s = await _read(a, _epoch);
    late final List<RoutineNotification> all;
    try {
      all =
          _records(s).values
              .map(
                (v) =>
                    NotificationCodec.read(Map<String, dynamic>.from(v as Map)),
              )
              .toList()
            ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } on Object {
      throw const NotificationException(NotificationErrorCode.storage);
    }
    final commands = all
        .where(
          (n) =>
              n.confirmedAt != null &&
              !_blocked(n.error) &&
              (n.serverId == null || n.retryBaseUpdatedAt != null),
        )
        .take(5)
        .toList();
    final watches = all
        .where(
          (n) =>
              n.isWatching &&
              n.retryBaseUpdatedAt == null &&
              !_blocked(n.error),
        )
        .toList();
    final batch = [...commands];
    if (watches.isNotEmpty) {
      for (var i = 0; i < min(5, watches.length); i++) {
        batch.add(watches[(_watchCursor + i) % watches.length]);
      }
      _watchCursor = (_watchCursor + 5) % watches.length;
    }
    for (final n in batch) {
      _check(a.scope, epoch);
      try {
        RemoteNotification result;
        if (n.serverId == null) {
          result = await remote.notify(
            n.target,
            n.language,
            n.idempotencyKey,
            a.accessToken,
          );
        } else if (n.retryBaseUpdatedAt != null) {
          final current = await remote.status(n.serverId!, a.accessToken);
          _check(a.scope, epoch);
          if (current.updatedAt != n.retryBaseUpdatedAt ||
              !{
                NotificationDeliveryState.definitivelyFailed,
                NotificationDeliveryState.uncertain,
              }.contains(current.state)) {
            result = current;
          } else {
            final rows = _records(s);
            final risk = (rows[n.target.key] as Map)['retryRisk'] == true;
            result = await remote.retry(n.serverId!, risk, a.accessToken);
          }
        } else {
          result = await remote.status(n.serverId!, a.accessToken);
        }
        _check(a.scope, epoch);
        await _apply(a.scope, epoch, n.target.key, result);
      } on Object catch (e) {
        _check(a.scope, epoch);
        final error = mapNotificationError(e);
        await _patch(
          a.scope,
          epoch,
          n.target.key,
          (row) => row['error'] = error.code.name,
        );
        if (error.code == NotificationErrorCode.unauthorized) {
          _authBlocked = true;
          return;
        }
        if (error.code == NotificationErrorCode.network ||
            error.code == NotificationErrorCode.unavailable) {
          _failures++;
          final delay = min(300, 15 * (1 << min(_failures - 1, 5)));
          _nextAttempt = _now().add(
            Duration(seconds: delay + Random.secure().nextInt(5)),
          );
          return;
        }
      }
    }
    _failures = 0;
    _nextAttempt = null;
  }

  @override
  Future<void> setPushEnabled(bool value) async {
    final a = _session(), epoch = _epoch;
    await _write(a.scope, epoch, (s) => s['pushEnabled'] = value);
  }

  @override
  Future<bool> pushEnabled() async {
    final a = account();
    if (a == null) return false;
    return (await _read(a, _epoch))['pushEnabled'] == true;
  }

  @override
  Future<void> deferDeviceRemoval() async {
    final a = _session(), epoch = _epoch;
    await _write(a.scope, epoch, (s) => s['deviceRemovalPending'] = true);
  }

  @override
  Future<bool> deviceRemovalPending() async {
    final a = account();
    if (a == null) return false;
    return (await _read(a, _epoch))['deviceRemovalPending'] == true;
  }

  @override
  Future<void> flushDeviceRemoval() {
    if (_removalFlight != null) return _removalFlight!;
    late final Future<void> operation;
    operation = _flushRemoval().whenComplete(() {
      if (identical(_removalFlight, operation)) _removalFlight = null;
    });
    _removalFlight = operation;
    return operation;
  }

  Future<void> _flushRemoval() async {
    final a = account();
    if (a == null || !a.canRequest) return;
    final epoch = _epoch;
    final s = await _read(a, epoch);
    if (s['deviceRemovalPending'] != true) return;
    final id = await installationId();
    _check(a.scope, epoch);
    await remote.unregisterDevice(id, a.accessToken);
    _check(a.scope, epoch);
    await _write(a.scope, epoch, (s) => s['deviceRemovalPending'] = false);
  }

  @override
  Future<String> installationId() async {
    try {
      return await store.update('__gymsas_push_installation_v1', (d) {
        d['id'] ??= _key();
        return d['id'] as String;
      });
    } on Object {
      throw const NotificationException(NotificationErrorCode.storage);
    }
  }

  @override
  Future<void> registerDevice(
    String id,
    String token, {
    required String expectedScope,
  }) async {
    final a = _online(), epoch = _epoch;
    _check(expectedScope, epoch);
    await remote.registerDevice(id, token, a.accessToken);
    _check(a.scope, epoch);
  }

  @override
  Future<void> unregisterDevice(
    String id, {
    required String expectedScope,
  }) async {
    final a = _online(), epoch = _epoch;
    _check(expectedScope, epoch);
    await remote.unregisterDevice(id, a.accessToken);
    _check(a.scope, epoch);
  }
}
