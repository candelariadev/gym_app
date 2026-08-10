import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/features/coach/presentation/pages/coach_client_profile_page.dart';
import 'package:gym_app/features/coach/presentation/pages/coach_clients_page.dart';
import 'package:gym_app/features/coach/presentation/pages/coach_routine_detail_page.dart';
import 'package:gym_app/l10n/app_localizations.dart';
import 'package:gymsas_clients/gymsas_clients.dart';
import 'package:gymsas_design_system/gymsas_design_system.dart';

void main() {
  testWidgets('muestra clientes y rutinas reales en español', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light(),
        home: CoachClientsPage(
          getTrainerClients: GetTrainerClientsUseCase(_Repository()),
        ),
        onGenerateRoute: (settings) => MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => settings.name == CoachRoutineDetailPage.routeName
              ? const CoachRoutineDetailPage()
              : const CoachClientProfilePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kevin Ramos'), findsOneWidget);
    expect(find.text('1 rutina asignada'), findsOneWidget);

    await tester.tap(find.text('Kevin Ramos'));
    await tester.pumpAndSettle();

    expect(find.text('Rutinas asignadas'), findsOneWidget);
    expect(find.text('Upper body'), findsOneWidget);
    expect(find.text('Lunes · 1 ejercicio'), findsOneWidget);
    expect(find.text('Ver detalle'), findsOneWidget);
    expect(find.textContaining('bench-press'), findsNothing);

    await tester.ensureVisible(find.text('Ver detalle'));
    await tester.tap(find.text('Ver detalle'));
    await tester.pumpAndSettle();

    expect(find.text('Detalle de rutina'), findsOneWidget);
    expect(find.text('Plan semanal'), findsOneWidget);
    expect(find.text('Lunes'), findsOneWidget);
    expect(find.text('bench-press'), findsOneWidget);
    expect(find.text('Series'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('Descanso'), findsOneWidget);
    expect(find.text('90 s'), findsOneWidget);
  });
}

class _Repository implements TrainerClientRepository {
  @override
  Future<List<TrainerClient>> getClients() async => const [
    TrainerClient(
      id: 'client-1',
      ownerId: 'gym-1',
      name: 'Kevin Ramos',
      email: 'kevin@example.com',
      goals: ['strength'],
      user: 'kevin',
      assignedTrainers: [],
      assignedWorkouts: [
        AssignedWorkout(
          routineId: '550e8400-e29b-41d4-a716-446655440000',
          ownerId: 'gym-1',
          callerId: 'trainer-1',
          userId: 'kevin',
          name: 'Upper body',
          days: [
            WorkoutDayPlan(
              day: WorkoutDay.monday,
              exercises: [
                WorkoutExercise(
                  exerciseId: 'bench-press',
                  sets: 4,
                  reps: 8,
                  restSeconds: 90,
                ),
              ],
            ),
          ],
          status: 'ACTIVE',
        ),
      ],
      status: 'ACTIVE',
    ),
  ];
}
