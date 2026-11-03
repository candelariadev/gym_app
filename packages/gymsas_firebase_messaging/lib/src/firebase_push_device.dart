import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:gymsas_notifications/gymsas_notifications.dart';

class FirebasePushDevice implements PushDevice {
  FirebasePushDevice({FirebaseMessaging? messaging}) : _provided = messaging;
  final FirebaseMessaging? _provided;
  FirebaseMessaging get _messaging => _provided ?? FirebaseMessaging.instance;
  @override
  bool get supported =>
      !kIsWeb &&
      {
        TargetPlatform.android,
        TargetPlatform.iOS,
      }.contains(defaultTargetPlatform);
  @override
  Stream<String> get tokenChanges =>
      supported ? _messaging.onTokenRefresh : const Stream.empty();
  @override
  Stream<PushRoutineReference> get opened => supported
      ? FirebaseMessaging.onMessageOpenedApp
            .map(reference)
            .where((r) => r != null)
            .cast<PushRoutineReference>()
      : const Stream.empty();
  @override
  Stream<PushRoutineReference> get foreground => supported
      ? FirebaseMessaging.onMessage
            .map(reference)
            .where((r) => r != null)
            .cast<PushRoutineReference>()
      : const Stream.empty();
  static PushRoutineReference? reference(RemoteMessage message) {
    final d = message.data;
    final routine = d['routine_id'], id = d['notification_id'];
    final safe = RegExp(r'^[a-zA-Z0-9_-]{1,128}$');
    if (d['type'] != 'routine_ready' ||
        routine is! String ||
        id is! String ||
        !safe.hasMatch(routine) ||
        !safe.hasMatch(id)) {
      return null;
    }
    return PushRoutineReference(routineId: routine, notificationId: id);
  }

  PushPermission _permission(AuthorizationStatus value) => switch (value) {
    AuthorizationStatus.authorized ||
    AuthorizationStatus.provisional => PushPermission.allowed,
    AuthorizationStatus.denied => PushPermission.denied,
    _ => PushPermission.notDetermined,
  };
  @override
  Future<PushPermission> permission() async => supported
      ? _permission(
          (await _messaging.getNotificationSettings()).authorizationStatus,
        )
      : PushPermission.unsupported;
  @override
  Future<PushPermission> requestPermission() async {
    if (!supported) return PushPermission.unsupported;
    final value = _permission(
      (await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      )).authorizationStatus,
    );
    if (value == PushPermission.allowed) {
      await _messaging.setAutoInitEnabled(true);
    }
    return value;
  }

  @override
  Future<String?> token() async {
    if (!supported || await permission() != PushPermission.allowed) return null;
    // La app sólo solicita token con opt-in durable de la cuenta activa.
    // Logout deshabilita auto-init; una sesión posterior debe restaurarlo.
    await _messaging.setAutoInitEnabled(true);
    if (defaultTargetPlatform == TargetPlatform.iOS &&
        await _messaging.getAPNSToken() == null) {
      return null;
    }
    return _messaging.getToken();
  }

  @override
  Future<void> deleteToken() async {
    if (supported) {
      await _messaging.setAutoInitEnabled(false);
      await _messaging.deleteToken();
    }
  }

  @override
  Future<PushRoutineReference?> initialMessage() async {
    if (!supported) return null;
    final message = await _messaging.getInitialMessage();
    return message == null ? null : reference(message);
  }
}
