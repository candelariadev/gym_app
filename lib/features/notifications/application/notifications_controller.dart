import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:gymsas_notifications/gymsas_notifications.dart';

class NotificationsController extends ChangeNotifier
    with WidgetsBindingObserver {
  NotificationsController({
    required this.repository,
    required this.account,
    this.push,
  });
  final NotificationsRepository repository;
  final NotificationAccount? Function() account;
  final PushDevice? push;
  List<RoutineNotification> entries = const [];
  NotificationQuota? quota;
  NotificationErrorCode? error, pushError;
  PushPermission permission = PushPermission.notDetermined;
  bool quotaFresh = false,
      loadingQuota = false,
      pushEnabled = false,
      pushRegistered = false,
      registering = false;
  bool deviceRemovalPending = false;
  final Set<String> busy = <String>{};
  PushRoutineReference? foregroundReference, _pendingOpen;
  StreamSubscription<void>? _changes;
  StreamSubscription<String>? _tokens;
  StreamSubscription<PushRoutineReference>? _opens, _foreground;
  Timer? _timer;
  DateTime? _quotaAt;
  int _epoch = 0;
  bool _disposed = false,
      _started = false,
      _cleaningUp = false,
      _localLoading = false,
      _localAgain = false;
  String? _boundToken, _boundScope, _activeScope;
  bool get supported => push?.supported == true;
  bool get isTrainer => account()?.isTrainer == true;
  bool _current(String scope, int epoch) =>
      !_disposed && epoch == _epoch && account()?.scope == scope;
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  RoutineNotification? entry(String key) {
    for (final n in entries) {
      if (n.target.key == key) return n;
    }
    return null;
  }

  void start() {
    if (_started || _disposed) return;
    _started = true;
    WidgetsBinding.instance.addObserver(this);
    _changes = repository.changes.listen((_) => unawaited(reloadLocal()));
    _tokens = push?.tokenChanges.listen(
      (value) => unawaited(_register(tokenValue: value)),
    );
    _opens = push?.opened.listen((r) {
      _pendingOpen = r;
      _notify();
    });
    _foreground = push?.foreground.listen((r) {
      if (account()?.scope == _boundScope &&
          pushEnabled &&
          permission == PushPermission.allowed) {
        foregroundReference = r;
        _notify();
      }
    });
    unawaited(() async {
      try {
        final r = await push?.initialMessage();
        if (!_disposed && r != null) {
          _pendingOpen = r;
          _notify();
        }
      } on Object {
        // Un fallo push no bloquea el arranque ni la sesión offline.
      }
    }());
    _startTimer();
    unawaited(_tick());
  }

  void _startTimer() {
    _timer ??= Timer.periodic(
      const Duration(seconds: 15),
      (_) => unawaited(_tick()),
    );
  }

  void accountChanged() {
    final scope = account()?.scope;
    if (_activeScope != null && scope != _activeScope) _pendingOpen = null;
    _activeScope = scope;
    _epoch++;
    entries = const [];
    quota = null;
    quotaFresh = false;
    loadingQuota = false;
    busy.clear();
    error = null;
    pushError = null;
    pushEnabled = false;
    pushRegistered = false;
    deviceRemovalPending = false;
    _cleaningUp = false;
    registering = false;
    _boundToken = null;
    _boundScope = null;
    foregroundReference = null;
    _quotaAt = null;
    _notify();
    unawaited(() async {
      await reloadLocal();
      await _tick();
    }());
  }

  Future<void> reloadLocal() async {
    if (_disposed) return;
    if (_localLoading) {
      _localAgain = true;
      return;
    }
    _localLoading = true;
    try {
      do {
        _localAgain = false;
        final a = account(), epoch = _epoch;
        if (a == null) {
          entries = const [];
          quota = null;
          pushEnabled = false;
          break;
        }
        try {
          final rows = await repository.history();
          final cached = await repository.cachedQuota();
          final enabled = await repository.pushEnabled();
          final removal = await repository.deviceRemovalPending();
          if (!_current(a.scope, epoch)) continue;
          final changed = rows.any((next) {
            final previous = entry(next.target.key);
            return previous == null ||
                previous.state != next.state ||
                previous.serverId != next.serverId ||
                previous.error != next.error ||
                previous.retryBaseUpdatedAt != next.retryBaseUpdatedAt;
          });
          if (changed) {
            quotaFresh = false;
            _quotaAt = null;
          }
          entries = rows;
          quota = cached;
          pushEnabled = enabled;
          deviceRemovalPending = removal;
          error = null;
        } on NotificationException catch (e) {
          if (_current(a.scope, epoch)) error = e.code;
        }
      } while (_localAgain && !_disposed);
    } finally {
      _localLoading = false;
      _notify();
    }
  }

  Future<void> _tick() async {
    final a = account();
    if (a == null || _disposed) return;
    final epoch = _epoch;
    try {
      try {
        await repository.flushDeviceRemoval();
      } on NotificationException catch (e) {
        if (_current(a.scope, epoch)) pushError = e.code;
      }
      await repository.synchronize();
      if (!_current(a.scope, epoch)) return;
      await reloadLocal();
      if (a.isTrainer &&
          a.canRequest &&
          (_quotaAt == null ||
              DateTime.now().difference(_quotaAt!) >
                  const Duration(minutes: 1))) {
        await refreshQuota();
      }
      if (_current(a.scope, epoch) && pushEnabled) await _register();
    } on NotificationException catch (e) {
      if (_current(a.scope, epoch)) {
        error = e.code;
        _notify();
      }
    } on Object {
      if (_current(a.scope, epoch)) {
        error = NotificationErrorCode.unavailable;
        _notify();
      }
    }
  }

  Future<void> refreshQuota() async {
    if (loadingQuota || account()?.isTrainer != true) return;
    final a = account()!, epoch = _epoch;
    loadingQuota = true;
    _quotaAt = DateTime.now();
    _notify();
    try {
      final value = await repository.refreshQuota();
      if (_current(a.scope, epoch)) {
        quota = value;
        quotaFresh = true;
        error = null;
      }
    } on NotificationException catch (e) {
      if (_current(a.scope, epoch)) {
        quotaFresh = false;
        error = e.code;
      }
    } on Object {
      if (_current(a.scope, epoch)) {
        quotaFresh = false;
        error = NotificationErrorCode.unavailable;
      }
    } finally {
      if (_current(a.scope, epoch)) {
        loadingQuota = false;
        _notify();
      }
    }
  }

  Future<void> refresh() async {
    await _tick();
    if (!_disposed && account()?.isTrainer == true) await refreshQuota();
  }

  Future<void> confirm(ConfirmedRoutineTarget target, String language) {
    final scope = account()?.scope, epoch = _epoch;
    return _action(target.key, () async {
      await repository.rememberConfirmed(target);
      if (scope == null || !_current(scope, epoch)) return;
      await repository.confirm(target.key, language);
    });
  }

  Future<void> retry(
    RoutineNotification n, {
    bool acknowledgeDuplicateRisk = false,
  }) => _action(
    n.target.key,
    () => repository.retry(
      n.target.key,
      acknowledgeDuplicateRisk: acknowledgeDuplicateRisk,
    ),
  );
  Future<void> _action(String key, Future<void> Function() action) async {
    if (busy.contains(key) || account() == null) return;
    final a = account()!, epoch = _epoch;
    busy.add(key);
    error = null;
    _notify();
    try {
      await action();
      if (_current(a.scope, epoch)) {
        quotaFresh = false;
        await reloadLocal();
        // Consultar la cuota después del ACK, no en paralelo con la reserva.
        await repository.synchronize();
        if (!_current(a.scope, epoch)) return;
        await reloadLocal();
        await refreshQuota();
      }
    } on NotificationException catch (e) {
      if (_current(a.scope, epoch)) error = e.code;
    } on Object {
      if (_current(a.scope, epoch)) error = NotificationErrorCode.unavailable;
    } finally {
      if (_current(a.scope, epoch)) {
        busy.remove(key);
        _notify();
      }
    }
  }

  Future<void> enablePush() async {
    if (!supported || registering || _cleaningUp || account() == null) return;
    final a = account()!, epoch = _epoch;
    registering = true;
    pushError = null;
    _notify();
    try {
      final p = await push!.requestPermission();
      if (!_current(a.scope, epoch)) return;
      permission = p;
      await repository.setPushEnabled(p == PushPermission.allowed);
      if (!_current(a.scope, epoch)) return;
      pushEnabled = p == PushPermission.allowed;
    } on Object {
      if (_current(a.scope, epoch)) {
        pushError = NotificationErrorCode.unavailable;
      }
    } finally {
      if (_current(a.scope, epoch)) {
        registering = false;
        _notify();
      }
    }
    if (_current(a.scope, epoch) && pushEnabled) await _register();
  }

  Future<void> _register({String? tokenValue}) async {
    if (!supported ||
        registering ||
        _cleaningUp ||
        !pushEnabled ||
        account()?.canRequest != true) {
      return;
    }
    final a = account()!, epoch = _epoch;
    registering = true;
    _notify();
    try {
      await repository.flushDeviceRemoval();
      if (!_current(a.scope, epoch)) return;
      final p = await push!.permission();
      if (!_current(a.scope, epoch)) return;
      permission = p;
      if (p != PushPermission.allowed) return;
      final token = tokenValue ?? await push!.token();
      if (!_current(a.scope, epoch)) return;
      if (token == null) {
        pushRegistered = false;
        return;
      }
      if (_boundScope == a.scope && _boundToken == token) return;
      final id = await repository.installationId();
      if (!_current(a.scope, epoch)) return;
      await repository.registerDevice(id, token, expectedScope: a.scope);
      if (!_current(a.scope, epoch)) return;
      _boundScope = a.scope;
      _boundToken = token;
      pushRegistered = true;
      pushError = null;
    } on NotificationException catch (e) {
      if (_current(a.scope, epoch)) {
        pushError = e.code;
        pushRegistered = false;
      }
    } on Object {
      if (_current(a.scope, epoch)) {
        pushError = NotificationErrorCode.unavailable;
        pushRegistered = false;
      }
    } finally {
      if (_current(a.scope, epoch)) {
        registering = false;
        _notify();
      }
    }
  }

  Future<void> disablePush() => _cleanup(disablePreference: true);
  Future<void> beforeLogout() => _cleanup(disablePreference: false);
  Future<void> _cleanup({required bool disablePreference}) async {
    final a = account();
    if (a == null || _cleaningUp) return;
    final needsCleanup = pushEnabled || pushRegistered || deviceRemovalPending;
    if (!needsCleanup) return;
    _cleaningUp = true;
    _epoch++;
    final epoch = _epoch;
    foregroundReference = null;
    _pendingOpen = null;
    _boundScope = null;
    _boundToken = null;
    pushRegistered = false;
    registering = false;
    _notify();
    try {
      if (disablePreference) {
        await repository.setPushEnabled(false);
        if (_current(a.scope, epoch)) pushEnabled = false;
      }
      await repository.deferDeviceRemoval();
      if (_current(a.scope, epoch)) deviceRemovalPending = true;
      if (_current(a.scope, epoch)) {
        await repository.flushDeviceRemoval().timeout(
          const Duration(seconds: 3),
        );
        if (_current(a.scope, epoch)) {
          deviceRemovalPending = await repository.deviceRemovalPending();
        }
      }
    } on Object {
      if (_current(a.scope, epoch)) pushError = NotificationErrorCode.network;
    } finally {
      if (_current(a.scope, epoch)) {
        try {
          await push?.deleteToken().timeout(const Duration(seconds: 3));
        } on Object {
          // La revinculación posterior protege el cambio de cuenta si no hay red.
        }
        if (disablePreference) _cleaningUp = false;
        _notify();
      }
    }
  }

  PushRoutineReference? takeOpen() {
    if (account() == null) return null;
    final ref = _pendingOpen;
    _pendingOpen = null;
    return isTrainer ? null : ref;
  }

  void openForeground() {
    _pendingOpen = foregroundReference;
    foregroundReference = null;
    _notify();
  }

  void dismissForeground() {
    foregroundReference = null;
    _notify();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startTimer();
      quotaFresh = false;
      unawaited(_tick());
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _timer?.cancel();
      _timer = null;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _epoch++;
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_changes?.cancel());
    unawaited(_tokens?.cancel());
    unawaited(_opens?.cancel());
    unawaited(_foreground?.cancel());
    super.dispose();
  }
}
