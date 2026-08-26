import 'workout_session_exercise.dart';

class WorkoutSession {
  const WorkoutSession({
    required this.id,
    required this.routineId,
    required this.userId,
    required this.status,
    this.ownerId,
    this.scheduledDay,
    this.notes,
    this.totalDurationSeconds,
    this.startedAt,
    this.completedAt,
    this.exercises = const [],
  });

  final String id;
  final String? ownerId;
  final String routineId;
  final String? scheduledDay;
  final String userId;
  final String status;
  final String? notes;
  final int? totalDurationSeconds;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final List<WorkoutSessionExercise> exercises;

  bool get isActive => status == 'IN_PROGRESS' || status == 'PAUSED';
}
