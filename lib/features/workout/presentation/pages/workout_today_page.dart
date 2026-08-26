import 'package:flutter/material.dart';

import 'package:gymsas_design_system/gymsas_design_system.dart';
import 'package:gymsas_workouts/gymsas_workouts.dart' as workouts_pkg;
import '../../../../l10n/app_localizations.dart';
import '../../application/my_workouts_controller.dart';
import '../../application/workout_session_store.dart';
import '../../domain/workout_exercise_metadata.dart';
import '../../domain/workout_session_data.dart';
import 'workout_session_page.dart';

class WorkoutTodayPage extends StatefulWidget {
  const WorkoutTodayPage({
    super.key,
    required this.myWorkoutsController,
    required this.store,
  });

  final MyWorkoutsController myWorkoutsController;
  final WorkoutSessionStore store;

  static const routeName = '/workout-today';

  @override
  State<WorkoutTodayPage> createState() => _WorkoutTodayPageState();
}

class _WorkoutTodayPageState extends State<WorkoutTodayPage> {
  _MonthKey? _selectedMonthKey;

  @override
  void initState() {
    super.initState();
    widget.myWorkoutsController.addListener(_onControllerUpdated);
    widget.myWorkoutsController.load();
  }

  @override
  void dispose() {
    widget.myWorkoutsController.removeListener(_onControllerUpdated);
    super.dispose();
  }

  void _onControllerUpdated() => setState(() {});

  void _onRoutineActionPressed(AdvisedWorkoutItem item) {
    if (item.activeSession != null) {
      _openActiveSession(item);
      return;
    }

    () async {
      final action = await _openRoutinePicker(item);
      if (!mounted) return;

      switch (action) {
        case _RoutineStartActionDay(:final day):
          await _startRoutine(item, day);
        case null:
          break;
      }
    }();
  }

  void _openRoutineDetails(AdvisedWorkoutItem item) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.75,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.routineDetailTitle,
                  style: Theme.of(
                    sheetContext,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.xSmall),
                Text(
                  item.workout.name,
                  style: Theme.of(sheetContext).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.medium),
                Flexible(
                  child: SingleChildScrollView(
                    child: _WorkoutDaySummaryList(
                      workoutDays: item.availableDayPlans,
                      l10n: l10n,
                      maxVisibleDays: null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _startRoutine(
    AdvisedWorkoutItem item,
    workouts_pkg.WorkoutDay? scheduledDay,
  ) async {
    final started = await widget.myWorkoutsController.startRoutine(
      item,
      scheduledDay: scheduledDay,
    );
    if (!mounted || started == null) return;

    final sessionData = _resolveSessionData(
      item: item,
      session: started,
      exerciseMetadata: widget.myWorkoutsController.exerciseMetadata,
      l10n: AppLocalizations.of(context),
    );
    widget.store.restoreOrReplaceSession(sessionData);

    Navigator.of(context).pushNamed(
      WorkoutSessionPage.routeName,
      arguments: WorkoutExerciseArgs(session: sessionData, exerciseIndex: 0),
    );
  }

  Future<_RoutineStartAction?> _openRoutinePicker(
    AdvisedWorkoutItem item,
  ) async {
    final l10n = AppLocalizations.of(context);
    final workout = item.workout.name;
    final dayPlans = item.availableDayPlans
        .where((plan) => plan.exercises.isNotEmpty)
        .toList(growable: false);

    if (dayPlans.isEmpty) return null;

    final selected = await showModalBottomSheet<_RoutineStartAction>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 460),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(workout, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    l10n.workoutDaysCount(dayPlans.length),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.assignedRoutinesSubtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF7E8396),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      itemCount: dayPlans.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final plan = dayPlans[index];
                        final dayLabel = _dayLabelFromApiValue(
                          plan.day.apiValue,
                          l10n: l10n,
                        );

                        return _WorkoutDayStartCard(
                          dayLabel: dayLabel,
                          subtitle: _daySummary(plan, l10n: l10n),
                          onTap: () => Navigator.of(
                            sheetContext,
                          ).pop(_RoutineStartActionDay(plan.day)),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    return selected;
  }

  void _pauseRoutine(AdvisedWorkoutItem item) {
    () async {
      await widget.myWorkoutsController.pauseRoutine(item);
    }();
  }

  void _finishRoutine(AdvisedWorkoutItem item) {
    () async {
      await widget.myWorkoutsController.finishRoutine(item);
    }();
  }

  void _openActiveSession(AdvisedWorkoutItem item) {
    final activeSession = item.activeSession;
    if (activeSession == null) return;

    final sessionData = _resolveSessionData(
      item: item,
      session: activeSession,
      exerciseMetadata: widget.myWorkoutsController.exerciseMetadata,
      l10n: AppLocalizations.of(context),
    );
    widget.store.restoreOrReplaceSession(sessionData);
    Navigator.of(context).pushNamed(
      WorkoutSessionPage.routeName,
      arguments: WorkoutExerciseArgs(session: sessionData, exerciseIndex: 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final workouts = widget.myWorkoutsController.workouts;
    final isLoading = widget.myWorkoutsController.isLoading;
    final workouts_pkg.WorkoutErrorCode? error =
        widget.myWorkoutsController.errorCode;
    final now = DateTime.now();

    final monthIndexed = <_MonthKey, List<AdvisedWorkoutItem>>{};
    for (final item in workouts) {
      final month = _toMonthKey(item.workout.startDate);
      monthIndexed.putIfAbsent(month, () => []).add(item);
    }

    final monthKeys = _orderedMonthKeys(monthIndexed.keys.toList());
    final currentMonthKey = _toMonthKey(now);
    final selectedHomeMonth = _resolveSelectedMonthKey(
      requestedMonth: _selectedMonthKey,
      availableMonths: monthKeys,
      fallbackMonth: currentMonthKey,
    );
    final selectedMonthWorkouts = selectedHomeMonth == null
        ? const <AdvisedWorkoutItem>[]
        : monthIndexed[selectedHomeMonth] ?? const [];
    final content = _WorkoutRoutinesContent(
      l10n: l10n,
      isLoading: isLoading,
      error: error,
      onRetry: error == null ? null : () => widget.myWorkoutsController.load(),
      monthKeys: monthKeys,
      selectedMonth: selectedHomeMonth,
      onSelectMonth: (month) => setState(() {
        _selectedMonthKey = month;
      }),
      workouts: selectedMonthWorkouts,
      isBusy: widget.myWorkoutsController.isActionRunning,
      isRoutineBusy: widget.myWorkoutsController.isRoutineBusy,
      onStart: _onRoutineActionPressed,
      onDetails: _openRoutineDetails,
      onPause: _pauseRoutine,
      onFinish: _finishRoutine,
    );

    return Scaffold(body: SafeArea(child: content));
  }

  WorkoutSessionData _resolveSessionData({
    required AdvisedWorkoutItem item,
    required workouts_pkg.WorkoutSession session,
    required Map<String, WorkoutExerciseMetadata> exerciseMetadata,
    required AppLocalizations l10n,
  }) {
    final plannedById = <String, workouts_pkg.WorkoutExercise>{};
    final activeDay = _resolvePlannedDay(item, session);

    for (final workouts_pkg.WorkoutExercise exercise
        in activeDay?.exercises ?? const <workouts_pkg.WorkoutExercise>[]) {
      final id = _normalizedExerciseId(exercise.exerciseId);
      if (id.isNotEmpty) {
        plannedById[id] = exercise;
      }
    }

    final mapped = <WorkoutExercise>[];
    var order = 1;

    if (session.exercises.isNotEmpty) {
      for (final workouts_pkg.WorkoutSessionExercise sessionExercise
          in session.exercises) {
        final normalizedId = _normalizedExerciseId(sessionExercise.exerciseId);
        final metadata = exerciseMetadata[normalizedId];
        final prescriptionExercise = plannedById[normalizedId];

        final exerciseName = _firstNotBlank([
          metadata?.displayName,
          prescriptionExercise?.name,
          sessionExercise.exerciseId,
        ])!;

        final focus = _firstNotBlank([
          prescriptionExercise?.notes,
          metadata?.notes,
        ]);

        mapped.add(
          WorkoutExercise(
            order: order++,
            exerciseId: sessionExercise.exerciseId,
            name: exerciseName,
            focus: focus,
            metadata: metadata,
            seriesCount: sessionExercise.plannedSets ?? 0,
            repetitionRange: '${sessionExercise.plannedReps ?? 0} reps',
            imageUrl: metadata?.imageUrl,
          ),
        );
      }
    } else if (activeDay != null) {
      for (final workouts_pkg.WorkoutExercise plannedExercise
          in activeDay.exercises) {
        final normalizedId = _normalizedExerciseId(plannedExercise.exerciseId);
        final metadata = exerciseMetadata[normalizedId];

        mapped.add(
          WorkoutExercise(
            order: order++,
            exerciseId: plannedExercise.exerciseId,
            name:
                _firstNotBlank([metadata?.displayName, plannedExercise.name]) ??
                plannedExercise.exerciseId,
            focus: _firstNotBlank([plannedExercise.notes, metadata?.notes]),
            metadata: metadata,
            seriesCount: plannedExercise.sets,
            repetitionRange: '${plannedExercise.reps} reps',
            imageUrl: metadata?.imageUrl,
          ),
        );
      }
    }

    final totalSeries = mapped.fold<int>(
      0,
      (total, exercise) => total + exercise.seriesCount,
    );

    return WorkoutSessionData(
      sessionId: session.id,
      routineName: item.workout.name,
      dayTitle: _dayLabelFromApiValue(session.scheduledDay, l10n: l10n),
      estimatedDurationMinutes: (session.totalDurationSeconds ?? 0) ~/ 60,
      totalSeries: totalSeries,
      exercises: mapped,
      status: session.status,
      scheduledDay: session.scheduledDay,
      startedAt: session.startedAt,
      completedAt: session.completedAt,
      totalDurationSeconds: session.totalDurationSeconds,
    );
  }

  workouts_pkg.WorkoutDayPlan? _resolvePlannedDay(
    AdvisedWorkoutItem item,
    workouts_pkg.WorkoutSession session,
  ) {
    final scheduledDay = workouts_pkg.WorkoutDay.fromApiValue(
      session.scheduledDay,
    );

    final workoutDays = item.workout.days;
    if (scheduledDay == null || workoutDays == null || workoutDays.isEmpty) {
      return item.todayPlan;
    }

    return workoutDays.firstWhere(
      (plan) => plan.day == scheduledDay,
      orElse: () => item.todayPlan ?? workoutDays.first,
    );
  }
}

class _WorkoutRoutinesContent extends StatelessWidget {
  const _WorkoutRoutinesContent({
    required this.l10n,
    required this.isLoading,
    required this.error,
    required this.onRetry,
    required this.monthKeys,
    required this.selectedMonth,
    required this.onSelectMonth,
    required this.workouts,
    required this.isBusy,
    required this.isRoutineBusy,
    required this.onStart,
    required this.onDetails,
    required this.onPause,
    required this.onFinish,
  });

  final AppLocalizations l10n;
  final bool isLoading;
  final workouts_pkg.WorkoutErrorCode? error;
  final VoidCallback? onRetry;
  final List<_MonthKey> monthKeys;
  final _MonthKey? selectedMonth;
  final void Function(_MonthKey) onSelectMonth;
  final List<AdvisedWorkoutItem> workouts;
  final bool isBusy;
  final bool Function(String) isRoutineBusy;
  final void Function(AdvisedWorkoutItem) onStart;
  final void Function(AdvisedWorkoutItem) onDetails;
  final void Function(AdvisedWorkoutItem) onPause;
  final void Function(AdvisedWorkoutItem) onFinish;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return GymScrollablePage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GymBrandedHeader(
            title: l10n.appTitle,
            onBack: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: AppSpacing.medium),
          Text(
            l10n.assignedRoutinesTitle,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.small),
          Text(l10n.todayWorkoutActionDescription),
          const SizedBox(height: AppSpacing.medium),
          _MonthSelector(
            months: monthKeys,
            selected: selectedMonth,
            onSelected: onSelectMonth,
          ),
          const SizedBox(height: AppSpacing.medium),
          if (isLoading && workouts.isEmpty)
            const Center(child: CircularProgressIndicator())
          else if (workouts.isEmpty)
            _EmptyWorkoutState(
              hasError: error != null,
              error: error?.name,
              onRetry: error == null ? null : onRetry,
              label: l10n.myAssignedRoutinesEmpty,
              description: error == null ? l10n.assignedRoutinesSubtitle : null,
            )
          else ...[
            _WorkoutSection(
              title: selectedMonth?.label ?? _monthLabel(now),
              workouts: workouts,
              onStart: onStart,
              onDetails: onDetails,
              onPause: onPause,
              onFinish: onFinish,
              isBusy: isBusy,
              isRoutineBusy: isRoutineBusy,
              l10n: l10n,
            ),
          ],
        ],
      ),
    );
  }
}

abstract class _RoutineStartAction {
  const _RoutineStartAction();
}

class _RoutineStartActionDay extends _RoutineStartAction {
  const _RoutineStartActionDay(this.day);

  final workouts_pkg.WorkoutDay day;
}

class _WorkoutSection extends StatelessWidget {
  const _WorkoutSection({
    required this.title,
    required this.workouts,
    required this.onStart,
    required this.onDetails,
    required this.onPause,
    required this.onFinish,
    required this.isBusy,
    required this.isRoutineBusy,
    required this.l10n,
  });

  final String title;
  final List<AdvisedWorkoutItem> workouts;
  final void Function(AdvisedWorkoutItem) onStart;
  final void Function(AdvisedWorkoutItem) onDetails;
  final void Function(AdvisedWorkoutItem) onPause;
  final void Function(AdvisedWorkoutItem) onFinish;
  final bool isBusy;
  final bool Function(String) isRoutineBusy;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSpacing.small),
        ...workouts.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.medium),
            child: _WorkoutRoutineCard(
              item: item,
              isBusy: isBusy || isRoutineBusy(item.workout.routineId),
              detailActionLabel: l10n.viewRoutineDetails,
              onStart: () {
                onStart(item);
              },
              onDetails: () {
                onDetails(item);
              },
              onPause: () {
                onPause(item);
              },
              onFinish: () {
                onFinish(item);
              },
              l10n: l10n,
            ),
          ),
        ),
      ],
    );
  }
}

class _WorkoutRoutineCard extends StatelessWidget {
  const _WorkoutRoutineCard({
    required this.item,
    required this.isBusy,
    required this.detailActionLabel,
    required this.onStart,
    required this.onDetails,
    required this.onPause,
    required this.onFinish,
    required this.l10n,
  });

  final AdvisedWorkoutItem item;
  final bool isBusy;
  final String detailActionLabel;
  final VoidCallback onStart;
  final VoidCallback onDetails;
  final VoidCallback onPause;
  final VoidCallback onFinish;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasActiveSession = item.activeSession != null;
    final canStart = item.canStartRoutine;
    final title = item.workout.name;
    final exerciseCount =
        item.workout.days?.expand((day) => day.exercises).length ?? 0;
    final totalDays = item.availableDayPlans.length;
    final plannedDays = item.availableDayPlans;

    final canOpenSession = canStart || hasActiveSession;

    return Semantics(
      button: canOpenSession,
      label: title,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: isBusy || !canOpenSession ? null : onStart,
        child: GymSurface(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.workoutDaysCount(totalDays),
                          style: theme.textTheme.bodyMedium,
                        ),
                        Text(
                          '$exerciseCount ${l10n.exercisesLabel}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  _RoutineStatusBadge(
                    isActive: item.isInProgress,
                    isPaused: item.isPaused,
                    l10n: l10n,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.medium),
              _WorkoutDaySummaryList(
                workoutDays: plannedDays,
                l10n: l10n,
                maxVisibleDays: 2,
              ),
              const SizedBox(height: AppSpacing.medium),
              Wrap(
                spacing: AppSpacing.medium,
                runSpacing: AppSpacing.small,
                children: [
                  OutlinedButton(
                    onPressed: isBusy ? null : onDetails,
                    child: Text(detailActionLabel),
                  ),
                  if (hasActiveSession)
                    OutlinedButton(
                      onPressed: isBusy ? null : onPause,
                      child: Text(l10n.pauseLabel),
                    ),
                  if (hasActiveSession)
                    OutlinedButton(
                      onPressed: isBusy ? null : onFinish,
                      child: Text(l10n.commonFinish),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkoutDaySummaryList extends StatelessWidget {
  const _WorkoutDaySummaryList({
    required this.workoutDays,
    required this.l10n,
    this.maxVisibleDays = 2,
  });

  final List<workouts_pkg.WorkoutDayPlan> workoutDays;
  final AppLocalizations l10n;
  final int? maxVisibleDays;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orderedDays = workoutDays
        .where((plan) => plan.exercises.isNotEmpty)
        .toList(growable: false);
    final max = maxVisibleDays;
    final visibleDays = (max == null || max <= 0 || max >= orderedDays.length)
        ? orderedDays
        : orderedDays.take(max).toList(growable: false);

    if (orderedDays.isEmpty) {
      return Text(
        l10n.noExercisesFound,
        style: theme.textTheme.bodySmall?.copyWith(
          color: const Color(0xFF7D8396),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ...visibleDays.map((plan) {
          final dayLabel = _dayLabelFromApiValue(plan.day.apiValue, l10n: l10n);
          final exerciseNames = plan.exercises
              .take(2)
              .map((exercise) => exercise.name)
              .toList(growable: false);
          final additionalCount = plan.exercises.length - exerciseNames.length;
          final subtitle = additionalCount > 0
              ? '${exerciseNames.join(", ")} + $additionalCount'
              : exerciseNames.join(', ');
          final showFullDetails = maxVisibleDays == null;

          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dayLabel,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.routineDayExerciseCount(plan.exercises.length),
                  style: theme.textTheme.bodySmall,
                ),
                if (showFullDetails)
                  ...plan.exercises.map(
                    (exercise) => Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '${l10n.workoutExerciseSetsReps(exercise.exerciseId, exercise.sets, exercise.reps)} · '
                        '${l10n.restSecondsValue(exercise.restSeconds)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF444A63),
                        ),
                      ),
                    ),
                  )
                else if (subtitle.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF444A63),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
        if (max != null && max < orderedDays.length)
          Text(
            '${l10n.workoutDaysCount(orderedDays.length - visibleDays.length)} más',
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF7E8397),
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }
}

class _WorkoutDayStartCard extends StatelessWidget {
  const _WorkoutDayStartCard({
    required this.dayLabel,
    required this.subtitle,
    required this.onTap,
  });

  final String dayLabel;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: Row(
            children: [
              const Icon(Icons.calendar_today_outlined),
              const SizedBox(width: AppSpacing.medium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dayLabel,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF6A7386),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthSelector extends StatelessWidget {
  const _MonthSelector({
    required this.months,
    required this.selected,
    required this.onSelected,
  });

  final List<_MonthKey> months;
  final _MonthKey? selected;
  final void Function(_MonthKey) onSelected;

  @override
  Widget build(BuildContext context) {
    if (months.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final month = months[index];
          final isSelected = month == selected;

          return ChoiceChip(
            label: Text(month.label),
            selected: isSelected,
            onSelected: (value) {
              if (value) {
                onSelected(month);
              }
            },
          );
        },
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemCount: months.length,
      ),
    );
  }
}

class _RoutineStatusBadge extends StatelessWidget {
  const _RoutineStatusBadge({
    required this.isActive,
    required this.isPaused,
    required this.l10n,
  });

  final bool isActive;
  final bool isPaused;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? const Color(0xFFE6F4EA)
        : isPaused
        ? const Color(0xFFFFF4E5)
        : const Color(0xFFF2F3F7);
    final label = isActive
        ? l10n.activeStatus
        : isPaused
        ? l10n.pendingStatus
        : l10n.inactiveStatus;
    final textColor = isActive
        ? const Color(0xFF20A86B)
        : isPaused
        ? const Color(0xFFF3A64E)
        : const Color(0xFF80869A);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

class _EmptyWorkoutState extends StatelessWidget {
  const _EmptyWorkoutState({
    required this.hasError,
    required this.error,
    required this.onRetry,
    required this.label,
    this.description,
  });

  final bool hasError;
  final String? error;
  final VoidCallback? onRetry;
  final String label;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GymSurface(
      width: double.infinity,
      child: Column(
        children: [
          Icon(
            hasError
                ? Icons.error_outline_rounded
                : Icons.fitness_center_rounded,
            size: 38,
            color: hasError ? const Color(0xFFD33B2D) : const Color(0xFF565B6E),
          ),
          const SizedBox(height: AppSpacing.medium),
          Text(
            label,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          if (description != null) ...[
            const SizedBox(height: AppSpacing.small),
            Text(description!, textAlign: TextAlign.center),
          ],
          if (error != null) ...[
            const SizedBox(height: AppSpacing.small),
            Text(error!, textAlign: TextAlign.center),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: AppSpacing.medium),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(AppLocalizations.of(context).exerciseRetry),
            ),
          ],
        ],
      ),
    );
  }
}

String _daySummary(
  workouts_pkg.WorkoutDayPlan plan, {
  required AppLocalizations l10n,
}) {
  final names = plan.exercises
      .take(3)
      .map((exercise) => exercise.name)
      .toList(growable: false);

  final remaining = plan.exercises.length - names.length;
  final suffix = remaining > 0 ? ' +$remaining' : '';
  final list = names.join(', ');

  return '${l10n.routineDayExerciseCount(plan.exercises.length)} · $list$suffix';
}

String _dayLabelFromApiValue(
  String? apiValue, {
  required AppLocalizations l10n,
}) {
  final day = workouts_pkg.WorkoutDay.fromApiValue(apiValue);
  if (day == null) return l10n.dayNotAssigned;

  return switch (day) {
    workouts_pkg.WorkoutDay.monday => l10n.weekdayMonday,
    workouts_pkg.WorkoutDay.tuesday => l10n.weekdayTuesday,
    workouts_pkg.WorkoutDay.wednesday => l10n.weekdayWednesday,
    workouts_pkg.WorkoutDay.thursday => l10n.weekdayThursday,
    workouts_pkg.WorkoutDay.friday => l10n.weekdayFriday,
    workouts_pkg.WorkoutDay.saturday => l10n.weekdaySaturday,
    workouts_pkg.WorkoutDay.sunday => l10n.weekdaySunday,
  };
}

_MonthKey? _resolveSelectedMonthKey({
  required _MonthKey? requestedMonth,
  required List<_MonthKey> availableMonths,
  required _MonthKey fallbackMonth,
}) {
  if (requestedMonth != null && availableMonths.contains(requestedMonth)) {
    return requestedMonth;
  }

  if (availableMonths.contains(fallbackMonth)) {
    return fallbackMonth;
  }

  if (availableMonths.isNotEmpty) {
    return availableMonths.first;
  }

  return null;
}

List<_MonthKey> _orderedMonthKeys(List<_MonthKey> months) {
  final ordered = [...months];
  ordered.sort((left, right) => right.compareTo(left));
  return ordered;
}

String _monthLabel(DateTime? date, {String fallback = 'Sin fecha'}) {
  if (date == null) return fallback;

  final months = const [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  return '${months[date.month - 1]} ${date.year}';
}

class _MonthKey implements Comparable<_MonthKey> {
  const _MonthKey(this.year, this.month, this.label);

  final int year;
  final int month;
  final String label;

  @override
  int compareTo(_MonthKey other) {
    if (year == 0 || other.year == 0) {
      return year == 0 ? (other.year == 0 ? 0 : 1) : -1;
    }

    final yearComparison = other.year.compareTo(year);
    if (yearComparison != 0) return yearComparison;
    return other.month.compareTo(month);
  }

  @override
  bool operator ==(Object other) =>
      other is _MonthKey && other.year == year && other.month == month;

  @override
  int get hashCode => Object.hash(year, month);
}

_MonthKey _toMonthKey(DateTime? date) {
  if (date == null) {
    return const _MonthKey(0, 0, 'Sin fecha');
  }

  return _MonthKey(date.year, date.month, _monthLabel(date));
}

String _normalizedExerciseId(String rawId) => rawId.trim().toLowerCase();

String? _firstNotBlank(List<String?> candidates) {
  for (final candidate in candidates) {
    if (candidate != null && candidate.trim().isNotEmpty) {
      return candidate.trim();
    }
  }
  return null;
}
