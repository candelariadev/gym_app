import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/features/dashboard/presentation/pages/trainer_dashboard_page.dart';
import 'package:gym_app/l10n/app_localizations.dart';
import 'package:gymsas_auth/gymsas_auth.dart';
import 'package:gymsas_dashboard/gymsas_dashboard.dart';

void main() {
  testWidgets('pull to refresh solicita nuevamente las métricas', (
    tester,
  ) async {
    final repository = _RefreshingDashboardRepository();
    final useCase = GetTrainerDashboardUseCase(repository);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: TrainerDashboardPage(
          session: AuthSession(
            accessToken: 'token',
            accessTokenExpiresAt: DateTime(2026, 8, 12, 20),
            refreshToken: 'refresh',
            refreshTokenExpiresAt: DateTime(2026, 8, 13),
            ownerId: 'tenant_1',
            user: 'trainer',
            role: UserRole.trainer,
          ),
          getTrainerDashboard: useCase,
          onLogout: () {},
          onOpenClients: () {},
          onCreateRoutine: () {},
          onOpenExerciseCatalog: () {},
          onOpenPlans: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(repository.calls, 1);

    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, 350));
    await tester.pumpAndSettle();

    expect(repository.calls, 2);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('Planes'), findsOneWidget);
    expect(find.text('Planes y suscripción'), findsNothing);
  });
}

class _RefreshingDashboardRepository implements TrainerDashboardRepository {
  int calls = 0;

  @override
  Future<TrainerDashboard> getDashboard() async {
    calls++;
    final available = calls > 1;
    return TrainerDashboard(
      activeClients: DashboardMetric(
        value: available ? 7 : null,
        status: available
            ? DashboardMetricStatus.available
            : DashboardMetricStatus.unavailable,
      ),
      assignedWorkouts: DashboardMetric(
        value: available ? 5 : null,
        status: available
            ? DashboardMetricStatus.available
            : DashboardMetricStatus.unavailable,
      ),
      generatedAt: DateTime.utc(2026, 8, 12),
    );
  }
}
