import 'package:flutter_test/flutter_test.dart';
import 'package:gymsas_api_client/gymsas_api_client.dart';
import 'package:gymsas_notifications/gymsas_notifications.dart';
import 'package:gymsas_notifications/src/infrastructure/graphql_notification_remote.dart';
import 'support.dart';

class Client implements GraphQlClient {
  Map<String, dynamic> result = {};
  Map<String, dynamic>? variables;
  String? document, token;
  @override
  Future<Map<String, dynamic>> execute({
    required String document,
    Map<String, dynamic> variables = const {},
    String? accessToken,
  }) async {
    this.document = document;
    this.variables = variables;
    token = accessToken;
    return result;
  }

  @override
  void close() {}
}

void main() {
  test(
    'registro y baja requieren ACK verdadero, no sólo HTTP exitoso',
    () async {
      final c = Client(), remote = GraphQlNotificationRemote(Client());
      await expectLater(
        remote.registerDevice('phone', 'synthetic-token', 'test'),
        throwsA(isA<NotificationException>()),
      );
      c.result = {'registerPushDevice': false, 'unregisterPushDevice': false};
      final r = GraphQlNotificationRemote(c);
      await expectLater(
        r.registerDevice('phone', 'synthetic-token', 'test'),
        throwsA(isA<NotificationException>()),
      );
      await expectLater(
        r.unregisterDevice('phone', 'test'),
        throwsA(isA<NotificationException>()),
      );
      c.result = {'registerPushDevice': true, 'unregisterPushDevice': true};
      await r.registerDevice('phone', 'synthetic-token', 'test');
      await r.unregisterDevice('phone', 'test');
    },
  );
  test(
    'envía confirmación explícita y clave estable sólo mediante BFF',
    () async {
      final c = Client()
        ..result = {
          'notifyRoutineReady': {
            'id': 'n',
            'status': 'pending',
            'updatedAt': '2026-10-20T12:00:00Z',
            'providerAccepted': false,
          },
        };
      final r = await GraphQlNotificationRemote(
        c,
      ).notify(target, 'en', 'stable-key', 'test-access-token');
      expect(c.variables!['input'], {
        'routineId': target.routineId,
        'clientId': target.clientId,
        'language': 'en',
        'idempotencyKey': 'stable-key',
        'confirm': true,
      });
      expect(c.token, 'test-access-token');
      expect(r.state, NotificationDeliveryState.pending);
      expect(r.providerAccepted, false);
    },
  );
  test('aceptación del proveedor no se convierte en entrega', () async {
    final c = Client()
      ..result = {
        'notification': {
          'id': 'n',
          'status': 'provider_accepted',
          'updatedAt': '2026-10-20T12:00:00Z',
          'providerAccepted': true,
        },
      };
    final n = await GraphQlNotificationRemote(c).status('n', 'test');
    expect(n.state, NotificationDeliveryState.providerAccepted);
    expect(c.document, isNot(contains('delivered')));
  });
  test('un estado no soportado no se presenta como éxito', () async {
    final c = Client()
      ..result = {
        'notification': {
          'id': 'n',
          'status': 'delivered',
          'updatedAt': '2026-10-20T12:00:00Z',
          'providerAccepted': true,
        },
      };
    await expectLater(
      GraphQlNotificationRemote(c).status('n', 'test'),
      throwsA(
        isA<NotificationException>().having(
          (e) => e.code,
          'code',
          NotificationErrorCode.invalidResponse,
        ),
      ),
    );
  });
  test(
    'políticas legadas deshabilitadas no se convierten en ilimitadas',
    () async {
      final c = Client()
        ..result = {
          'notificationQuota': {
            'enabled': false,
            'reason': 'policy_not_configured',
          },
        };
      final q = await GraphQlNotificationRemote(c).quota('test');
      expect(q.enabled, false);
      expect(q.limit, isNull);
      expect(q.unlimited, false);
    },
  );
  test('cuota Float GraphQL e ilimitado explícito se conservan', () async {
    final c = Client()
      ..result = {
        'notificationQuota': {
          'enabled': true,
          'limit': -1.0,
          'remaining': -1.0,
          'reserved': 2.0,
          'providerAccepted': 3.0,
          'resetsAt': '2026-11-01T00:00:00Z',
        },
      };
    final q = await GraphQlNotificationRemote(c).quota('test');
    expect(q.unlimited, true);
    expect(q.reserved, 2);
    expect(q.providerAccepted, 3);
  });
  test('mapea errores HTTP GraphQL sin exponer el mensaje del servidor', () {
    for (final pair in {
      401: NotificationErrorCode.unauthorized,
      403: NotificationErrorCode.forbidden,
      409: NotificationErrorCode.conflict,
      422: NotificationErrorCode.policyDisabled,
      429: NotificationErrorCode.quotaExceeded,
      503: NotificationErrorCode.unavailable,
    }.entries) {
      final e = mapNotificationError(
        GraphQlException([
          GraphQlError(
            message: 'private-provider-detail',
            extensions: {'httpStatus': pair.key},
          ),
        ]),
      );
      expect(e.code, pair.value);
      expect(e.toString(), isNot(contains('private-provider-detail')));
    }
  });
  test('el reintento mantiene ID y propaga la aceptación del riesgo', () async {
    final c = Client()
      ..result = {
        'retryNotification': {
          'id': 'n',
          'status': 'pending',
          'updatedAt': '2026-10-20T12:00:00Z',
          'providerAccepted': false,
        },
      };
    await GraphQlNotificationRemote(c).retry('n', true, 'test');
    expect(c.variables, {'id': 'n', 'risk': true});
  });
}
