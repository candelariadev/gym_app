import '../domain/workout_session_data.dart';

/// Temporary adapter data until the workout endpoint is connected.
/// Keeping it here prevents transport/demo concerns from leaking into domain.
abstract final class WorkoutDemoData {
  static const session = WorkoutSessionData(
    routineName: 'Rutina Full Body',
    dayTitle: 'Día 2 - Espalda y Bíceps',
    estimatedDurationMinutes: 45,
    totalSeries: 16,
    exercises: [
      WorkoutExercise(
        order: 1,
        name: 'Jalón al pecho',
        focus: 'Espalda',
        seriesCount: 4,
        repetitionRange: '10 - 12',
      ),
      WorkoutExercise(
        order: 2,
        name: 'Remo con barra',
        focus: 'Espalda',
        seriesCount: 4,
        repetitionRange: '6 - 8',
      ),
      WorkoutExercise(
        order: 3,
        name: 'Dominadas asistidas',
        focus: 'Espalda',
        seriesCount: 3,
        repetitionRange: '8 - 10',
      ),
      WorkoutExercise(
        order: 4,
        name: 'Curl de bíceps',
        focus: 'Bíceps',
        seriesCount: 3,
        repetitionRange: '10 - 12',
      ),
    ],
  );
}
