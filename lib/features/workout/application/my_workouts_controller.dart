import 'package:flutter/foundation.dart';
import 'package:gymsas_workouts/gymsas_workouts.dart';

import 'workout_exercise_metadata_resolver.dart';
import '../domain/workout_exercise_metadata.dart';

class AdvisedWorkoutItem {
  const AdvisedWorkoutItem({
    required this.workout,
    this.activeSession,
    this.todayPlan,
    this.todayDay,
    this.startDay,
    this.isCurrentMonthPlan,
    required this.canStartRoutine,
    required this.availableDayPlans,
  });

  final Workout workout;
  final WorkoutSession? activeSession;
  final WorkoutDayPlan? todayPlan;
  final WorkoutDay? todayDay;
  final WorkoutDay? startDay;
  final bool? isCurrentMonthPlan;
  final bool canStartRoutine;
  final List<WorkoutDayPlan> availableDayPlans;

  List<WorkoutDay> get availableDays =>
      availableDayPlans.map((plan) => plan.day).toList(growable: false);

  bool get hasActiveSession =>
      activeSession != null && _isActiveStatus(activeSession!.status);

  bool get canContinue {
    return activeSession != null;
  }

  bool get isInProgress =>
      activeSession?.status == WorkoutSessionStatus.inProgress.value;

  bool get isPaused => activeSession?.status == WorkoutSessionStatus.paused.value;

  static bool _isActiveStatus(String rawStatus) {
    return rawStatus == WorkoutSessionStatus.inProgress.value ||
        rawStatus == WorkoutSessionStatus.paused.value;
  }
}

class MyWorkoutsController extends ChangeNotifier {
  MyWorkoutsController({
    required GetMyWorkoutsUseCase getMyWorkouts,
    required GetMyWorkoutSessionsUseCase getMyWorkoutSessions,
    required StartWorkoutSessionUseCase startWorkoutSession,
    required PauseWorkoutSessionUseCase pauseWorkoutSession,
    required FinishWorkoutSessionUseCase finishWorkoutSession,
    required WorkoutExerciseMetadataResolver exerciseMetadataResolver,
    DateTime Function()? nowProvider,
  })  : _getMyWorkouts = getMyWorkouts,
        _getMyWorkoutSessions = getMyWorkoutSessions,
        _startWorkoutSession = startWorkoutSession,
        _pauseWorkoutSession = pauseWorkoutSession,
        _finishWorkoutSession = finishWorkoutSession,
        _exerciseMetadataResolver = exerciseMetadataResolver,
        _nowProvider = nowProvider ?? DateTime.now;

  final GetMyWorkoutsUseCase _getMyWorkouts;
  final GetMyWorkoutSessionsUseCase _getMyWorkoutSessions;
  final StartWorkoutSessionUseCase _startWorkoutSession;
  final PauseWorkoutSessionUseCase _pauseWorkoutSession;
  final FinishWorkoutSessionUseCase _finishWorkoutSession;
  final WorkoutExerciseMetadataResolver _exerciseMetadataResolver;
  final DateTime Function() _nowProvider;

  bool isLoading = false;
  bool isActionRunning = false;

  WorkoutErrorCode? errorCode;
  List<AdvisedWorkoutItem> workouts = const [];
  List<WorkoutSession> sessions = const [];
  int completedWorkoutsCount = 0;
  List<DateTime> completedWorkoutDays = const [];

  Map<String, WorkoutExerciseMetadata> exerciseMetadata = const {};

  final Set<String> _busyRoutineIds = <String>{};

  bool isRoutineBusy(String routineId) => _busyRoutineIds.contains(routineId);

  Future<void> load() async {
    if (isLoading) return;
    final now = _nowProvider();

    isLoading = true;
    errorCode = null;
    _notify();

    try {
      final results = await Future.wait([
        _getMyWorkouts(activeOnly: false),
        _getMyWorkoutSessions(activeOnly: false),
      ]);
      final workouts = results[0] as List<Workout>;
      final sessions = results[1] as List<WorkoutSession>;
      final completedSessions = sessions.where(_isCompletedSession).toList(
        growable: false,
      );
      exerciseMetadata = await _loadExerciseMetadata(workouts: workouts, sessions: sessions);

      this.workouts = _toWorkoutItems(
        workouts,
        sessions,
        now: now,
      );
      this.sessions = sessions;
      completedWorkoutsCount = completedSessions.length;
      completedWorkoutDays = _collectCompletedWorkoutDays(completedSessions);
    } on Object {
      errorCode = const WorkoutException(WorkoutErrorCode.unexpected).code;
    } finally {
      isLoading = false;
      _notify();
    }
  }

  Future<Map<String, WorkoutExerciseMetadata>> _loadExerciseMetadata({
    required List<Workout> workouts,
    required List<WorkoutSession> sessions,
  }) async {
    final exerciseIds = <String>{};

    for (final workout in workouts) {
      for (final day in workout.days ?? const []) {
        for (final exercise in day.exercises) {
          final normalizedId = _normalizedExerciseId(exercise.exerciseId);
          if (normalizedId.isNotEmpty) {
            exerciseIds.add(normalizedId);
          }
        }
      }
    }

    for (final session in sessions) {
      for (final exercise in session.exercises) {
        final normalizedId = _normalizedExerciseId(exercise.exerciseId);
        if (normalizedId.isNotEmpty) {
          exerciseIds.add(normalizedId);
        }
      }
    }

    if (exerciseIds.isEmpty) {
      return const {};
    }

    return _exerciseMetadataResolver.resolve(exerciseIds);
  }

  Future<WorkoutSession?> startRoutine(
    AdvisedWorkoutItem item,
    {
    WorkoutDay? scheduledDay,
  }) async {
    final resolvedDay = scheduledDay ?? item.startDay;
    if (resolvedDay == null || !item.canStartRoutine) return null;
    final routineId = item.workout.routineId;

    final isSupportedDay = item.availableDays.contains(resolvedDay);
    if (!isSupportedDay) {
      return null;
    }

    if (_busyRoutineIds.contains(routineId)) return null;

    _busyRoutineIds.add(routineId);
    isActionRunning = true;
    errorCode = null;
    _notify();

    try {
      final session = await _startWorkoutSession(
        StartWorkoutSessionCommand(
          routineId: routineId,
          scheduledDay: resolvedDay.apiValue,
        ),
      );
      await load();
      return session;
    } on Object catch (error) {
      errorCode = error is WorkoutException
          ? error.code
          : const WorkoutException(WorkoutErrorCode.unexpected).code;
      return null;
    } finally {
      _busyRoutineIds.remove(routineId);
      isActionRunning = false;
      _notify();
    }
  }

  Future<bool> pauseRoutine(AdvisedWorkoutItem item) async {
    final session = item.activeSession;
    if (session == null || session.status != WorkoutSessionStatus.inProgress.value) {
      return false;
    }
    final routineId = session.routineId;
    if (_busyRoutineIds.contains(routineId)) return false;

    return _runSessionAction(
      sessionId: session.id,
      routineId: routineId,
      action: () => _pauseWorkoutSession(session.id),
      onSuccess: () => true,
    );
  }

  Future<bool> finishRoutine(AdvisedWorkoutItem item) async {
    final session = item.activeSession;
    if (session == null) return false;
    final routineId = session.routineId;
    if (_busyRoutineIds.contains(routineId)) return false;

    return _runSessionAction(
      sessionId: session.id,
      routineId: routineId,
      action: () => _finishWorkoutSession(session.id),
      onSuccess: () => true,
    );
  }

  Future<bool> _runSessionAction({
    required String sessionId,
    required String routineId,
    required Future<WorkoutSession> Function() action,
    required bool Function() onSuccess,
  }) async {
    _busyRoutineIds.add(routineId);
    isActionRunning = true;
    errorCode = null;
    _notify();

    try {
      await action();
      await load();
      return onSuccess();
    } on Object catch (error) {
      errorCode = error is WorkoutException
          ? error.code
          : const WorkoutException(WorkoutErrorCode.unexpected).code;
      return false;
    } finally {
      _busyRoutineIds.remove(routineId);
      isActionRunning = false;
      _notify();
    }
  }

  void _notify() {
    if (!hasListeners) return;
    notifyListeners();
  }

  List<AdvisedWorkoutItem> _toWorkoutItems(
    List<Workout> workouts,
    List<WorkoutSession> sessions, {
    required DateTime now,
  }) {
    final byRoutine = <String, List<WorkoutSession>>{};
    for (final session in sessions) {
      if (!_isActiveStatus(session.status)) continue;
      byRoutine.putIfAbsent(session.routineId, () => []).add(session);
    }

    final orderedByDate = workouts.toList()
      ..sort((left, right) {
        final leftDate = left.startDate;
        final rightDate = right.startDate;
        if (leftDate == null && rightDate == null) return 0;
        if (leftDate == null) return 1;
        if (rightDate == null) return -1;
        return rightDate.compareTo(leftDate);
      });

    final items = orderedByDate
        .map((workout) {
          final active = _activeSessionFor(workout.routineId, byRoutine);
          final todayDay = _dayFromNow(now);
          final workoutDays = workout.days ?? const <WorkoutDayPlan>[];
          final todayPlan = workoutDays
              .where((day) => day.day == todayDay)
              .firstOrNull;
          final startPlan = workoutDays
              .where((day) => day.exercises.isNotEmpty)
              .firstOrNull;
          final startDay = startPlan?.day;

          final isCurrentMonthPlan =
              workout.isCurrentMonthPlan ?? _isCurrentMonthPlan(workout, now);
          final canStartRoutine =
              active == null &&
              (startDay != null) &&
              workoutDays
                  .where((day) => day.day == startDay)
                  .any((day) => day.exercises.isNotEmpty);

          return AdvisedWorkoutItem(
            workout: workout,
            activeSession: active,
            todayPlan: todayPlan,
            todayDay: todayPlan == null ? null : todayDay,
            startDay: startDay,
            isCurrentMonthPlan: isCurrentMonthPlan,
            canStartRoutine: canStartRoutine,
            availableDayPlans: workoutDays
                .where((day) => day.exercises.isNotEmpty)
                .toList(growable: false),
          );
        })
        .toList(growable: false);

    final currentMonth = items
        .where((item) => item.isCurrentMonthPlan == true)
        .toList(growable: false);
    final other = items
        .where((item) => item.isCurrentMonthPlan != true)
        .toList(growable: false);

    return [...currentMonth, ...other];
  }

  WorkoutSession? _activeSessionFor(
    String routineId,
    Map<String, List<WorkoutSession>> byRoutine,
  ) {
    final candidates = byRoutine[routineId];
    if (candidates == null || candidates.isEmpty) return null;

    candidates.sort((left, right) {
      final leftStarted = left.startedAt;
      final rightStarted = right.startedAt;
      if (leftStarted == null && rightStarted == null) return 0;
      if (leftStarted == null) return 1;
      if (rightStarted == null) return -1;
      return rightStarted.compareTo(leftStarted);
    });

    return candidates.firstWhere(
      (session) =>
          session.status == WorkoutSessionStatus.inProgress.value ||
          session.status == WorkoutSessionStatus.paused.value,
      orElse: () => candidates.first,
    );
  }

  bool _isCurrentMonthPlan(Workout workout, DateTime now) {
    final startDate = workout.startDate;
    final durationWeeks = workout.durationWeeks;
    if (startDate == null || durationWeeks == null || durationWeeks <= 0) {
      return false;
    }

    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final monthStart = DateTime(now.year, now.month);
    final monthEnd = now.month == 12
        ? DateTime(now.year + 1, 1)
        : DateTime(now.year, now.month + 1);

    final plannedEnd = start.add(Duration(days: durationWeeks * 7 - 1));
    return plannedEnd.isAfter(monthStart) &&
        !start.isAfter(monthEnd) &&
        !start.isAfter(plannedEnd) &&
        !start.isAfter(monthEnd) &&
        !plannedEnd.isBefore(monthStart);
  }

  static WorkoutDay _dayFromNow(DateTime now) {
    return WorkoutDay.values[(now.weekday - 1).clamp(0, 6)];
  }

  static bool _isActiveStatus(String status) {
    return status == WorkoutSessionStatus.inProgress.value ||
        status == WorkoutSessionStatus.paused.value;
  }

  static bool _isCompletedSession(WorkoutSession session) {
    return WorkoutSessionStatus.fromString(session.status) ==
        WorkoutSessionStatus.completed;
  }

  static List<DateTime> _collectCompletedWorkoutDays(
    List<WorkoutSession> completedSessions,
  ) {
    final uniqueDays = <int>{};
    for (final session in completedSessions) {
      final completedAt = session.completedAt;
      if (completedAt == null) continue;

      final key = (completedAt.year * 10000) +
          (completedAt.month * 100) +
          completedAt.day;
      uniqueDays.add(key);
    }

    return uniqueDays
        .map((key) {
          final day = key % 100;
          final month = (key ~/ 100) % 100;
          final year = key ~/ 10000;
          return DateTime(year, month, day);
        })
        .toList(growable: false)
      ..sort();
  }

  static String _normalizedExerciseId(String rawId) => rawId.trim().toLowerCase();
}

extension _FirstOrNullWorkoutDayPlan<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
