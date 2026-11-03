import '../domain/entities/session_performance.dart';
import '../domain/ports/workout_progress_repository.dart';

class RecordWorkoutPerformance {
  const RecordWorkoutPerformance(this._port);
  final SessionPerformanceCommandPort _port;
  Future<void> call(SessionPerformance performance) =>
      _port.recordPerformance(performance);
}
