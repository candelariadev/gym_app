import 'workout_day.dart';
import 'workout_exercise.dart';

class WorkoutDayPlan {
  const WorkoutDayPlan({required this.day, required this.exercises});

  final WorkoutDay? day;
  final List<WorkoutExercise> exercises;
}
