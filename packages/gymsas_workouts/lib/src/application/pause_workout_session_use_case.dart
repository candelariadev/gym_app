import '../domain/entities/workout_session.dart';
import '../domain/ports/workout_repository.dart';

class PauseWorkoutSessionUseCase {
  const PauseWorkoutSessionUseCase(this._repository);

  final WorkoutRepository _repository;

  Future<WorkoutSession> call(String sessionId) {
    if (sessionId.trim().isEmpty) {
      throw const FormatException('sessionId required');
    }
    return _repository.pauseWorkoutSession(sessionId);
  }
}
