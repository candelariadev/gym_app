import 'package:gymsas_api_client/gymsas_api_client.dart';

import '../../domain/entities/assign_workout_command.dart';
import '../../domain/entities/start_workout_session_command.dart';
import '../../domain/entities/workout.dart';
import '../../domain/entities/workout_day.dart';
import '../../domain/entities/workout_day_plan.dart';
import '../../domain/entities/workout_exercise.dart';
import '../../domain/ports/workout_repository.dart';
import '../../domain/entities/workout_session.dart';
import '../../domain/entities/workout_session_exercise.dart';
import '../../domain/workout_error.dart';
import '../datasources/workout_graphql_data_source.dart';
import '../mappers/workout_error_mapper.dart';

class WorkoutRepositoryImpl implements WorkoutRepository {
  const WorkoutRepositoryImpl({
    required WorkoutGraphQlDataSource dataSource,
    required String? Function() accessTokenProvider,
    required WorkoutErrorMapper errorMapper,
    required ApiTrace trace,
  }) : _dataSource = dataSource,
       _accessTokenProvider = accessTokenProvider,
       _errorMapper = errorMapper,
       _trace = trace;

  final WorkoutGraphQlDataSource _dataSource;
  final String? Function() _accessTokenProvider;
  final WorkoutErrorMapper _errorMapper;
  final ApiTrace _trace;

  static const _defaultDayTime = 'MONDAY';

  @override
  Future<Workout> assign(AssignWorkoutCommand command) async {
    _trace.record('workout_assignment_started', {
      'user_id': command.userId,
      'days': command.days.length,
      'exercises': command.days.fold<int>(
        0,
        (sum, day) => sum + day.exercises.length,
      ),
    });
    try {
      final token = _accessTokenProvider();
      if (token == null || token.isEmpty) {
        throw const WorkoutException(WorkoutErrorCode.unauthorized);
      }
      final raw = await _dataSource.assign(
        command: command,
        accessToken: token,
      );
      final workout = Workout(
        routineId: raw['routineId']?.toString() ?? '',
        userId: raw['userId']?.toString() ?? '',
        name: raw['name']?.toString() ?? '',
        status: raw['status']?.toString() ?? '',
      );
      if (workout.routineId.isEmpty || workout.userId.isEmpty) {
        throw const FormatException('workout');
      }
      _trace.record('workout_assignment_completed', {
        'user_id': command.userId,
        'routine_id': workout.routineId,
      });
      return workout;
    } on Object catch (error) {
      final mapped = _errorMapper.from(error);
      _trace.record('workout_assignment_failed', {
        'user_id': command.userId,
        'error_code': mapped.code.name,
        'error': mapped.message,
      });
      throw mapped;
    }
  }

  @override
  Future<List<Workout>> getMyWorkouts({bool? activeOnly}) async {
    _trace.record('workout_list_started', {
      'active_only': activeOnly ?? true,
    });
    try {
      final token = _accessTokenProvider();
      if (token == null || token.isEmpty) {
        throw const WorkoutException(WorkoutErrorCode.unauthorized);
      }
      final raws = await _dataSource.workouts(
        accessToken: token,
        activeOnly: activeOnly ?? true,
      );
      final workouts = raws
          .map(_readWorkout)
          .whereType<Workout>()
          .toList(growable: false);
      _trace.record('workout_list_completed', {
        'count': workouts.length,
      });
      return workouts;
    } on Object catch (error) {
      final mapped = _errorMapper.from(error);
      _trace.record('workout_list_failed', {
        'error_code': mapped.code.name,
      });
      throw mapped;
    }
  }

  @override
  Future<List<WorkoutSession>> getMyWorkoutSessions({bool? activeOnly}) async {
    _trace.record('workout_session_list_started', {
      'active_only': activeOnly ?? true,
    });
    try {
      final token = _accessTokenProvider();
      if (token == null || token.isEmpty) {
        throw const WorkoutException(WorkoutErrorCode.unauthorized);
      }
      final raws = await _dataSource.sessions(
        accessToken: token,
        activeOnly: activeOnly ?? true,
      );
      final sessions = raws
          .map(_readWorkoutSession)
          .whereType<WorkoutSession>()
          .toList(growable: false);
      _trace.record('workout_session_list_completed', {
        'count': sessions.length,
      });
      return sessions;
    } on Object catch (error) {
      final mapped = _errorMapper.from(error);
      _trace.record('workout_session_list_failed', {
        'error_code': mapped.code.name,
      });
      throw mapped;
    }
  }

  @override
  Future<WorkoutSession> startWorkoutSession(StartWorkoutSessionCommand command) async {
    final scheduledDay = command.scheduledDay.trim().toUpperCase();
    final normalizedCommand = StartWorkoutSessionCommand(
      routineId: command.routineId.trim(),
      scheduledDay: scheduledDay,
      userId: command.userId?.trim(),
    );
    _trace.record('workout_session_start_requested', {
      'routine_id': normalizedCommand.routineId,
      'scheduled_day': normalizedCommand.scheduledDay,
      'user_id': normalizedCommand.userId ?? '',
    });
    try {
      final token = _accessTokenProvider();
      if (token == null || token.isEmpty) {
        throw const WorkoutException(WorkoutErrorCode.unauthorized);
      }
      final raw = await _dataSource.startSession(
        accessToken: token,
        command: normalizedCommand,
      );
      final session = _readWorkoutSession(raw);
      if (session == null) {
        throw const WorkoutException(WorkoutErrorCode.invalidResponse);
      }
      _trace.record('workout_session_start_completed', {
        'session_id': session.id,
      });
      return session;
    } on Object catch (error) {
      final mapped = _errorMapper.from(error);
      _trace.record('workout_session_start_failed', {
        'routine_id': normalizedCommand.routineId,
        'scheduled_day': scheduledDay,
        'error_code': mapped.code.name,
      });
      throw mapped;
    }
  }

  @override
  Future<WorkoutSession> pauseWorkoutSession(String sessionId) async {
    final normalizedId = sessionId.trim();
    if (normalizedId.isEmpty) {
      throw const WorkoutException(WorkoutErrorCode.invalidInput);
    }
    _trace.record('workout_session_pause_requested', {'session_id': normalizedId});
    try {
      final token = _accessTokenProvider();
      if (token == null || token.isEmpty) {
        throw const WorkoutException(WorkoutErrorCode.unauthorized);
      }
      final raw = await _dataSource.pauseSession(
        accessToken: token,
        sessionId: normalizedId,
      );
      final session = _readWorkoutSession(raw);
      if (session == null) {
        throw const WorkoutException(WorkoutErrorCode.invalidResponse);
      }
      _trace.record('workout_session_pause_completed', {'session_id': normalizedId});
      return session;
    } on Object catch (error) {
      final mapped = _errorMapper.from(error);
      _trace.record('workout_session_pause_failed', {
        'session_id': normalizedId,
        'error_code': mapped.code.name,
      });
      throw mapped;
    }
  }

  @override
  Future<WorkoutSession> finishWorkoutSession(String sessionId) async {
    final normalizedId = sessionId.trim();
    if (normalizedId.isEmpty) {
      throw const WorkoutException(WorkoutErrorCode.invalidInput);
    }
    _trace.record('workout_session_finish_requested', {'session_id': normalizedId});
    try {
      final token = _accessTokenProvider();
      if (token == null || token.isEmpty) {
        throw const WorkoutException(WorkoutErrorCode.unauthorized);
      }
      final raw = await _dataSource.finishSession(
        accessToken: token,
        sessionId: normalizedId,
      );
      final session = _readWorkoutSession(raw);
      if (session == null) {
        throw const WorkoutException(WorkoutErrorCode.invalidResponse);
      }
      _trace.record('workout_session_finish_completed', {
        'session_id': normalizedId,
      });
      return session;
    } on Object catch (error) {
      final mapped = _errorMapper.from(error);
      _trace.record('workout_session_finish_failed', {
        'session_id': normalizedId,
        'error_code': mapped.code.name,
      });
      throw mapped;
    }
  }

  Workout? _readWorkout(Map<String, dynamic> raw) {
    final routineId = _readString(raw['routineId']);
    final userId = _readString(raw['userId']);
    final name = _readString(raw['name']);
    final status = _readString(raw['status']);
    if (routineId == null || userId == null || name == null || status == null) {
      return null;
    }
    final startDate = _toDate(raw['startDate']);
    final endDate = _toDate(raw['endDate']);
    final durationWeeks = _readInt(raw['durationWeeks']);
    final notes = raw['notes'] is String ? (raw['notes'] as String).trim() : null;
    final isCurrentMonthPlan = _readBool(raw['isCurrentMonthPlan']);
    final days = _readWorkoutDays(raw['days']);
    return Workout(
      routineId: routineId,
      userId: userId,
      name: name,
      status: status,
      startDate: startDate,
      endDate: endDate,
      durationWeeks: durationWeeks,
      isCurrentMonthPlan: isCurrentMonthPlan,
      notes: notes?.isEmpty == true ? null : notes,
      days: days,
    );
  }

  List<WorkoutDayPlan>? _readWorkoutDays(Object? rawDays) {
    if (rawDays is! List) {
      return null;
    }
    final days = <WorkoutDayPlan>[];
    for (final day in rawDays) {
      if (day is! Map<String, dynamic>) {
        continue;
      }
      final dayParsed = WorkoutDay.fromApiValue(_readString(day['day']));
      if (dayParsed == null) {
        continue;
      }
      final exercisesRaw = day['exercises'];
      final exercises = <WorkoutExercise>[];
      if (exercisesRaw is List) {
        for (final entry in exercisesRaw) {
          if (entry is! Map<String, dynamic>) continue;
          final exerciseId = _readString(entry['exerciseId']);
          if (exerciseId == null) continue;
          final sets = _readInt(entry['sets']);
          final reps = _readInt(entry['reps']);
          final restSeconds = _readInt(entry['restSeconds']);
          if (sets == null || reps == null || restSeconds == null) {
            continue;
          }
          final name = _readString(entry['name']) ??
              _readString(entry['exerciseName']) ??
              exerciseId;
          exercises.add(
            WorkoutExercise(
              exerciseId: exerciseId,
              name: name,
              sets: sets,
              reps: reps,
              restSeconds: restSeconds,
              notes: entry['notes'] is String ? entry['notes'] as String : null,
            ),
          );
        }
      }
      days.add(WorkoutDayPlan(day: dayParsed, exercises: exercises));
    }
    return days;
  }

  WorkoutSession? _readWorkoutSession(Map<String, dynamic> raw) {
    final id = _readString(raw['id']);
    final routineId = _readString(raw['routineId']);
    final userId = _readString(raw['userId']);
    final status = _readString(raw['status']);
    if (id == null || routineId == null || userId == null || status == null) {
      return null;
    }
    final scheduledDay = _readString(raw['scheduledDay']);
    final ownerId = _readString(raw['ownerId']);
    final notes = raw['notes'] is String ? raw['notes'] as String : null;
    final totalDurationSeconds = _readInt(raw['totalDurationSeconds']);
    final startedAt = _toDateTime(raw['startedAt']);
    final completedAt = _toDateTime(raw['completedAt']);
    final exercises = _readWorkoutSessionExercises(raw['exercises']);
    return WorkoutSession(
      id: id,
      ownerId: ownerId,
      routineId: routineId,
      scheduledDay: scheduledDay ?? _defaultDayTime,
      userId: userId,
      status: status,
      notes: notes?.isEmpty == true ? null : notes,
      totalDurationSeconds: totalDurationSeconds,
      startedAt: startedAt,
      completedAt: completedAt,
      exercises: exercises,
    );
  }

  List<WorkoutSessionExercise> _readWorkoutSessionExercises(Object? raw) {
    if (raw is! List) return const [];
    final out = <WorkoutSessionExercise>[];
    for (final rawExercise in raw) {
      if (rawExercise is! Map<String, dynamic>) continue;
      final exerciseId = _readString(rawExercise['exerciseId']);
      if (exerciseId == null) continue;
      out.add(
        WorkoutSessionExercise(
          exerciseId: exerciseId,
          plannedSets: _readInt(rawExercise['plannedSets']),
          plannedReps: _readInt(rawExercise['plannedReps']),
          plannedRestSeconds: _readInt(rawExercise['plannedRestSeconds']),
        ),
      );
    }
    return out;
  }

  DateTime? _toDate(Object? raw) {
    final date = raw?.toString();
    if (date == null || date.isEmpty) return null;
    return DateTime.tryParse(date);
  }

  DateTime? _toDateTime(Object? raw) {
    final date = raw?.toString();
    if (date == null || date.isEmpty) return null;
    return DateTime.tryParse(date);
  }

  String? _readString(Object? raw) {
    if (raw is String && raw.trim().isNotEmpty) return raw.trim();
    return null;
  }

  int? _readInt(Object? raw) {
    return raw is int
        ? raw
        : raw is num
              ? raw.toInt()
              : int.tryParse(raw?.toString() ?? '');
  }

  bool? _readBool(Object? raw) {
    if (raw is bool) return raw;
    if (raw is String) {
      final normalized = raw.trim().toLowerCase();
      if (normalized == 'true') return true;
      if (normalized == 'false') return false;
    }
    return null;
  }
}
