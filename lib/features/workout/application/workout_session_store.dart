import 'dart:async';

import 'package:flutter/foundation.dart';

import '../domain/workout_session_data.dart';

class WorkoutSessionStore extends ChangeNotifier {
  static const int restSecondsTotal = 60;

  WorkoutSessionStore({required WorkoutSessionData initialSession})
    : _initialSession = initialSession {
    reset();
  }

  final WorkoutSessionData _initialSession;

  late WorkoutSessionData _session;
  late List<bool> _completedExercises;
  late List<List<bool>> _seriesByExercise;
  Timer? _restTimer;
  int _remainingRestSeconds = 0;
  int? _activeExerciseIndex;

  WorkoutSessionData get session => _session;
  int get remainingRestSeconds => _remainingRestSeconds;
  bool get isRestActive => _remainingRestSeconds > 0;
  int? get activeExerciseIndex => _activeExerciseIndex;

  void reset() {
    _restTimer?.cancel();
    _remainingRestSeconds = 0;
    _activeExerciseIndex = 0;
    _session = _initialSession;
    _completedExercises = _session.exercises
        .map((exercise) => exercise.isCompleted)
        .toList();
    _seriesByExercise = _session.exercises
        .map((exercise) => List<bool>.filled(exercise.seriesCount, false))
        .toList();
    notifyListeners();
  }

  bool isExerciseCompleted(int exerciseIndex) =>
      _completedExercises[exerciseIndex];

  int get completedExercisesCount =>
      _completedExercises.where((completed) => completed).length;

  List<bool> seriesFor(int exerciseIndex) =>
      List<bool>.from(_seriesByExercise[exerciseIndex]);

  void toggleSeries(int exerciseIndex, int seriesIndex) {
    _activeExerciseIndex = exerciseIndex;
    _seriesByExercise[exerciseIndex][seriesIndex] =
        !_seriesByExercise[exerciseIndex][seriesIndex];
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

  void completeExercise(int exerciseIndex) {
    _completedExercises[exerciseIndex] = true;
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
    if (exerciseIndex + 1 >= _session.exercises.length) {
      return null;
    }

    return _session.exercises[exerciseIndex + 1];
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    super.dispose();
  }
}
