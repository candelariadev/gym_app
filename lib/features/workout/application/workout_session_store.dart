import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:gymsas_workouts/gymsas_workouts.dart'
    show
        RecordWorkoutPerformance,
        SessionPerformance,
        ExercisePerformance,
        WorkoutSet;

import '../domain/workout_session_data.dart';

class WorkoutSessionStore extends ChangeNotifier {
  static const int restSecondsTotal = 60;

  WorkoutSessionStore({
    WorkoutSessionData? initialSession,
    RecordWorkoutPerformance? recordPerformance,
  }) : _recordPerformance = recordPerformance,
       _initialSession = initialSession ?? WorkoutSessionData.empty() {
    reset();
  }

  final WorkoutSessionData _initialSession;
  final RecordWorkoutPerformance? _recordPerformance;
  int _pendingSaves = 0;
  int _generation = 0;
  bool saveFailed = false;
  bool isSaving = false;
  bool _disposed = false;

  Future<void> flushPerformance() async {
    final generation = _generation;
    final record = _recordPerformance;
    if (record == null || _session.sessionId.isEmpty || !hasExercises) return;
    final snapshot = SessionPerformance(
      sessionId: _session.sessionId,
      exercises: [
        for (var i = 0; i < _session.exercises.length; i++)
          if (_session.exercises[i].exerciseId != null)
            ExercisePerformance(
              exerciseId: _session.exercises[i].exerciseId!,
              completed: _completedExercises[i],
              sets: [
                for (var j = 0; j < _seriesByExercise[i].length; j++)
                  WorkoutSet(
                    setNumber: j + 1,
                    weightKg: _weightsByExercise[i][j],
                    reps: _repsByExercise[i][j],
                    restSeconds: _recordedSet(i, j + 1)?.restSeconds,
                    durationSeconds: _recordedSet(i, j + 1)?.durationSeconds,
                    completed: _seriesByExercise[i][j],
                  ),
              ],
            ),
      ],
    );
    isSaving = true;
    _pendingSaves++;
    if (!_disposed) notifyListeners();
    // Invoke now so the repository captures the current account before awaits.
    // Its durable transaction serializes snapshots and coalesces the outbox.
    final next = record(snapshot);
    try {
      await next;
      if (generation == _generation) saveFailed = false;
    } on Object {
      if (generation == _generation) saveFailed = true;
      rethrow;
    } finally {
      if (generation == _generation) {
        _pendingSaves--;
        isSaving = _pendingSaves > 0;
        if (!_disposed) notifyListeners();
      }
    }
  }

  void _scheduleSave() {
    if (_recordPerformance == null) return;
    // Never debounce durable writes: an app termination must not discard the
    // last edit during a timer window. Remote replay is handled separately.
    unawaited(flushPerformance().catchError((Object _) {}));
  }

  WorkoutSet? _recordedSet(int exerciseIndex, int number) {
    for (final set in _session.exercises[exerciseIndex].recordedSets) {
      if (set.setNumber == number) return set;
    }
    return null;
  }

  late WorkoutSessionData _session;
  late List<bool> _completedExercises;
  late List<List<bool>> _seriesByExercise;
  late List<List<double?>> _weightsByExercise;
  late List<List<int?>> _repsByExercise;
  Timer? _restTimer;
  Timer? _sessionTimer;
  int _remainingRestSeconds = 0;
  Duration _elapsedSessionDuration = Duration.zero;
  int? _activeExerciseIndex;

  WorkoutSessionData get session => _session;
  int get remainingRestSeconds => _remainingRestSeconds;
  Duration get elapsedSessionDuration => _elapsedSessionDuration;
  bool get isRestActive => _remainingRestSeconds > 0;
  int? get activeExerciseIndex => _activeExerciseIndex;
  bool get hasExercises => _session.exercises.isNotEmpty;
  bool get hasProgress => _session.totalExercises > 0;
  bool get areAllExercisesCompleted =>
      hasExercises && completedExercisesCount == _session.totalExercises;

  void reset() {
    _generation++;
    _pendingSaves = 0;
    isSaving = false;
    saveFailed = false;
    _restTimer?.cancel();
    _sessionTimer?.cancel();
    _remainingRestSeconds = 0;
    _activeExerciseIndex = null;
    _session = _initialSession;
    _syncFromSession();
    _startSessionTimer();
    notifyListeners();
  }

  void replaceSession(WorkoutSessionData nextSession) {
    _generation++;
    _pendingSaves = 0;
    isSaving = false;
    saveFailed = false;
    _restTimer?.cancel();
    _sessionTimer?.cancel();
    _remainingRestSeconds = 0;
    _activeExerciseIndex = null;
    _session = nextSession;
    _syncFromSession();
    _startSessionTimer();
    notifyListeners();
  }

  void restoreOrReplaceSession(WorkoutSessionData nextSession) {
    if (!_canPreserveProgressFor(nextSession)) {
      replaceSession(nextSession);
      return;
    }

    _session = nextSession;
    _startSessionTimer();
    notifyListeners();
  }

  bool _canPreserveProgressFor(WorkoutSessionData nextSession) {
    if (_session.sessionId.isEmpty ||
        _session.sessionId != nextSession.sessionId) {
      return false;
    }
    if (_session.exercises.length != nextSession.exercises.length) return false;

    for (var index = 0; index < _session.exercises.length; index++) {
      final current = _session.exercises[index];
      final next = nextSession.exercises[index];
      if (current.exerciseId != next.exerciseId ||
          current.seriesCount != next.seriesCount) {
        return false;
      }
    }
    return true;
  }

  void _syncFromSession() {
    _completedExercises = _session.exercises
        .map((exercise) => exercise.isCompleted)
        .toList(growable: false);
    _seriesByExercise = _session.exercises
        .map(
          (exercise) =>
              List<bool>.filled(exercise.seriesCount, false, growable: false),
        )
        .toList(growable: false);
    _weightsByExercise = _session.exercises
        .map((exercise) => List<double?>.filled(exercise.seriesCount, null))
        .toList(growable: false);
    _repsByExercise = _session.exercises
        .map((exercise) => List<int?>.filled(exercise.seriesCount, null))
        .toList(growable: false);
    _activeExerciseIndex = _session.exercises.isEmpty ? null : 0;
    for (var i = 0; i < _session.exercises.length; i++) {
      for (final set in _session.exercises[i].recordedSets) {
        final j = set.setNumber - 1;
        if (j < 0 || j >= _seriesByExercise[i].length) continue;
        _seriesByExercise[i][j] = set.completed;
        _weightsByExercise[i][j] = set.weightKg;
        _repsByExercise[i][j] = set.reps;
      }
      if (_seriesByExercise[i].isNotEmpty &&
          _seriesByExercise[i].every((done) => done)) {
        _completedExercises[i] = true;
      }
    }
  }

  bool isExerciseCompleted(int exerciseIndex) {
    if (exerciseIndex < 0 || exerciseIndex >= _completedExercises.length) {
      return false;
    }
    return _completedExercises[exerciseIndex];
  }

  int get completedExercisesCount =>
      _completedExercises.where((completed) => completed).length;

  List<bool> seriesFor(int exerciseIndex) {
    if (exerciseIndex < 0 || exerciseIndex >= _seriesByExercise.length) {
      return const [];
    }
    return List<bool>.from(_seriesByExercise[exerciseIndex]);
  }

  List<double?> weightsFor(int exerciseIndex) {
    if (exerciseIndex < 0 || exerciseIndex >= _weightsByExercise.length) {
      return const [];
    }
    return List<double?>.from(_weightsByExercise[exerciseIndex]);
  }

  List<int?> repetitionsFor(int exerciseIndex) {
    if (exerciseIndex < 0 || exerciseIndex >= _repsByExercise.length) {
      return const [];
    }
    return List<int?>.from(_repsByExercise[exerciseIndex]);
  }

  WorkoutExercise? exerciseAtOrNull(int exerciseIndex) {
    if (exerciseIndex < 0 || exerciseIndex >= _session.exercises.length) {
      return null;
    }
    return _session.exercises[exerciseIndex];
  }

  void toggleSeries(int exerciseIndex, int seriesIndex) {
    _activeExerciseIndex = exerciseIndex;
    if (exerciseIndex < 0 || exerciseIndex >= _seriesByExercise.length) {
      return;
    }
    final exerciseSeries = _seriesByExercise[exerciseIndex];
    if (seriesIndex < 0 || seriesIndex >= exerciseSeries.length) {
      return;
    }
    _seriesByExercise[exerciseIndex][seriesIndex] =
        !_seriesByExercise[exerciseIndex][seriesIndex];
    if (!_seriesByExercise[exerciseIndex][seriesIndex]) {
      _completedExercises[exerciseIndex] = false;
    }
    _scheduleSave();
    notifyListeners();
  }

  void setSeriesWeight(int exerciseIndex, int seriesIndex, String rawValue) {
    if (exerciseIndex < 0 || exerciseIndex >= _weightsByExercise.length) {
      return;
    }
    final exerciseWeights = _weightsByExercise[exerciseIndex];
    if (seriesIndex < 0 || seriesIndex >= exerciseWeights.length) {
      return;
    }

    final value = rawValue.trim();
    _weightsByExercise[exerciseIndex][seriesIndex] = value.isEmpty
        ? null
        : double.tryParse(value.replaceAll(',', '.'));
    _scheduleSave();
    notifyListeners();
  }

  void setSeriesRepetitions(
    int exerciseIndex,
    int seriesIndex,
    String rawValue,
  ) {
    if (exerciseIndex < 0 || exerciseIndex >= _repsByExercise.length) {
      return;
    }
    final exerciseRepetitions = _repsByExercise[exerciseIndex];
    if (seriesIndex < 0 || seriesIndex >= exerciseRepetitions.length) {
      return;
    }

    final value = rawValue.trim();
    _repsByExercise[exerciseIndex][seriesIndex] = value.isEmpty
        ? null
        : int.tryParse(value);
    _scheduleSave();
    notifyListeners();
  }

  void startRestTimer() {
    _restTimer?.cancel();
    _remainingRestSeconds = restSecondsTotal;
    notifyListeners();

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingRestSeconds <= 1) {
        timer.cancel();
        _remainingRestSeconds = 0;
        notifyListeners();
        return;
      }

      _remainingRestSeconds -= 1;
      notifyListeners();
    });
  }

  void skipRest() {
    _restTimer?.cancel();
    if (_remainingRestSeconds == 0) return;
    _remainingRestSeconds = 0;
    notifyListeners();
  }

  void _startSessionTimer() {
    _sessionTimer?.cancel();
    _updateElapsedSessionDuration();

    if (_session.startedAt == null ||
        _session.completedAt != null ||
        _session.status != 'IN_PROGRESS') {
      return;
    }

    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateElapsedSessionDuration();
      notifyListeners();
    });
  }

  void _updateElapsedSessionDuration() {
    final storedDuration = _session.totalDurationSeconds;
    if (_session.status != 'IN_PROGRESS' && storedDuration != null) {
      _elapsedSessionDuration = Duration(
        seconds: storedDuration < 0 ? 0 : storedDuration,
      );
      return;
    }

    final startedAt = _session.startedAt;
    if (startedAt == null) {
      _elapsedSessionDuration = Duration.zero;
      return;
    }

    final end = _session.completedAt ?? DateTime.now();
    final elapsed = end.difference(startedAt);
    _elapsedSessionDuration = elapsed.isNegative ? Duration.zero : elapsed;
  }

  void completeExercise(int exerciseIndex) {
    if (exerciseIndex < 0 || exerciseIndex >= _completedExercises.length) {
      return;
    }
    _completedExercises[exerciseIndex] = true;
    _scheduleSave();
    if (_activeExerciseIndex == exerciseIndex) {
      _activeExerciseIndex = null;
    }
    notifyListeners();
  }

  bool canOpenExercise(int exerciseIndex) {
    if (!isRestActive) {
      return true;
    }

    return exerciseIndex == _activeExerciseIndex;
  }

  WorkoutExercise exerciseAt(int exerciseIndex) =>
      _session.exercises[exerciseIndex];

  WorkoutExercise? nextExerciseAfter(int exerciseIndex) {
    final nextIndex = exerciseIndex + 1;
    if (nextIndex >= _session.exercises.length) {
      return null;
    }
    return _session.exercises[nextIndex];
  }

  @override
  void dispose() {
    _disposed = true;
    _restTimer?.cancel();
    _sessionTimer?.cancel();
    super.dispose();
  }
}
