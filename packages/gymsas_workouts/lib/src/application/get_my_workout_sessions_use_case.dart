import '../domain/entities/workout_session.dart';
import '../domain/ports/workout_repository.dart';

class GetMyWorkoutSessionsUseCase {
  const GetMyWorkoutSessionsUseCase(this._repository);

  final WorkoutRepository _repository;

  Future<List<WorkoutSession>> call({bool? activeOnly = true}) {
    return _repository.getMyWorkoutSessions(activeOnly: activeOnly);
  }
}
