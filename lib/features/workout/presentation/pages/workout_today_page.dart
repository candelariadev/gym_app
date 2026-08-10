import 'package:flutter/material.dart';

import 'package:gymsas_design_system/gymsas_design_system.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/workout_session_store.dart';
import '../../domain/workout_session_data.dart';
import 'workout_session_page.dart';

class WorkoutTodayPage extends StatelessWidget {
  const WorkoutTodayPage({super.key, required this.store});

  final WorkoutSessionStore store;

  static const routeName = '/workout-today';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final session = store.session;

        return GymScrollablePage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GymBrandedHeader(
                title: l10n.appTitle,
                onBack: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: AppSpacing.medium),
              _RoutineHeader(
                session: session,
                completedCount: store.completedExercisesCount,
              ),
              const SizedBox(height: AppSpacing.large),
              ...List.generate(session.exercises.length, (index) {
                final exercise = session.exercises[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.medium),
                  child: _ExerciseListItem(
                    exercise: exercise,
                    isCompleted: store.isExerciseCompleted(index),
                    isDisabled: !store.canOpenExercise(index),
                    onTap: () {
                      if (!store.canOpenExercise(index)) {
                        return;
                      }
                      Navigator.of(context).pushNamed(
                        WorkoutSessionPage.routeName,
                        arguments: WorkoutExerciseArgs(
                          session: session,
                          exerciseIndex: index,
                        ),
                      );
                    },
                  ),
                );
              }),
              const SizedBox(height: AppSpacing.large),
              _WorkoutFooter(session: session),
            ],
          ),
        );
      },
    );
  }
}

class _RoutineHeader extends StatelessWidget {
  const _RoutineHeader({required this.session, required this.completedCount});

  final WorkoutSessionData session;
  final int completedCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return GymSurface(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.large),
      elevation: GymSurfaceElevation.none,
      child: Column(
        children: [
          Text(
            l10n.todayRoutineTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(session.routineName, style: theme.textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.small),
          Text(
            session.dayTitle,
            style: theme.textTheme.headlineSmall?.copyWith(fontSize: 24),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.medium),
          Row(
            children: [
              Text(
                l10n.progressLabel,
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
              ),
              const Spacer(),
              Text(
                l10n.exerciseProgress(completedCount, session.totalExercises),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: completedCount / session.totalExercises,
              minHeight: 8,
              backgroundColor: const Color(0xFFE1E3EA),
              valueColor: AlwaysStoppedAnimation(colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseListItem extends StatelessWidget {
  const _ExerciseListItem({
    required this.exercise,
    required this.isCompleted,
    required this.isDisabled,
    required this.onTap,
  });

  final WorkoutExercise exercise;
  final bool isCompleted;
  final bool isDisabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Material(
      color: isCompleted ? const Color(0xFFC7F0C8) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isDisabled ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFF4EB85E)
                      : Colors.transparent,
                  border: Border.all(
                    color: isCompleted
                        ? const Color(0xFF4EB85E)
                        : const Color(0xFFB9BDCB),
                  ),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: isCompleted
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 26,
                      )
                    : Text(
                        '${exercise.order}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF6E7386),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
              const SizedBox(width: AppSpacing.medium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCompleted ? l10n.completedStatus : exercise.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isCompleted ? const Color(0xFF4EB85E) : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (!isCompleted)
                      Row(
                        children: [
                          Text(
                            exercise.focus,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF3D7CFF),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.large),
                          Text(
                            '${exercise.seriesCount} x ${exercise.repetitionRange}',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              Icon(
                isCompleted
                    ? Icons.chevron_right_rounded
                    : Icons.chevron_right_rounded,
                color: isCompleted
                    ? const Color(0xFF4EB85E)
                    : (isDisabled
                          ? const Color(0xFFD0D3DE)
                          : const Color(0xFF7B7F8F)),
                size: 34,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkoutFooter extends StatelessWidget {
  const _WorkoutFooter({required this.session});

  final WorkoutSessionData session;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GymSurface(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.large),
      elevation: GymSurfaceElevation.none,
      child: Row(
        children: [
          _FooterStat(
            icon: Icons.local_fire_department_outlined,
            label: l10n.estimatedDurationLabel,
            value: l10n.minutesValue(session.estimatedDurationMinutes),
          ),
          const SizedBox(width: AppSpacing.large),
          _FooterStat(
            icon: Icons.circle,
            label: l10n.totalSetsLabel,
            value: l10n.setsValue(session.totalSeries),
          ),
        ],
      ),
    );
  }
}

class _FooterStat extends StatelessWidget {
  const _FooterStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F2F7),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, size: 16, color: const Color(0xFFA1A6B7)),
          ),
          const SizedBox(width: AppSpacing.small),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
