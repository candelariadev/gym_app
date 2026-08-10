import 'package:flutter/material.dart';

import 'package:gymsas_design_system/gymsas_design_system.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/workout_session_store.dart';
import '../../domain/workout_session_data.dart';

class WorkoutSessionPage extends StatefulWidget {
  const WorkoutSessionPage({super.key, required this.store});

  final WorkoutSessionStore store;

  static const routeName = '/workout-session';

  @override
  State<WorkoutSessionPage> createState() => _WorkoutSessionPageState();
}

class _WorkoutSessionPageState extends State<WorkoutSessionPage> {
  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as WorkoutExerciseArgs?;
    final store = widget.store;
    final l10n = AppLocalizations.of(context);

    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final session = args?.session ?? store.session;
        final exerciseIndex = args?.exerciseIndex ?? 0;
        final exercise = store.exerciseAt(exerciseIndex);
        final seriesCompleted = store.seriesFor(exerciseIndex);
        final checkedSeries = seriesCompleted
            .where((isCompleted) => isCompleted)
            .length;
        final isTimerActive = store.isRestActive;
        final canContinue =
            checkedSeries == exercise.seriesCount && !isTimerActive;
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return GymScrollablePage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GymBrandedHeader(
                title: l10n.appTitle,
                onBack: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: AppSpacing.medium),
              Center(
                child: Text(
                  l10n.todayRoutineTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.medium),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: exercise.order / session.totalExercises,
                        minHeight: 8,
                        backgroundColor: const Color(0xFFE1E3EA),
                        valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.small),
                  Text(
                    '${exercise.order}/${session.totalExercises}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF7E8397),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.large),
              Center(
                child: Text(
                  session.dayTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.medium),
              _WorkoutVideoCard(primaryColor: colorScheme.primary),
              const SizedBox(height: AppSpacing.large),
              _WorkoutExerciseCard(
                order: exercise.order,
                totalExercises: session.totalExercises,
                exercise: exercise,
                seriesCompleted: seriesCompleted,
                isTimerActive: isTimerActive,
                onSeriesTap: (index) {
                  if (isTimerActive) {
                    return;
                  }

                  store.toggleSeries(exerciseIndex, index);

                  if (store.seriesFor(exerciseIndex)[index]) {
                    store.startRestTimer();
                  }
                },
                canContinue: canContinue,
                onComplete: () {
                  store.completeExercise(exerciseIndex);
                  Navigator.of(context).pop();
                },
              ),
              if (store.remainingRestSeconds > 0) ...[
                const SizedBox(height: AppSpacing.medium),
                _RestTimerCard(
                  formattedTime: _formatTime(store.remainingRestSeconds),
                ),
              ],
              const SizedBox(height: AppSpacing.medium),
              _NextExerciseCard(
                nextExerciseName: exerciseIndex + 1 < session.exercises.length
                    ? store.nextExerciseAfter(exerciseIndex)?.name ?? ''
                    : l10n.workoutCompleted,
                nextExerciseDetails:
                    exerciseIndex + 1 < session.exercises.length
                    ? l10n.nextExerciseSummary(
                        store.nextExerciseAfter(exerciseIndex)?.seriesCount ??
                            0,
                        store
                                .nextExerciseAfter(exerciseIndex)
                                ?.repetitionRange ??
                            '',
                      )
                    : l10n.workoutCompletedDescription,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WorkoutVideoCard extends StatelessWidget {
  const _WorkoutVideoCard({required this.primaryColor});

  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8E735D), Color(0xFF56473E)],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.16,
              child: CustomPaint(painter: _WorkoutPatternPainter()),
            ),
          ),
          Center(
            child: Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.92),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 48,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutExerciseCard extends StatelessWidget {
  const _WorkoutExerciseCard({
    required this.order,
    required this.totalExercises,
    required this.exercise,
    required this.seriesCompleted,
    required this.isTimerActive,
    required this.onSeriesTap,
    required this.canContinue,
    required this.onComplete,
  });

  final int order;
  final int totalExercises;
  final WorkoutExercise exercise;
  final List<bool> seriesCompleted;
  final bool isTimerActive;
  final ValueChanged<int> onSeriesTap;
  final bool canContinue;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return GymSurface(
      child: Column(
        children: [
          Text(
            l10n.exercisePosition(order, totalExercises),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF7E8397),
            ),
          ),
          const SizedBox(height: AppSpacing.medium),
          Text(
            exercise.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.large),
          Row(
            children: [
              Expanded(
                child: _WorkoutStat(
                  value: '${exercise.seriesCount}',
                  label: l10n.setsLabel,
                ),
              ),
              Container(width: 1, height: 34, color: const Color(0xFFE4E6EE)),
              Expanded(
                child: _WorkoutStat(
                  value: exercise.repetitionRange,
                  label: l10n.repsLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.large),
          ...List.generate(
            seriesCompleted.length,
            (index) => Padding(
              padding: EdgeInsets.only(
                bottom: index == seriesCompleted.length - 1
                    ? 0
                    : AppSpacing.small,
              ),
              child: _SeriesTile(
                label: l10n.setLabel(index + 1),
                isCompleted: seriesCompleted[index],
                isLocked: isTimerActive,
                onTap: () => onSeriesTap(index),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.large),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canContinue ? onComplete : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canContinue ? null : const Color(0xFFD8D9DF),
                foregroundColor: canContinue ? null : const Color(0xFF8F95A7),
              ),
              child: Text(l10n.completeAndContinue),
            ),
          ),
        ],
      ),
    );
  }
}

class _RestTimerCard extends StatelessWidget {
  const _RestTimerCard({required this.formattedTime});

  final String formattedTime;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GymSurface(
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFECECFF),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.timer_outlined,
              color: Color(0xFF5B5CF6),
              size: 32,
            ),
          ),
          const SizedBox(height: AppSpacing.medium),
          Text(
            l10n.restBetweenSets,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            formattedTime,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontSize: 40,
              color: const Color(0xFF5B5CF6),
            ),
          ),
          const SizedBox(height: AppSpacing.xSmall),
          Text(
            l10n.restBlockedMessage,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _SeriesTile extends StatelessWidget {
  const _SeriesTile({
    required this.label,
    required this.isCompleted,
    required this.isLocked,
    required this.onTap,
  });

  final String label;
  final bool isCompleted;
  final bool isLocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isCompleted ? const Color(0xFFC3F0C5) : Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: isLocked ? null : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isCompleted
                  ? const Color(0xFF89D88B)
                  : const Color(0xFFE2E4EC),
            ),
          ),
          child: Row(
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Icon(
                isCompleted
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: isCompleted
                    ? const Color(0xFF49B55B)
                    : (isLocked
                          ? const Color(0xFFD0D3DE)
                          : const Color(0xFF9AA0B2)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkoutStat extends StatelessWidget {
  const _WorkoutStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: primary,
            fontSize: 26,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF7E8397),
          ),
        ),
      ],
    );
  }
}

class _NextExerciseCard extends StatelessWidget {
  const _NextExerciseCard({
    required this.nextExerciseName,
    required this.nextExerciseDetails,
  });

  final String nextExerciseName;
  final String nextExerciseDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return GymSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.nextLabel,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF9AA0B2),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            nextExerciseName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(nextExerciseDetails, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _WorkoutPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white;

    final path = Path()
      ..moveTo(size.width * 0.15, size.height * 0.75)
      ..lineTo(size.width * 0.32, size.height * 0.35)
      ..lineTo(size.width * 0.52, size.height * 0.62)
      ..lineTo(size.width * 0.72, size.height * 0.28)
      ..lineTo(size.width * 0.88, size.height * 0.74);

    canvas.drawPath(path, paint);

    final dotPaint = Paint()..color = Colors.white;
    for (final offset in [
      Offset(size.width * 0.15, size.height * 0.75),
      Offset(size.width * 0.32, size.height * 0.35),
      Offset(size.width * 0.52, size.height * 0.62),
      Offset(size.width * 0.72, size.height * 0.28),
      Offset(size.width * 0.88, size.height * 0.74),
    ]) {
      canvas.drawCircle(offset, 5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
