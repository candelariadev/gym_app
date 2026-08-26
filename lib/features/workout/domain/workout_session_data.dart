import 'workout_exercise_metadata.dart';

class WorkoutExercise {
  const WorkoutExercise({
    required this.order,
    required this.name,
    this.focus,
    required this.seriesCount,
    required this.repetitionRange,
    this.isCompleted = false,
    this.imageUrl,
    this.exerciseId,
    this.metadata,
  });

  final int order;
  final String name;
  final String? focus;
  final int seriesCount;
  final String repetitionRange;
  final bool isCompleted;
  final String? imageUrl;
  final String? exerciseId;
  final WorkoutExerciseMetadata? metadata;
}

class WorkoutSessionData {
  const WorkoutSessionData.empty()
    : this(
        routineName: '',
        dayTitle: null,
        estimatedDurationMinutes: 0,
        totalSeries: 0,
        exercises: const [],
        sessionId: '',
        status: '',
      );

  const WorkoutSessionData({
    this.sessionId = '',
    required this.routineName,
    required this.dayTitle,
    required this.estimatedDurationMinutes,
    required this.totalSeries,
    required this.exercises,
    this.status = '',
    this.scheduledDay,
    this.startedAt,
    this.completedAt,
    this.totalDurationSeconds,
  });

  final String sessionId;
  final String routineName;
  final String? dayTitle;
  final int estimatedDurationMinutes;
  final int totalSeries;
  final List<WorkoutExercise> exercises;
  final String status;
  final String? scheduledDay;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final int? totalDurationSeconds;

  int get totalExercises => exercises.length;

  int get completedExercises =>
      exercises.where((exercise) => exercise.isCompleted).length;

  WorkoutExercise? get currentExercise {
    final pending = exercises.where((exercise) => !exercise.isCompleted);
    return pending.isEmpty ? null : pending.first;
  }
}

class WorkoutExerciseArgs {
  const WorkoutExerciseArgs({
    required this.session,
    required this.exerciseIndex,
  });

  final WorkoutSessionData session;
  final int exerciseIndex;
}
