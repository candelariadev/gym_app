import '../domain/entities/workout.dart';
import '../domain/ports/workout_repository.dart';
import '../domain/workout_error.dart';
import '../domain/ports/confirmed_workout_cache_port.dart';

// Este caso de uso se compone con el repositorio remoto, sin fallback de caché.
class GetConfirmedWorkoutUseCase {
  const GetConfirmedWorkoutUseCase(
    this._remote, {
    ConfirmedWorkoutCachePort? cache,
  }) : _cache = cache;
  final WorkoutRepository _remote;
  final ConfirmedWorkoutCachePort? _cache;
  Future<Workout> call(String routineId) async {
    if (routineId.isEmpty) {
      throw const WorkoutException(WorkoutErrorCode.invalidInput);
    }
    final scope = _cache?.currentScope;
    final routines = await _remote.getMyWorkouts(activeOnly: true);
    for (final routine in routines) {
      if (routine.routineId == routineId && routine.status == 'ACTIVE') {
        if (_cache != null) {
          if (scope == null || scope != _cache.currentScope) {
            throw const WorkoutException(WorkoutErrorCode.unauthorized);
          }
          await _cache.cacheConfirmedWorkout(routine, expectedScope: scope);
        }
        return routine;
      }
    }
    throw const WorkoutException(WorkoutErrorCode.forbidden);
  }
}
