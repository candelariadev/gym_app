import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/features/workout/application/workout_session_store.dart';
import 'package:gym_app/features/workout/domain/workout_session_data.dart';

void main() {
  test('preserva peso reps y series al restaurar la misma sesion', () {
    final store = WorkoutSessionStore(initialSession: _session());

    store.setSeriesWeight(0, 0, '82.5');
    store.setSeriesRepetitions(0, 0, '11');
    store.toggleSeries(0, 0);
    store.completeExercise(0);
    store.restoreOrReplaceSession(_session(status: 'PAUSED'));

    expect(store.weightsFor(0), [82.5, null]);
    expect(store.repetitionsFor(0), [11, null]);
    expect(store.seriesFor(0), [true, false]);
    expect(store.isExerciseCompleted(0), isTrue);
    expect(store.session.status, 'PAUSED');

    store.dispose();
  });

  test('limpia el progreso cuando cambia la sesion', () {
    final store = WorkoutSessionStore(initialSession: _session());
    store.setSeriesWeight(0, 0, '50');

    store.restoreOrReplaceSession(_session(sessionId: 'session-2'));

    expect(store.weightsFor(0), [null, null]);
    expect(store.repetitionsFor(0), [null, null]);
    expect(store.seriesFor(0), [false, false]);

    store.dispose();
  });
}

WorkoutSessionData _session({
  String sessionId = 'session-1',
  String status = 'IN_PROGRESS',
}) {
  return WorkoutSessionData(
    sessionId: sessionId,
    routineName: 'Rutina',
    dayTitle: 'Lunes',
    estimatedDurationMinutes: 30,
    totalSeries: 2,
    status: status,
    exercises: const [
      WorkoutExercise(
        order: 1,
        exerciseId: 'bench-press',
        name: 'Bench press',
        seriesCount: 2,
        repetitionRange: '10 reps',
      ),
    ],
  );
}
