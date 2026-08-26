import '../entities/start_workout_session_command.dart';
import '../entities/assign_workout_command.dart';
import '../entities/workout.dart';
import '../entities/workout_session.dart';

abstract interface class WorkoutRepository {
  Future<Workout> assign(AssignWorkoutCommand command);
  Future<List<Workout>> getMyWorkouts({bool? activeOnly});
  Future<List<WorkoutSession>> getMyWorkoutSessions({bool? activeOnly});
  Future<WorkoutSession> startWorkoutSession(StartWorkoutSessionCommand command);
  Future<WorkoutSession> pauseWorkoutSession(String sessionId);
  Future<WorkoutSession> finishWorkoutSession(String sessionId);
}
