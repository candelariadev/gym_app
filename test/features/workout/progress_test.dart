import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/features/advised/presentation/pages/my_progress_page.dart';
import 'package:gym_app/features/workout/application/workout_session_store.dart';
import 'package:gym_app/features/workout/domain/workout_session_data.dart';
import 'package:gym_app/l10n/app_localizations.dart';
import 'package:gymsas_workouts/gymsas_workouts.dart' hide WorkoutExercise;
import 'package:gymsas_workouts/src/infrastructure/repositories/workout_progress_repository.dart';
import 'package:gymsas_api_client/gymsas_api_client.dart';
import 'package:gymsas_design_system/gymsas_design_system.dart';

void main() {
  test('restores recorded sets and persists completed performance', () async {
    final port = _PerformancePort();
    final store = WorkoutSessionStore(
      recordPerformance: RecordWorkoutPerformance(port),
      initialSession: const WorkoutSessionData(
        sessionId: 's',
        status: 'IN_PROGRESS',
        routineName: 'Routine',
        dayTitle: null,
        estimatedDurationMinutes: 20,
        totalSeries: 1,
        exercises: [
          WorkoutExercise(
            order: 1,
            name: 'Squat',
            exerciseId: 'squat',
            seriesCount: 1,
            repetitionRange: '10',
            recordedSets: [
              WorkoutSet(setNumber: 1, weightKg: 20, reps: 10, completed: true),
            ],
          ),
        ],
      ),
    );
    addTearDown(store.dispose);
    expect(store.weightsFor(0), [20]);
    expect(store.repetitionsFor(0), [10]);
    expect(store.areAllExercisesCompleted, isTrue);
    store.setSeriesWeight(0, 0, '22.5');
    await store.flushPerformance();
    expect(port.saved!.exercises.single.sets.single.weightKg, 22.5);
    expect(port.saved!.exercises.single.sets.single.completed, isTrue);
    store.toggleSeries(0, 0);
    expect(store.areAllExercisesCompleted, isFalse);
  });

  test('failed persistence remains visible and is retryable', () async {
    final port = _PerformancePort()..fail = true;
    final store = WorkoutSessionStore(
      recordPerformance: RecordWorkoutPerformance(port),
      initialSession: const WorkoutSessionData(
        sessionId: 's',
        status: 'IN_PROGRESS',
        routineName: 'R',
        dayTitle: null,
        estimatedDurationMinutes: 1,
        totalSeries: 1,
        exercises: [
          WorkoutExercise(
            order: 1,
            name: 'Squat',
            exerciseId: 'squat',
            seriesCount: 1,
            repetitionRange: '10',
          ),
        ],
      ),
    );
    addTearDown(store.dispose);
    await expectLater(
      store.flushPerformance(),
      throwsA(isA<ProgressException>()),
    );
    expect(store.saveFailed, isTrue);
    port.fail = false;
    await store.flushPerformance();
    expect(store.saveFailed, isFalse);
  });

  test(
    'GraphQL query forwards window and uses nullable measured load',
    () async {
      final client = _GraphQlClient();
      final repository = GraphQlWorkoutProgressRepository(
        client,
        () => 'test-token',
      );
      final progress = await repository.getProgress(
        ProgressRequest(
          from: DateTime(2026, 10, 1),
          to: DateTime(2026, 10, 20),
          granularity: ProgressGranularity.week,
          timeZone: '-06:00',
        ),
      );
      expect(client.variables['granularity'], 'WEEK');
      expect(client.variables['timeZone'], '-06:00');
      expect(progress.historyMonths, 1);
      expect(progress.points.single.maxWeightKg, isNull);
    },
  );

  testWidgets(
    'shows subscription window, chart and daily weekly monthly controls',
    (tester) async {
      final port = _QueryPort();
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.light(),
          home: MyProgressPage(getProgress: GetWorkoutProgress(port)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(GymProgressChart), findsOneWidget);
      expect(find.text('Diario'), findsOneWidget);
      expect(find.text('Semanal'), findsOneWidget);
      expect(find.text('Mensual'), findsOneWidget);
      await tester.tap(find.text('Mensual'));
      await tester.pumpAndSettle();
      expect(port.lastRequest!.granularity, ProgressGranularity.month);
      port.fail = true;
      await tester.tap(find.text('Semanal'));
      await tester.pumpAndSettle();
      expect(
        find.text('Tu suscripción no permite consultar este periodo.'),
        findsOneWidget,
      );
      expect(find.byType(GymProgressChart), findsNothing);
    },
  );
}

class _PerformancePort implements SessionPerformanceCommandPort {
  SessionPerformance? saved;
  bool fail = false;
  @override
  Future<void> recordPerformance(SessionPerformance performance) async {
    if (fail) throw const ProgressException(ProgressError.unavailable);
    saved = performance;
  }
}

class _QueryPort implements WorkoutProgressQueryPort {
  ProgressRequest? lastRequest;
  bool fail = false;
  @override
  Future<WorkoutProgress> getProgress(ProgressRequest request) async {
    lastRequest = request;
    if (fail) throw const ProgressException(ProgressError.historyNotAllowed);
    return WorkoutProgress(
      from: request.from,
      to: request.to,
      historyMonths: 1,
      earliestDate: request.from,
      points: [
        ProgressPoint(
          date: request.to,
          completedSets: 3,
          repetitions: 30,
          maxWeightKg: 20,
          volumeKg: 600,
          sessions: 1,
          trainingDays: 1,
          unrecordedSessions: 0,
        ),
      ],
    );
  }
}

class _GraphQlClient implements GraphQlClient {
  Map<String, dynamic> variables = {};
  @override
  Future<Map<String, dynamic>> execute({
    required String document,
    Map<String, dynamic> variables = const {},
    String? accessToken,
  }) async {
    this.variables = variables;
    expect(accessToken, 'test-token');
    return {
      'myWorkoutProgress': {
        'from': '2026-10-01',
        'to': '2026-10-20',
        'earliestDate': '2026-09-20',
        'historyMonths': 1,
        'points': [
          {
            'date': '2026-10-19',
            'completedSets': 2,
            'repetitions': 20,
            'maxWeightKg': null,
            'volumeKg': 0,
            'sessions': 1,
            'trainingDays': 1,
            'unrecordedSessions': 0,
          },
        ],
      },
    };
  }

  @override
  void close() {}
}
