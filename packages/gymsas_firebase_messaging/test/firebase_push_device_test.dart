import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymsas_firebase_messaging/gymsas_firebase_messaging.dart';
import 'package:gymsas_notifications/gymsas_notifications.dart';

void main() {
  test(
    'convierte sólo referencias mínimas y seguras, sin filtrar el SDK al dominio',
    () {
      final r = FirebasePushDevice.reference(
        const RemoteMessage(
          data: {
            'type': 'routine_ready',
            'routine_id': 'routine-123',
            'notification_id': 'n-123',
            'private': 'ignored',
          },
        ),
      );
      expect(r, isA<PushRoutineReference>());
      expect(r!.routineId, 'routine-123');
    },
  );
  test('rechaza navegación arbitraria y mensajes ajenos a rutinas', () {
    for (final data in <Map<String, dynamic>>[
      {'type': 'other', 'routine_id': 'r', 'notification_id': 'n'},
      {
        'type': 'routine_ready',
        'routine_id': 'https://unsafe.test',
        'notification_id': 'n',
      },
      {'type': 'routine_ready', 'routine_id': 'r'},
      {'type': 'routine_ready', 'routine_id': 42, 'notification_id': 'n'},
    ]) {
      expect(FirebasePushDevice.reference(RemoteMessage(data: data)), isNull);
    }
  });
  test('plataformas no soportadas no inicializan Firebase Messaging', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final device = FirebasePushDevice();
    expect(device.supported, false);
    expect(await device.permission(), PushPermission.unsupported);
    expect(await device.requestPermission(), PushPermission.unsupported);
    expect(await device.token(), isNull);
    expect(await device.initialMessage(), isNull);
  });
}
