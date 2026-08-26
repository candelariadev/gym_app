import 'package:gymsas_api_client/gymsas_api_client.dart';
import 'package:gymsas_workouts/gymsas_workouts.dart';
import 'package:gymsas_workouts/src/infrastructure/datasources/workout_graphql_data_source.dart';
import 'package:test/test.dart';

void main() {
  test('serializa todos los días y la prescripción numérica', () async {
    final client = _RecordingGraphQlClient();
    final dataSource = WorkoutGraphQlDataSource(client);
    final exercises = List.generate(
      3,
      (index) => WorkoutExercise(
        exerciseId: 'exercise-$index',
        name: 'Exercise $index',
        sets: 3,
        reps: 10,
        restSeconds: 60,
      ),
    );

    await dataSource.assign(
      accessToken: 'token',
      command: AssignWorkoutCommand(
        userId: 'client_user',
        name: 'Rutina semanal',
        startDate: DateTime(2026, 8, 12),
        durationWeeks: 8,
        days: [
          WorkoutDayPlan(day: WorkoutDay.monday, exercises: exercises),
          WorkoutDayPlan(day: WorkoutDay.friday, exercises: exercises),
        ],
      ),
    );

    final input = client.variables['input'] as Map<String, dynamic>;
    final days = input['days'] as List<dynamic>;
    expect(days, hasLength(2));
    expect((days.first as Map<String, dynamic>)['day'], 'MONDAY');
    expect((days.last as Map<String, dynamic>)['day'], 'FRIDAY');
    expect(input['startDate'], '2026-08-12');
    final firstExercise =
        ((days.first as Map<String, dynamic>)['exercises'] as List<dynamic>)
                .first
            as Map<String, dynamic>;
    expect(firstExercise['sets'], isA<int>());
    expect(firstExercise['restSeconds'], 60);
  });
}

class _RecordingGraphQlClient implements GraphQlClient {
  Map<String, dynamic> variables = const {};

  @override
  Future<Map<String, dynamic>> execute({
    required String document,
    Map<String, dynamic> variables = const {},
    String? accessToken,
  }) async {
    this.variables = variables;
    return {
      'assignWorkout': {
        'routineId': 'routine-1',
        'userId': 'client_user',
        'name': 'Rutina semanal',
        'status': 'ACTIVE',
      },
    };
  }

  @override
  void close() {}
}
