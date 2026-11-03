class WorkoutSet {
  const WorkoutSet({
    required this.setNumber,
    this.weightKg,
    this.reps,
    this.restSeconds,
    this.durationSeconds,
    this.completed = false,
  });
  final int setNumber;
  final double? weightKg;
  final int? reps, restSeconds, durationSeconds;
  final bool completed;
}

class ExercisePerformance {
  const ExercisePerformance({
    required this.exerciseId,
    required this.sets,
    this.completed = false,
  });
  final String exerciseId;
  final List<WorkoutSet> sets;
  final bool completed;
}

class SessionPerformance {
  const SessionPerformance({required this.sessionId, required this.exercises});
  final String sessionId;
  final List<ExercisePerformance> exercises;
}
