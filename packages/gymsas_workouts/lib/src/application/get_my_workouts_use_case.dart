import '../domain/entities/workout.dart';
import '../domain/ports/workout_repository.dart';

class GetMyWorkoutsUseCase {
  const GetMyWorkoutsUseCase(this._repository);

  final WorkoutRepository _repository;

  Future<List<Workout>> call({bool? activeOnly = true}) {
    return _repository.getMyWorkouts(activeOnly: activeOnly);
  }
}
