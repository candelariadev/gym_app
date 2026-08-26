import 'package:gymsas_workouts/gymsas_workouts.dart';
import 'package:test/test.dart';

void main() {
  test('envía una rutina semanal completa al puerto de salida', () async {
    final repository = _RecordingRepository();
    final useCase = AssignWorkoutUseCase(repository);
    final command = _validCommand();

    final result = await useCase(command);

    expect(repository.received, same(command));
    expect(result.routineId, 'routine-1');
  });

  test('rechaza un día con menos de tres ejercicios', () async {
    final repository = _RecordingRepository();
    final invalid = AssignWorkoutCommand(
      userId: 'client_user',
      name: 'Fuerza',
      startDate: DateTime(2026, 8, 12),
      durationWeeks: 8,
      days: const [
        WorkoutDayPlan(
          day: WorkoutDay.monday,
          exercises: [
            WorkoutExercise(
              exerciseId: 'bench-press',
              name: 'Press de banca',
              sets: 4,
              reps: 8,
              restSeconds: 90,
            ),
          ],
        ),
      ],
    );

    expect(
      () => AssignWorkoutUseCase(repository)(invalid),
      throwsA(
        isA<WorkoutException>().having(
          (error) => error.code,
          'code',
          WorkoutErrorCode.invalidInput,
        ),
      ),
    );
    expect(repository.received, isNull);
  });
}

AssignWorkoutCommand _validCommand() => AssignWorkoutCommand(
  userId: 'client_user',
  name: 'Fuerza',
  startDate: DateTime(2026, 8, 12),
  durationWeeks: 8,
  days: const [
    WorkoutDayPlan(
      day: WorkoutDay.monday,
      exercises: [
        WorkoutExercise(
          exerciseId: 'bench-press',
          name: 'Press de banca',
          sets: 4,
          reps: 8,
          restSeconds: 90,
        ),
        WorkoutExercise(
          exerciseId: 'incline-press',
          name: 'Press inclinado',
          sets: 3,
          reps: 10,
          restSeconds: 60,
        ),
        WorkoutExercise(
          exerciseId: 'chest-fly',
          name: 'Aperturas',
          sets: 3,
          reps: 12,
          restSeconds: 45,
        ),
      ],
    ),
  ],
);

class _RecordingRepository implements WorkoutRepository {
  AssignWorkoutCommand? received;

  @override
  Future<Workout> assign(AssignWorkoutCommand command) async {
    received = command;
    return Workout(
      routineId: 'routine-1',
      userId: command.userId,
      name: command.name,
      status: 'ACTIVE',
    );
  }

  @override
  Future<List<Workout>> getMyWorkouts({bool? activeOnly}) async => const [];

  @override
  Future<List<WorkoutSession>> getMyWorkoutSessions({bool? activeOnly}) async =>
      const [];

  @override
  Future<WorkoutSession> startWorkoutSession(StartWorkoutSessionCommand command) {
    throw UnimplementedError();
  }

  @override
  Future<WorkoutSession> pauseWorkoutSession(String sessionId) {
    throw UnimplementedError();
  }

  @override
  Future<WorkoutSession> finishWorkoutSession(String sessionId) {
    throw UnimplementedError();
  }
}
