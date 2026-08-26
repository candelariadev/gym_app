import 'workout_day_plan.dart';

class AssignWorkoutCommand {
  const AssignWorkoutCommand({
    required this.userId,
    required this.name,
    required this.startDate,
    required this.durationWeeks,
    required this.days,
    this.notes,
  });

  final String userId;
  final String name;
  final DateTime startDate;
  final int durationWeeks;
  final List<WorkoutDayPlan> days;
  final String? notes;
}
