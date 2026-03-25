import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../application/workout_session_store.dart';
import '../../domain/workout_session_data.dart';
import 'workout_session_page.dart';

class WorkoutTodayPage extends StatelessWidget {
  const WorkoutTodayPage({super.key});

  static const routeName = '/workout-today';

  @override
  Widget build(BuildContext context) {
    final store = WorkoutSessionStore.instance;

    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final session = store.session;

        return Scaffold(
          backgroundColor: const Color(0xFFF7F7FB),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.fitness_center_rounded,
                                color: colorScheme.onPrimary,
                                size: 13,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'FitCoach',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  _RoutineHeader(session: session, completedCount: store.completedExercisesCount),
                  const SizedBox(height: AppSpacing.large),
                  ...List.generate(
                    session.exercises.length,
                    (index) {
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
                    },
                  ),
                  const SizedBox(height: AppSpacing.large),
                  _WorkoutFooter(session: session),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RoutineHeader extends StatelessWidget {
  const _RoutineHeader({
    required this.session,
    required this.completedCount,
  });

  final WorkoutSessionData session;
  final int completedCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            'Rutina de hoy',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            session.routineName,
            style: theme.textTheme.bodyMedium,
          ),
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
                'Progreso',
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
              ),
              const Spacer(),
              Text(
                '$completedCount de ${session.totalExercises} ejercicios',
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
                  color: isCompleted ? const Color(0xFF4EB85E) : Colors.transparent,
                  border: Border.all(
                    color: isCompleted
                        ? const Color(0xFF4EB85E)
                        : const Color(0xFFB9BDCB),
                  ),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: isCompleted
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 26)
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
                      isCompleted ? 'Completada' : exercise.name,
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
    return Container(
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const _FooterStat(
            icon: Icons.local_fire_department_outlined,
            label: 'Duracion estimada',
            value: '45 minutos',
          ),
          const SizedBox(width: AppSpacing.large),
          _FooterStat(
            icon: Icons.circle,
            label: 'Total series',
            value: '${session.totalSeries} series',
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
