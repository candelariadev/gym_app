import '../domain/entities/workout_session.dart';
import '../domain/ports/workout_repository.dart';

class FinishWorkoutSessionUseCase {
  const FinishWorkoutSessionUseCase(this._repository);

  final WorkoutRepository _repository;

  Future<WorkoutSession> call(String sessionId) {
    if (sessionId.trim().isEmpty) {
      throw const FormatException('sessionId required');
    }
    return _repository.finishWorkoutSession(sessionId);
  }
}
