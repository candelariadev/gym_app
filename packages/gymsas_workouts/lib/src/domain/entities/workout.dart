import 'workout_day_plan.dart';

class Workout {
  const Workout({
    required this.routineId,
    required this.userId,
    required this.name,
    required this.status,
    this.startDate,
    this.endDate,
    this.durationWeeks,
    this.isCurrentMonthPlan,
    this.notes,
    this.days,
  });

  final String routineId;
  final String userId;
  final String name;
  final String status;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? durationWeeks;
  final bool? isCurrentMonthPlan;
  final String? notes;
  final List<WorkoutDayPlan>? days;
}
