class WorkoutExerciseMetadata {
  const WorkoutExerciseMetadata({
    required this.exerciseId,
    this.displayName,
    this.notes,
    this.imageUrl,
    this.force,
    this.level,
    this.mechanic,
    this.equipment,
    this.category,
    this.primaryMuscles = const [],
    this.secondaryMuscles = const [],
    this.instructions = const [],
  });

  final String exerciseId;
  final String? displayName;
  final String? notes;
  final String? imageUrl;
  final String? force;
  final String? level;
  final String? mechanic;
  final String? equipment;
  final String? category;
  final List<String> primaryMuscles;
  final List<String> secondaryMuscles;
  final List<String> instructions;
}
