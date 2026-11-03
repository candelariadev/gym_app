import '../entities/workout.dart';

abstract interface class ConfirmedWorkoutCachePort {
  String? get currentScope;
  Future<void> cacheConfirmedWorkout(
    Workout workout, {
    required String expectedScope,
  });
}
