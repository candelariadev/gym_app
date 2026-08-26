class WorkoutSessionExercise {
  const WorkoutSessionExercise({
    required this.exerciseId,
    this.plannedSets,
    this.plannedReps,
    this.plannedRestSeconds,
  });

  final String exerciseId;
  final int? plannedSets;
  final int? plannedReps;
  final int? plannedRestSeconds;
}
