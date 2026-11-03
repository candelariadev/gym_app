import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/features/notifications/application/notifications_controller.dart';
import 'package:gymsas_notifications/gymsas_notifications.dart';
import '../../../packages/gymsas_notifications/test/support.dart';

class FakePush implements PushDevice {
  final tokens = StreamController<String>.broadcast(),
      opens = StreamController<PushRoutineReference>.broadcast(),
      messages = StreamController<PushRoutineReference>.broadcast();
  PushPermission status = PushPermission.allowed;
  Completer<PushPermission>? permissionGate;
  int requests = 0, deletes = 0;
  String value = 'test-device-token';
  @override
  bool get supported => true;
  @override
  Stream<String> get tokenChanges => tokens.stream;
  @override
  Stream<PushRoutineReference> get opened => opens.stream;
  @override
  Stream<PushRoutineReference> get foreground => messages.stream;
  @override
  Future<PushPermission> permission() async => status;
  @override
  Future<PushPermission> requestPermission() async {
    requests++;
    return permissionGate == null ? status : permissionGate!.future;
  }

  @override
  Future<String?> token() async => value;
  @override
  Future<void> deleteToken() async {
    deletes++;
  }

  @override
  Future<PushRoutineReference?> initialMessage() async => null;
  Future<void> close() async {
    await tokens.close();
    await opens.close();
    await messages.close();
  }
}

Future<void> waitFor(bool Function() condition) async {
  for (var i = 0; i < 100; i++) {
    if (condition()) return;
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
  expect(condition(), true);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'actualiza cuota después de confirmar el envío, no antes de reservar',
    () async {
      final h = Harness()..online();
      final c = NotificationsController(
        repository: h.repo,
        account: () => h.account,
      );
      addTearDown(() {
        c.dispose();
        h.repo.dispose();
      });
      final entered = Completer<void>(),
          response = Completer<RemoteNotification>();
      h.remote.gate = (n) {
        entered.complete();
        return response.future;
      };
      await c.refreshQuota();
      final operation = c.confirm(target, 'es');
      await entered.future;
      expect(c.busy, contains(target.key));
      expect(c.quotaFresh, false);
      h.remote.quotaRemaining = 0;
      response.complete(h.remote.current);
      await operation;
      expect(c.quota!.remaining, 0);
      expect(c.quotaFresh, true);
      expect(c.busy, isEmpty);
    },
  );
  test(
    'no solicita permiso sin acción y registra únicamente tras consentimiento',
    () async {
      final h = Harness()..online(), push = FakePush();
      final c = NotificationsController(
        repository: h.repo,
        account: () => h.account,
        push: push,
      );
      addTearDown(() async {
        c.dispose();
        h.repo.dispose();
        await push.close();
      });
      c.start();
      await c.reloadLocal();
      expect(push.requests, 0);
      expect(h.remote.registrations, 0);
      await c.enablePush();
      expect(push.requests, 1);
      expect(c.pushRegistered, true);
      expect(h.remote.registrations, 1);
      push.value = 'rotated-token';
      push.tokens.add(push.value);
      await waitFor(() => h.remote.registrations == 2);
      expect(c.pushRegistered, true);
    },
  );
  test(
    'permiso denegado no registra tokens ni oculta el uso offline',
    () async {
      final h = Harness()..online(),
          push = FakePush()..status = PushPermission.denied;
      final c = NotificationsController(
        repository: h.repo,
        account: () => h.account,
        push: push,
      );
      addTearDown(() async {
        c.dispose();
        h.repo.dispose();
        await push.close();
      });
      await c.enablePush();
      expect(c.permission, PushPermission.denied);
      expect(c.pushEnabled, false);
      expect(h.remote.registrations, 0);
    },
  );
  test(
    'permiso que termina después de cambiar cuenta no registra en otra identidad',
    () async {
      final h = Harness()..online(),
          push = FakePush()..permissionGate = Completer();
      final c = NotificationsController(
        repository: h.repo,
        account: () => h.account,
        push: push,
      );
      addTearDown(() async {
        c.dispose();
        h.repo.dispose();
        await push.close();
      });
      final operation = c.enablePush();
      h.account = session(scope: 'backend/other/user');
      h.repo.accountChanged();
      c.accountChanged();
      push.permissionGate!.complete(PushPermission.allowed);
      await operation;
      await c.reloadLocal();
      expect(h.remote.registrations, 0);
      expect(c.pushEnabled, false);
    },
  );
  test(
    'antes de logout desregistra, borra token y conserva preferencias y cola protegida',
    () async {
      final h = Harness()..online(), push = FakePush();
      final c = NotificationsController(
        repository: h.repo,
        account: () => h.account,
        push: push,
      );
      addTearDown(() async {
        c.dispose();
        h.repo.dispose();
        await push.close();
      });
      await c.enablePush();
      await h.repo.rememberConfirmed(target);
      await c.beforeLogout();
      expect(h.remote.removals, 1);
      expect(push.deletes, 1);
      expect(c.pushRegistered, false);
      expect(await h.repo.pushEnabled(), true);
      expect(await h.repo.deviceRemovalPending(), false);
      expect((await h.repo.history()).length, 1);
    },
  );
  test(
    'desactivar sin conexión conserva una baja durable y no afirma desactivación remota',
    () async {
      final h = Harness()..online(), push = FakePush();
      final c = NotificationsController(
        repository: h.repo,
        account: () => h.account,
        push: push,
      );
      addTearDown(() async {
        c.dispose();
        h.repo.dispose();
        await push.close();
      });
      await c.enablePush();
      h.account = session(online: false);
      await c.disablePush();
      expect(await h.repo.pushEnabled(), false);
      expect(await h.repo.deviceRemovalPending(), true);
      expect(c.deviceRemovalPending, true);
      h.online();
      await h.repo.flushDeviceRemoval();
      expect(await h.repo.deviceRemovalPending(), false);
      expect(h.remote.removals, 1);
    },
  );
  test('los mensajes en primer plano se ocultan al cambiar cuenta', () async {
    final h = Harness()..online(), push = FakePush();
    final c = NotificationsController(
      repository: h.repo,
      account: () => h.account,
      push: push,
    );
    addTearDown(() async {
      c.dispose();
      h.repo.dispose();
      await push.close();
    });
    c.start();
    await c.enablePush();
    push.messages.add(
      const PushRoutineReference(routineId: 'r', notificationId: 'n'),
    );
    await waitFor(() => c.foregroundReference != null);
    h.account = session(scope: 'new/tenant/user');
    h.repo.accountChanged();
    c.accountChanged();
    expect(c.foregroundReference, isNull);
    expect(c.entries, isEmpty);
    expect(c.quota, isNull);
  });
}
