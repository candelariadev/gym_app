import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/features/notifications/application/notifications_controller.dart';
import 'package:gym_app/features/notifications/presentation/routine_notification_panel.dart';
import 'package:gym_app/features/notifications/presentation/notification_routine_page.dart';
import 'package:gym_app/l10n/app_localizations.dart';
import 'package:gymsas_design_system/gymsas_design_system.dart';
import 'package:gymsas_workouts/gymsas_workouts.dart';
import '../../../packages/gymsas_notifications/test/support.dart';

Widget app(Widget child, {String locale = 'es', bool page = false}) =>
    MaterialApp(
      locale: Locale(locale),
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: page ? child : Scaffold(body: SingleChildScrollView(child: child)),
    );

class RemoteWorkouts implements WorkoutRepository {
  int calls = 0;
  @override
  Future<List<Workout>> getMyWorkouts({bool? activeOnly}) async {
    calls++;
    return const [
      Workout(
        routineId: 'other',
        userId: 'client',
        name: 'Private other routine',
        status: 'ACTIVE',
      ),
    ];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets(
    'requiere confirmar y diferencia solicitud pendiente de entrega',
    (tester) async {
      final h = Harness();
      addTearDown(h.repo.dispose);
      await h.repo.rememberConfirmed(target);
      h.online();
      final c = NotificationsController(
        repository: h.repo,
        account: () => h.account,
      );
      addTearDown(c.dispose);
      await c.reloadLocal();
      await c.refreshQuota();
      await tester.pumpWidget(
        app(RoutineNotificationPanel(controller: c, targets: const [target])),
      );
      await tester.pumpAndSettle();
      expect(find.text('Notificar al cliente'), findsOneWidget);
      expect(h.remote.notifyCalls, 0);
      await tester.ensureVisible(find.text('Notificar al cliente'));
      await tester.tap(find.text('Notificar al cliente'));
      await tester.pumpAndSettle();
      expect(find.text('¿Notificar al cliente?'), findsOneWidget);
      expect(h.remote.notifyCalls, 0);
      await tester.tap(find.text('Confirmar notificación'));
      await tester.pumpAndSettle();
      await h.repo.synchronize();
      await c.reloadLocal();
      await tester.pumpAndSettle();
      expect(h.remote.logical.length, 1);
      expect(
        find.text('Solicitud aceptada por GymSAS; envío pendiente.'),
        findsOneWidget,
      );
      expect(find.textContaining('entregada'), findsNothing);
    },
  );
  testWidgets('cancelar la confirmación no guarda intención ni envía', (
    tester,
  ) async {
    final h = Harness();
    addTearDown(h.repo.dispose);
    await h.repo.rememberConfirmed(target);
    h.online();
    final c = NotificationsController(
      repository: h.repo,
      account: () => h.account,
    );
    addTearDown(c.dispose);
    await c.reloadLocal();
    await c.refreshQuota();
    await tester.pumpWidget(
      app(RoutineNotificationPanel(controller: c, targets: const [target])),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Notificar al cliente'));
    await tester.tap(find.text('Notificar al cliente'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ahora no'));
    await tester.pumpAndSettle();
    expect(h.remote.notifyCalls, 0);
    expect((await h.repo.history()).single.confirmedAt, isNull);
  });
  testWidgets('la cuota cacheada se señala y el flujo se localiza al inglés', (
    tester,
  ) async {
    final h = Harness()..online();
    addTearDown(h.repo.dispose);
    await h.repo.refreshQuota();
    await h.repo.rememberConfirmed(target);
    h.account = session(online: false);
    final c = NotificationsController(
      repository: h.repo,
      account: () => h.account,
    );
    addTearDown(c.dispose);
    await c.reloadLocal();
    await tester.pumpWidget(
      app(
        RoutineNotificationPanel(controller: c, targets: const [target]),
        locale: 'en',
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Notify the client'), findsOneWidget);
    expect(find.textContaining('Saved quota, not checked now'), findsOneWidget);
    expect(h.remote.notifyCalls, 0);
  });
  testWidgets('una referencia sin acceso no abre otra rutina ni usa caché', (
    tester,
  ) async {
    final remote = RemoteWorkouts();
    await tester.pumpWidget(
      app(
        NotificationRoutinePage(
          routineId: 'requested',
          verify: GetConfirmedWorkoutUseCase(remote),
          canVerify: () => true,
        ),
        page: true,
      ),
    );
    await tester.pumpAndSettle();
    expect(remote.calls, 1);
    expect(find.text('Private other routine'), findsNothing);
    expect(
      find.textContaining('No se pudo comprobar tu acceso'),
      findsOneWidget,
    );
  });
  testWidgets('sesión no autorizada no realiza consulta desde push', (
    tester,
  ) async {
    final remote = RemoteWorkouts();
    await tester.pumpWidget(
      app(
        NotificationRoutinePage(
          routineId: 'requested',
          verify: GetConfirmedWorkoutUseCase(remote),
          canVerify: () => false,
        ),
        page: true,
      ),
    );
    await tester.pumpAndSettle();
    expect(remote.calls, 0);
    expect(
      find.textContaining('No se pudo comprobar tu acceso'),
      findsOneWidget,
    );
  });
  testWidgets(
    'componentes compartidos soportan texto grande y tema sin desbordar',
    (tester) async {
      await tester.pumpWidget(
        app(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 900),
              textScaler: TextScaler.linear(2),
            ),
            child: const SizedBox(
              width: 300,
              child: GymActionStatusCard(
                title: 'Notification request',
                status:
                    'Accepted by provider, not delivery or read confirmation.',
                detail: 'Saved for this account',
                actionLabel: 'Refresh request status',
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    },
  );
}
