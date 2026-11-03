import '../entities/workout_progress.dart';
import '../entities/session_performance.dart';

abstract interface class WorkoutProgressQueryPort {
  Future<WorkoutProgress> getProgress(ProgressRequest request);
}

abstract interface class SessionPerformanceCommandPort {
  Future<void> recordPerformance(SessionPerformance performance);
}
