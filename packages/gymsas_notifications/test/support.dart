import 'package:gymsas_notifications/gymsas_notifications.dart';
import 'package:gymsas_offline/gymsas_offline.dart';
import 'package:gymsas_notifications/src/infrastructure/durable_notifications_repository.dart';

class MemoryValues implements OfflineValueStorage {
  final values = <String, String>{};
  bool failWrites = false;
  @override
  Future<String?> read(String key) async => values[key];
  @override
  Future<void> write(String key, String value) async {
    if (failWrites) throw StateError('disk full');
    values[key] = value;
  }
}

const target = ConfirmedRoutineTarget(
  routineId: 'routine-one',
  clientId: 'client-id',
  clientName: 'Private client name',
  routineName: 'Strength',
);
NotificationAccount session({
  String scope = 'backend/tenant/user',
  bool online = true,
  bool trainer = true,
}) => NotificationAccount(
  scope: scope,
  accessToken: 'test-only-session-not-to-store',
  canRequest: online,
  isTrainer: trainer,
);

class FakeRemote implements NotificationRemote {
  int notifyCalls = 0,
      retryCalls = 0,
      statusCalls = 0,
      quotaCalls = 0,
      registrations = 0,
      removals = 0;
  bool loseNotify = false, loseRetry = false;
  int quotaRemaining = 1;
  NotificationErrorCode? fail;
  NotificationDeliveryState initialState = NotificationDeliveryState.pending;
  final logical = <String, RemoteNotification>{};
  final keys = <String>[], tokens = <String>[];
  Future<RemoteNotification> Function(RemoteNotification)? gate;
  void Function()? afterNotify;
  RemoteNotification get current => logical.values.last;
  void replace(RemoteNotification n) {
    final key = logical.keys.firstWhere((k) => logical[k]!.id == n.id);
    logical[key] = n;
  }

  @override
  Future<RemoteNotification> notify(
    ConfirmedRoutineTarget target,
    String language,
    String key,
    String token,
  ) async {
    notifyCalls++;
    keys.add(key);
    tokens.add(token);
    if (fail != null) throw NotificationException(fail!);
    final result = logical.putIfAbsent(
      key,
      () => RemoteNotification(
        id: 'notification-${logical.length}',
        state: initialState,
        updatedAt: '2026-10-20T12:00:00.000Z',
        providerAccepted: false,
      ),
    );
    afterNotify?.call();
    if (loseNotify) {
      loseNotify = false;
      throw const NotificationException(NotificationErrorCode.network);
    }
    return gate == null ? result : gate!(result);
  }

  @override
  Future<RemoteNotification> status(String id, String token) async {
    statusCalls++;
    tokens.add(token);
    if (fail != null) throw NotificationException(fail!);
    return logical.values.firstWhere((n) => n.id == id);
  }

  @override
  Future<RemoteNotification> retry(String id, bool risk, String token) async {
    retryCalls++;
    tokens.add(token);
    final old = logical.values.firstWhere((n) => n.id == id);
    final n = RemoteNotification(
      id: id,
      state: old.state,
      updatedAt: '2026-10-20T12:00:0$retryCalls.000Z',
      providerAccepted: false,
    );
    replace(n);
    if (loseRetry) {
      loseRetry = false;
      throw const NotificationException(NotificationErrorCode.network);
    }
    return n;
  }

  @override
  Future<NotificationQuota> quota(String token) async {
    quotaCalls++;
    return NotificationQuota(
      enabled: true,
      checkedAt: DateTime.now().toUtc(),
      limit: 1,
      remaining: quotaRemaining,
      reserved: 0,
      providerAccepted: 0,
    );
  }

  @override
  Future<void> registerDevice(String id, String value, String token) async {
    registrations++;
    tokens.add(token);
  }

  @override
  Future<void> unregisterDevice(String id, String token) async {
    removals++;
    tokens.add(token);
  }
}

class Harness {
  Harness({OfflineValueStorage? values}) : values = values ?? MemoryValues() {
    store = SerializedOfflineDocumentStore(this.values);
    repo = create();
  }
  final OfflineValueStorage values;
  late final OfflineDocumentStore store;
  final remote = FakeRemote();
  NotificationAccount? account = session(online: false);
  DateTime now = DateTime.utc(2026, 10, 20);
  late DurableNotificationsRepository repo;
  DurableNotificationsRepository create() => DurableNotificationsRepository(
    store: store,
    remote: remote,
    account: () => account,
    now: () => now,
  );
  void online() {
    account = session();
    repo.accountChanged();
  }
}
