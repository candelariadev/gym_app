import 'package:gymsas_api_client/gymsas_api_client.dart';

import '../../domain/entities/assign_workout_command.dart';
import '../../domain/entities/start_workout_session_command.dart';

class WorkoutGraphQlDataSource {
  const WorkoutGraphQlDataSource(this._client);

  static const _queryWorkoutsDocument = r'''
    query MyWorkouts($activeOnly: Boolean) {
      myWorkouts(activeOnly: $activeOnly) {
        routineId
        userId
        name
        status
        startDate
        endDate
        durationWeeks
        notes
        isCurrentMonthPlan
        days {
          day
          exercises {
            exerciseId
            sets
            reps
            restSeconds
            notes
          }
        }
      }
    }
  ''';

  static const _querySessionsDocument = r'''
    query MyWorkoutSessions($activeOnly: Boolean) {
      myWorkoutSessions(activeOnly: $activeOnly) {
        id
        ownerId
        routineId
        scheduledDay
        userId
        status
        notes
        totalDurationSeconds
        startedAt
        completedAt
        exercises {
          exerciseId
          plannedSets
          plannedReps
          plannedRestSeconds
        }
      }
    }
  ''';

  static const _startSessionDocument = r'''
    mutation StartWorkoutSession($input: StartWorkoutSessionInput!) {
      startWorkoutSession(input: $input) {
        id
        ownerId
        routineId
        scheduledDay
        userId
        status
        notes
        totalDurationSeconds
        startedAt
        completedAt
        exercises {
          exerciseId
          plannedSets
          plannedReps
          plannedRestSeconds
        }
      }
    }
  ''';

  static const _pauseSessionDocument = r'''
    mutation PauseWorkoutSession($sessionId: ID!) {
      pauseWorkoutSession(sessionId: $sessionId) {
        id
        ownerId
        routineId
        scheduledDay
        userId
        status
        notes
        totalDurationSeconds
        startedAt
        completedAt
      }
    }
  ''';

  static const _finishSessionDocument = r'''
    mutation FinishWorkoutSession($sessionId: ID!) {
      finishWorkoutSession(sessionId: $sessionId) {
        id
        ownerId
        routineId
        scheduledDay
        userId
        status
        notes
        totalDurationSeconds
        startedAt
        completedAt
      }
    }
  ''';

  static const _assignDocument = r'''
    mutation AssignWorkout($input: AssignWorkoutInput!) {
      assignWorkout(input: $input) {
        routineId
        userId
        name
        status
      }
    }
  ''';

  final GraphQlClient _client;

  Future<Map<String, dynamic>> assign({
    required AssignWorkoutCommand command,
    required String accessToken,
  }) async {
    final data = await _client.execute(
      document: _assignDocument,
      accessToken: accessToken,
      variables: {'input': _input(command)},
    );
    final raw = data['assignWorkout'];
    if (raw is! Map<String, dynamic>) {
      throw const FormatException('assignWorkout');
    }
    return raw;
  }

  Future<List<Map<String, dynamic>>> workouts({
    required String accessToken,
    bool activeOnly = true,
  }) async {
    final data = await _client.execute(
      document: _queryWorkoutsDocument,
      accessToken: accessToken,
      variables: {'activeOnly': activeOnly},
    );
    final raw = data['myWorkouts'];
    if (raw is! List) {
      throw const FormatException('myWorkouts');
    }
    return raw
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);
  }

  Future<List<Map<String, dynamic>>> sessions({
    required String accessToken,
    bool activeOnly = true,
  }) async {
    final data = await _client.execute(
      document: _querySessionsDocument,
      accessToken: accessToken,
      variables: {'activeOnly': activeOnly},
    );
    final raw = data['myWorkoutSessions'];
    if (raw is! List) {
      throw const FormatException('myWorkoutSessions');
    }
    return raw
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> startSession({
    required StartWorkoutSessionCommand command,
    required String accessToken,
  }) async {
    final data = await _client.execute(
      document: _startSessionDocument,
      accessToken: accessToken,
      variables: {'input': _startInput(command)},
    );
    final raw = data['startWorkoutSession'];
    if (raw is! Map<String, dynamic>) {
      throw const FormatException('startWorkoutSession');
    }
    return raw;
  }

  Future<Map<String, dynamic>> pauseSession({
    required String sessionId,
    required String accessToken,
  }) async {
    final data = await _client.execute(
      document: _pauseSessionDocument,
      accessToken: accessToken,
      variables: {'sessionId': sessionId},
    );
    final raw = data['pauseWorkoutSession'];
    if (raw is! Map<String, dynamic>) {
      throw const FormatException('pauseWorkoutSession');
    }
    return raw;
  }

  Future<Map<String, dynamic>> finishSession({
    required String sessionId,
    required String accessToken,
  }) async {
    final data = await _client.execute(
      document: _finishSessionDocument,
      accessToken: accessToken,
      variables: {'sessionId': sessionId},
    );
    final raw = data['finishWorkoutSession'];
    if (raw is! Map<String, dynamic>) {
      throw const FormatException('finishWorkoutSession');
    }
    return raw;
  }

  Map<String, dynamic> _input(AssignWorkoutCommand command) => {
    'userId': command.userId,
    'name': command.name.trim(),
    'startDate': _date(command.startDate),
    'durationWeeks': command.durationWeeks,
    'days': command.days
        .map(
          (day) => {
            'day': day.day.apiValue,
            'exercises': day.exercises
                .map(
                  (exercise) => {
                    'exerciseId': exercise.exerciseId,
                    'sets': exercise.sets,
                    'reps': exercise.reps,
                    'restSeconds': exercise.restSeconds,
                    'notes': exercise.notes,
                  },
                )
                .toList(growable: false),
          },
        )
        .toList(growable: false),
    'notes': command.notes,
  };

  Map<String, dynamic> _startInput(StartWorkoutSessionCommand command) => {
    'routineId': command.routineId,
    'scheduledDay': command.scheduledDay,
    'userId': command.userId,
  };

  String _date(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
