import 'session_performance.dart';

class WorkoutSessionExercise {
  const WorkoutSessionExercise({
    required this.exerciseId,
    this.plannedSets,
    this.plannedReps,
    this.plannedRestSeconds,
    this.sets = const [],
    this.isCompleted = false,
  });

  final String exerciseId;
  final int? plannedSets;
  final int? plannedReps;
  final int? plannedRestSeconds;
  final List<WorkoutSet> sets;
  final bool isCompleted;
}
