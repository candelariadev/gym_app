import '../domain/entities/assign_workout_command.dart';
import '../domain/entities/workout.dart';
import '../domain/ports/workout_repository.dart';
import '../domain/workout_error.dart';

class AssignWorkoutUseCase {
  const AssignWorkoutUseCase(this._repository);

  final WorkoutRepository _repository;

  Future<Workout> call(AssignWorkoutCommand command) {
    _validate(command);
    return _repository.assign(command);
  }

  void _validate(AssignWorkoutCommand command) {
    if (command.userId.trim().isEmpty ||
        command.name.trim().isEmpty ||
        command.name.length > 120 ||
        command.durationWeeks < 4 ||
        command.durationWeeks > 52 ||
        command.days.isEmpty ||
        command.days.length > 7) {
      throw const WorkoutException(WorkoutErrorCode.invalidInput);
    }
    final scheduledDays = <Object>{};
    for (final day in command.days) {
      if (!scheduledDays.add(day.day) ||
          day.exercises.length < 3 ||
          day.exercises.length > 30) {
        throw const WorkoutException(WorkoutErrorCode.invalidInput);
      }
      final exerciseIds = <String>{};
      for (final exercise in day.exercises) {
        if (exercise.exerciseId.trim().isEmpty ||
            !exerciseIds.add(exercise.exerciseId) ||
            exercise.sets < 1 ||
            exercise.sets > 100 ||
            exercise.reps < 1 ||
            exercise.reps > 1000 ||
            exercise.restSeconds < 1 ||
            exercise.restSeconds > 3600) {
          throw const WorkoutException(WorkoutErrorCode.invalidInput);
        }
      }
    }
  }
}
