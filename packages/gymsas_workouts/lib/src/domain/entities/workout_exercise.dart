class WorkoutExercise {
  const WorkoutExercise({
    required this.exerciseId,
    required this.name,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    this.notes,
  });

  final String exerciseId;
  final String name;
  final int sets;
  final int reps;
  final int restSeconds;
  final String? notes;

  WorkoutExercise copyWith({
    int? sets,
    int? reps,
    int? restSeconds,
    String? notes,
  }) => WorkoutExercise(
    exerciseId: exerciseId,
    name: name,
    sets: sets ?? this.sets,
    reps: reps ?? this.reps,
    restSeconds: restSeconds ?? this.restSeconds,
    notes: notes ?? this.notes,
  );
}
