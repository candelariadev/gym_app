import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymsas_notifications/gymsas_notifications.dart';
import 'package:gymsas_notifications/src/infrastructure/durable_notifications_repository.dart';
import 'package:gymsas_offline/gymsas_offline_native.dart';
import 'support.dart';

void main() {
  test(
    'recordar una rutina confirmada nunca envía sin consentimiento',
    () async {
      final h = Harness();
      addTearDown(h.repo.dispose);
      await h.repo.rememberConfirmed(target);
      h.online();
      await h.repo.synchronize();
      expect(h.remote.notifyCalls, 0);
      expect(
        (await h.repo.history()).single.state,
        NotificationDeliveryState.ready,
      );
    },
  );
  test(
    'rechaza referencias locales y no acepta rutinas no confirmadas',
    () async {
      final h = Harness();
      addTearDown(h.repo.dispose);
      await expectLater(
        h.repo.rememberConfirmed(
          const ConfirmedRoutineTarget(
            routineId: 'local-123',
            clientId: 'c',
            clientName: 'Client',
            routineName: 'A',
          ),
        ),
        throwsA(isA<NotificationException>()),
      );
      expect(h.remote.notifyCalls, 0);
      await expectLater(
        h.repo.confirm('missing', 'es'),
        throwsA(isA<NotificationException>()),
      );
    },
  );
  test(
    'doble clic concurrente conserva una sola clave y solicitud lógica',
    () async {
      final h = Harness();
      addTearDown(h.repo.dispose);
      await h.repo.rememberConfirmed(target);
      h.online();
      await Future.wait(
        List.generate(20, (_) => h.repo.confirm(target.key, 'es')),
      );
      await h.repo.synchronize();
      expect(h.remote.logical.length, 1);
      expect(h.remote.keys.toSet().length, 1);
      expect((await h.repo.history()).single.serverId, isNotNull);
    },
  );
  test(
    'sobrevive disco real cifrado, reapertura sin red y respuesta perdida',
    () async {
      final dir = await Directory.systemTemp.createTemp(
        'notification-offline-test-',
      );
      addTearDown(() => dir.delete(recursive: true));
      final key = List.generate(32, (i) => i);
      final h = Harness(values: EncryptedFileOfflineValueStorage(dir, key));
      await h.repo.rememberConfirmed(target);
      await h.repo.confirm(target.key, 'en');
      await h.repo.synchronize();
      final original = (await h.repo.history()).single.idempotencyKey;
      h.repo.dispose();
      final reopened = SerializedOfflineDocumentStore(
        EncryptedFileOfflineValueStorage(dir, key),
      );
      var account = session(online: false);
      final second = DurableNotificationsRepository(
        store: reopened,
        remote: h.remote,
        account: () => account,
      );
      addTearDown(second.dispose);
      expect((await second.history()).single.idempotencyKey, original);
      await second.synchronize();
      expect(h.remote.notifyCalls, 0);
      account = session();
      h.remote.loseNotify = true;
      await second.synchronize();
      expect(h.remote.logical.length, 1);
      second.dispose();
      final third = DurableNotificationsRepository(
        store: reopened,
        remote: h.remote,
        account: () => account,
      );
      addTearDown(third.dispose);
      await third.synchronize();
      expect(h.remote.logical.length, 1);
      expect(h.remote.keys, [original, original]);
      expect((await third.history()).single.serverId, isNotNull);
      for (final file in dir.listSync().whereType<File>()) {
        final value = await file.readAsString();
        expect(value, isNot(contains(target.clientName)));
        expect(value, isNot(contains('test-only-session-not-to-store')));
      }
    },
  );
  test('si falla guardar consentimiento no se llama al servidor', () async {
    final values = MemoryValues(), h = Harness();
    final durable = Harness(values: values);
    addTearDown(durable.repo.dispose);
    addTearDown(h.repo.dispose);
    await durable.repo.rememberConfirmed(target);
    values.failWrites = true;
    await expectLater(
      durable.repo.confirm(target.key, 'es'),
      throwsA(
        isA<NotificationException>().having(
          (e) => e.code,
          'code',
          NotificationErrorCode.storage,
        ),
      ),
    );
    expect(durable.remote.notifyCalls, 0);
    values.failWrites = false;
    expect((await durable.repo.history()).single.confirmedAt, isNull);
  });
  test(
    'fallo al persistir ACK conserva clave para recuperar sin duplicar',
    () async {
      final values = MemoryValues(), h = Harness(values: MemoryValues());
      addTearDown(h.repo.dispose);
      final test = Harness(values: values);
      await test.repo.rememberConfirmed(target);
      await test.repo.confirm(target.key, 'es');
      test.online();
      test.remote.afterNotify = () => values.failWrites = true;
      await expectLater(
        test.repo.synchronize(),
        throwsA(isA<NotificationException>()),
      );
      test.repo.dispose();
      values.failWrites = false;
      test.remote.afterNotify = null;
      final reopened = test.create();
      addTearDown(reopened.dispose);
      await reopened.synchronize();
      expect(test.remote.logical.length, 1);
      expect(test.remote.keys.toSet().length, 1);
      expect((await reopened.history()).single.serverId, isNotNull);
    },
  );
  test('aísla historial y cola entre backend, tenant y usuario', () async {
    final h = Harness();
    addTearDown(h.repo.dispose);
    await h.repo.rememberConfirmed(target);
    await h.repo.confirm(target.key, 'es');
    for (final scope in [
      'other-backend/tenant/user',
      'backend/other-tenant/user',
      'backend/tenant/other-user',
    ]) {
      h.account = session(scope: scope);
      h.repo.accountChanged();
      expect(await h.repo.history(), isEmpty);
      await h.repo.synchronize();
    }
    expect(h.remote.notifyCalls, 0);
    h.account = session();
    h.repo.accountChanged();
    await h.repo.synchronize();
    expect(h.remote.notifyCalls, 1);
  });
  test(
    'un ACK tardío nunca modifica la cuenta que acaba de iniciar sesión',
    () async {
      final h = Harness();
      addTearDown(h.repo.dispose);
      await h.repo.rememberConfirmed(target);
      await h.repo.confirm(target.key, 'es');
      h.online();
      final gate = Completer<RemoteNotification>();
      h.remote.gate = (_) => gate.future;
      final sync = h.repo.synchronize();
      while (h.remote.notifyCalls == 0) {
        await Future<void>.delayed(Duration.zero);
      }
      h.account = session(scope: 'backend/other/user');
      h.repo.accountChanged();
      gate.complete(h.remote.current);
      await expectLater(sync, throwsA(isA<NotificationException>()));
      expect(await h.repo.history(), isEmpty);
      expect(h.remote.tokens.single, 'test-only-session-not-to-store');
      h.account = session(online: false);
      h.repo.accountChanged();
      expect((await h.repo.history()).single.serverId, isNull);
    },
  );
  test(
    '401 pausa el envío, no descarta intención y exige nueva sesión',
    () async {
      final h = Harness();
      addTearDown(h.repo.dispose);
      await h.repo.rememberConfirmed(target);
      await h.repo.confirm(target.key, 'es');
      h.online();
      h.remote.fail = NotificationErrorCode.unauthorized;
      await h.repo.synchronize();
      await h.repo.synchronize();
      expect(h.remote.notifyCalls, 1);
      expect(
        (await h.repo.history()).single.error,
        NotificationErrorCode.unauthorized,
      );
      h.remote.fail = null;
      h.repo.accountChanged();
      await h.repo.synchronize();
      expect(h.remote.logical.length, 1);
    },
  );
  test(
    'cuota o permisos rechazados no disparan reintentos automáticos',
    () async {
      for (final code in [
        NotificationErrorCode.quotaExceeded,
        NotificationErrorCode.forbidden,
        NotificationErrorCode.policyDisabled,
        NotificationErrorCode.conflict,
      ]) {
        final h = Harness();
        await h.repo.rememberConfirmed(target);
        await h.repo.confirm(target.key, 'es');
        h.online();
        h.remote.fail = code;
        await h.repo.synchronize();
        await h.repo.synchronize();
        expect(h.remote.notifyCalls, 1);
        expect((await h.repo.history()).single.error, code);
        h.repo.dispose();
      }
    },
  );
  test(
    'un reintento manual incierto exige confirmar riesgo y no se duplica tras timeout',
    () async {
      final h = Harness();
      await h.repo.rememberConfirmed(target);
      await h.repo.confirm(target.key, 'es');
      h.online();
      h.remote.initialState = NotificationDeliveryState.uncertain;
      await h.repo.synchronize();
      await expectLater(
        h.repo.retry(target.key),
        throwsA(isA<NotificationException>()),
      );
      expect(h.remote.retryCalls, 0);
      h.remote.loseRetry = true;
      await h.repo.retry(target.key, acknowledgeDuplicateRisk: true);
      await h.repo.synchronize();
      expect(h.remote.retryCalls, 1);
      h.repo.dispose();
      final reopened = h.create();
      addTearDown(reopened.dispose);
      await reopened.synchronize();
      expect(h.remote.retryCalls, 1);
      expect((await reopened.history()).single.retryBaseUpdatedAt, isNull);
      expect(
        (await reopened.history()).single.state,
        NotificationDeliveryState.uncertain,
      );
    },
  );
  test(
    'consulta pendientes y nunca llama retry sobre aceptación del proveedor',
    () async {
      final h = Harness();
      addTearDown(h.repo.dispose);
      await h.repo.rememberConfirmed(target);
      await h.repo.confirm(target.key, 'es');
      h.online();
      await h.repo.synchronize();
      final old = h.remote.current;
      h.remote.replace(
        RemoteNotification(
          id: old.id,
          state: NotificationDeliveryState.providerAccepted,
          updatedAt: '2026-10-20T12:00:01.000Z',
          providerAccepted: true,
        ),
      );
      await h.repo.synchronize();
      await h.repo.synchronize();
      expect(h.remote.notifyCalls, 1);
      expect(h.remote.retryCalls, 0);
      expect(h.remote.statusCalls, 1);
      expect((await h.repo.history()).single.providerAccepted, true);
    },
  );
  test(
    'schema corrupto se conserva y no provoca envío ni reinicialización',
    () async {
      final h = Harness();
      addTearDown(h.repo.dispose);
      await h.store.update(
        h.account!.scope,
        (d) => d['notifications'] = {'version': 99, 'records': {}},
      );
      await expectLater(
        h.repo.history(),
        throwsA(isA<NotificationException>()),
      );
      await expectLater(
        h.repo.rememberConfirmed(target),
        throwsA(isA<NotificationException>()),
      );
      expect(
        (await h.store.read(h.account!.scope))['notifications']['version'],
        99,
      );
      expect(h.remote.notifyCalls, 0);
    },
  );
  test(
    'no guarda credenciales ni tokens de dispositivo en documentos',
    () async {
      final values = MemoryValues(), h = Harness(values: MemoryValues());
      addTearDown(h.repo.dispose);
      final test = Harness(values: values);
      addTearDown(test.repo.dispose);
      await test.repo.rememberConfirmed(target);
      await test.repo.confirm(target.key, 'es');
      test.online();
      await test.repo.registerDevice(
        'phone',
        'private-device-token',
        expectedScope: test.account!.scope,
      );
      await test.repo.synchronize();
      final saved = values.values.values.join();
      expect(saved, isNot(contains('private-device-token')));
      expect(saved, isNot(contains(test.account!.accessToken)));
    },
  );
  test(
    'cuota en caché e instalación estable sobreviven a reapertura',
    () async {
      final h = Harness();
      addTearDown(h.repo.dispose);
      h.online();
      await h.repo.refreshQuota();
      final id = await h.repo.installationId();
      final reopened = h.create();
      addTearDown(reopened.dispose);
      expect((await reopened.cachedQuota())!.remaining, 1);
      expect(await reopened.installationId(), id);
      h.account = session(scope: 'other/account');
      h.repo.accountChanged();
      expect(await h.repo.cachedQuota(), isNull);
      expect(await h.repo.installationId(), id);
    },
  );
}
