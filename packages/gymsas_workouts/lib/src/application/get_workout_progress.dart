import '../domain/entities/workout_progress.dart';
import '../domain/ports/workout_progress_repository.dart';

class GetWorkoutProgress {
  const GetWorkoutProgress(this._port);
  final WorkoutProgressQueryPort _port;
  Future<WorkoutProgress> call(ProgressRequest request) =>
      _port.getProgress(request);
}
