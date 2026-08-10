class WorkoutExercise {
  const WorkoutExercise({
    required this.exerciseId,
    this.sets,
    this.reps,
    this.restSeconds,
    this.notes,
  });

  final String exerciseId;
  final int? sets;
  final int? reps;
  final int? restSeconds;
  final String? notes;
}
