import 'assigned_trainer.dart';
import 'assigned_workout.dart';

class TrainerClient {
  const TrainerClient({
    required this.id,
    required this.ownerId,
    required this.name,
    this.email,
    required this.goals,
    required this.user,
    required this.assignedTrainers,
    required this.assignedWorkouts,
    required this.status,
    this.birthdate,
    this.gender,
    this.weight,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String ownerId;
  final String name;
  final String? email;
  final DateTime? birthdate;
  final String? gender;
  final double? weight;
  final List<String> goals;
  final String? notes;
  final String user;
  final List<AssignedTrainer> assignedTrainers;
  final List<AssignedWorkout> assignedWorkouts;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get initials {
    final words = name.trim().split(RegExp(r'\s+'));
    return words
        .where((word) => word.isNotEmpty)
        .take(2)
        .map((word) => word[0])
        .join()
        .toUpperCase();
  }
}
