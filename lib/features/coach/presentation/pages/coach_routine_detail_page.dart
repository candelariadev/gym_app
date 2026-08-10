import 'package:flutter/material.dart';
import 'package:gymsas_clients/gymsas_clients.dart';
import 'package:gymsas_design_system/gymsas_design_system.dart';

import '../../../../l10n/app_localizations.dart';
import '../localization/client_catalog_localizations.dart';

class CoachRoutineDetailArgs {
  const CoachRoutineDetailArgs({
    required this.workout,
    required this.clientName,
  });

  final AssignedWorkout workout;
  final String clientName;
}

class CoachRoutineDetailPage extends StatelessWidget {
  const CoachRoutineDetailPage({super.key});

  static const routeName = '/coach/routine-detail';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! CoachRoutineDetailArgs) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.routineDetailTitle)),
        body: Center(child: Text(l10n.routineNotFound)),
      );
    }

    final workout = args.workout;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.routineDetailTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _RoutineHeader(workout: workout, clientName: args.clientName),
            const SizedBox(height: AppSpacing.large),
            Text(
              l10n.weeklyPlanTitle,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.weeklyPlanSubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
            for (
              var dayIndex = 0;
              dayIndex < workout.days.length;
              dayIndex++
            ) ...[
              if (dayIndex > 0) const SizedBox(height: AppSpacing.small),
              _RoutineDay(
                day: workout.days[dayIndex],
                initiallyExpanded: dayIndex == 0,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RoutineHeader extends StatelessWidget {
  const _RoutineHeader({required this.workout, required this.clientName});

  final AssignedWorkout workout;
  final String clientName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final startDate = workout.startDate;
    final durationWeeks = workout.durationWeeks;
    final metadata = startDate != null && durationWeeks != null
        ? l10n.workoutWeeklyMetadata(
            workout.days.length,
            MaterialLocalizations.of(
              context,
            ).formatCompactDate(startDate.toLocal()),
            workout.totalExercises,
            durationWeeks,
          )
        : l10n.workoutMetadata(
            workout.totalExercises,
            l10n.workoutDaysCount(workout.days.length),
          );

    return GymSurface(
      backgroundColor: theme.colorScheme.primaryContainer,
      elevation: GymSurfaceElevation.none,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                child: const Icon(Icons.fitness_center_rounded),
              ),
              const SizedBox(width: AppSpacing.medium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.routineAssignedTo(clientName),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              GymTag(label: l10n.clientStatusLabel(workout.status)),
            ],
          ),
          const SizedBox(height: AppSpacing.medium),
          Text(
            metadata,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (workout.notes != null && workout.notes!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.small),
            Text(
              workout.notes!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RoutineDay extends StatelessWidget {
  const _RoutineDay({required this.day, required this.initiallyExpanded});

  final WorkoutDayPlan day;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GymWorkoutDayCard(
      title: l10n.workoutDayLabel(day.day),
      subtitle: l10n.routineDayExerciseCount(day.exercises.length),
      initiallyExpanded: initiallyExpanded,
      exercises: day.exercises.indexed
          .map(
            (entry) => GymWorkoutExerciseTile(
              position: entry.$1 + 1,
              title: entry.$2.exerciseId,
              setsLabel: l10n.setsLabel,
              setsValue: entry.$2.sets?.toString() ?? l10n.metricUnavailable,
              repsLabel: l10n.repsLabel,
              repsValue: entry.$2.reps?.toString() ?? l10n.metricUnavailable,
              restLabel: l10n.restLabel,
              restValue: entry.$2.restSeconds == null
                  ? l10n.metricUnavailable
                  : l10n.restSecondsValue(entry.$2.restSeconds!),
              notes: entry.$2.notes,
            ),
          )
          .toList(growable: false),
    );
  }
}
