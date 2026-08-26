import '../domain/entities/start_workout_session_command.dart';
import '../domain/entities/workout_session.dart';
import '../domain/ports/workout_repository.dart';

class StartWorkoutSessionUseCase {
  const StartWorkoutSessionUseCase(this._repository);

  final WorkoutRepository _repository;

  Future<WorkoutSession> call(StartWorkoutSessionCommand command) {
    if (command.routineId.trim().isEmpty) {
      throw const FormatException('Routine id required');
    }
    if (command.scheduledDay.trim().isEmpty) {
      throw const FormatException('Scheduled day required');
    }
    return _repository.startWorkoutSession(command);
  }
}
