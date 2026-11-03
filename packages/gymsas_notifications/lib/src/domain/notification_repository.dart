import 'notification_models.dart';

abstract interface class NotificationsRepository {
  Stream<void> get changes;
  Future<List<RoutineNotification>> history();
  Future<void> rememberConfirmed(ConfirmedRoutineTarget target);
  Future<void> confirm(String targetKey, String language);
  Future<void> retry(String targetKey, {bool acknowledgeDuplicateRisk = false});
  Future<NotificationQuota?> cachedQuota();
  Future<NotificationQuota> refreshQuota();
  Future<void> synchronize();
  Future<void> setPushEnabled(bool value);
  Future<bool> pushEnabled();
  Future<void> deferDeviceRemoval();
  Future<bool> deviceRemovalPending();
  Future<void> flushDeviceRemoval();
  Future<String> installationId();
  Future<void> registerDevice(
    String id,
    String token, {
    required String expectedScope,
  });
  Future<void> unregisterDevice(String id, {required String expectedScope});
}

abstract interface class NotificationRemote {
  Future<RemoteNotification> notify(
    ConfirmedRoutineTarget target,
    String language,
    String idempotencyKey,
    String accessToken,
  );
  Future<RemoteNotification> status(String id, String accessToken);
  Future<RemoteNotification> retry(
    String id,
    bool acknowledgeRisk,
    String accessToken,
  );
  Future<NotificationQuota> quota(String accessToken);
  Future<void> registerDevice(String id, String token, String accessToken);
  Future<void> unregisterDevice(String id, String accessToken);
}
