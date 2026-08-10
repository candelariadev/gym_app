class WorkoutExercise {
  const WorkoutExercise({
    required this.order,
    required this.name,
    required this.focus,
    required this.seriesCount,
    required this.repetitionRange,
    this.isCompleted = false,
  });

  final int order;
  final String name;
  final String focus;
  final int seriesCount;
  final String repetitionRange;
  final bool isCompleted;
}

class WorkoutSessionData {
  const WorkoutSessionData({
    required this.routineName,
    required this.dayTitle,
    required this.estimatedDurationMinutes,
    required this.totalSeries,
    required this.exercises,
  });

  final String routineName;
  final String dayTitle;
  final int estimatedDurationMinutes;
  final int totalSeries;
  final List<WorkoutExercise> exercises;

  int get totalExercises => exercises.length;

  int get completedExercises =>
      exercises.where((exercise) => exercise.isCompleted).length;

  WorkoutExercise get currentExercise =>
      exercises.firstWhere((exercise) => !exercise.isCompleted);
}

class WorkoutExerciseArgs {
  const WorkoutExerciseArgs({
    required this.session,
    required this.exerciseIndex,
  });

  final WorkoutSessionData session;
  final int exerciseIndex;
}
