import 'workout_day_plan.dart';

class AssignedWorkout {
  const AssignedWorkout({
    required this.routineId,
    required this.ownerId,
    required this.callerId,
    required this.userId,
    required this.name,
    required this.status,
    required this.days,
    this.startDate,
    this.durationWeeks,
    this.notes,
    this.createdAt,
  });

  final String routineId;
  final String ownerId;
  final String callerId;
  final String userId;
  final String name;
  final List<WorkoutDayPlan> days;
  final DateTime? startDate;
  final int? durationWeeks;
  final String? notes;
  final String status;
  final DateTime? createdAt;

  int get totalExercises =>
      days.fold(0, (total, day) => total + day.exercises.length);
}
