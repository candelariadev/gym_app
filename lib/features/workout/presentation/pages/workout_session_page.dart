import 'package:flutter/material.dart';

import 'package:gymsas_design_system/gymsas_design_system.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/workout_session_store.dart';
import '../../domain/workout_exercise_metadata.dart';
import '../../domain/workout_session_data.dart';

class WorkoutSessionPage extends StatefulWidget {
  const WorkoutSessionPage({super.key, required this.store});

  final WorkoutSessionStore store;

  static const routeName = '/workout-session';

  @override
  State<WorkoutSessionPage> createState() => _WorkoutSessionPageState();
}

class _WorkoutSessionPageState extends State<WorkoutSessionPage> {
  final Map<int, GlobalKey> _exerciseKeys = <int, GlobalKey>{};

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final l10n = AppLocalizations.of(context);

    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final session = store.session;

        if (session.totalExercises <= 0) {
          return GymScrollablePage(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GymBrandedHeader(
                  title: l10n.appTitle,
                  onBack: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: AppSpacing.xLarge),
                Icon(
                  Icons.fitness_center_outlined,
                  size: 42,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: AppSpacing.medium),
                Text(l10n.myAssignedRoutinesEmpty, textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.medium),
                Text(
                  'Esta sesión no contiene ejercicios todavía.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final completedExercises = store.completedExercisesCount;

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
                  session.routineName.isEmpty
                      ? l10n.todayRoutineTitle
                      : session.routineName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              Center(
                child: _SessionElapsedTimer(
                  label: l10n.sessionDurationLabel,
                  formattedTime: _formatTime(
                    store.elapsedSessionDuration.inSeconds,
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
                        value: completedExercises / session.totalExercises,
                        minHeight: 8,
                        backgroundColor: const Color(0xFFE1E3EA),
                        valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.small),
                  Text(
                    l10n.exerciseProgress(
                      completedExercises,
                      session.totalExercises,
                    ),
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
                  session.dayTitle ?? 'Día',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.medium),
              ...List.generate(session.exercises.length, (exerciseIndex) {
                final exercise = session.exercises[exerciseIndex];
                final seriesCompleted = store.seriesFor(exerciseIndex);
                final checkedSeries = seriesCompleted
                    .where((isCompleted) => isCompleted)
                    .length;
                final canContinue =
                    exercise.seriesCount > 0 &&
                    checkedSeries == exercise.seriesCount;
                final isCompleted = store.isExerciseCompleted(exerciseIndex);

                return Container(
                  key: _exerciseKeys.putIfAbsent(exerciseIndex, GlobalKey.new),
                  padding: EdgeInsets.only(
                    bottom: exerciseIndex == session.exercises.length - 1
                        ? 0
                        : AppSpacing.xLarge,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _WorkoutVideoCard(
                        primaryColor: colorScheme.primary,
                        exerciseImageUrl: exercise.imageUrl,
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      _WorkoutExerciseCard(
                        order: exercise.order,
                        totalExercises: session.totalExercises,
                        exercise: exercise,
                        seriesCompleted: seriesCompleted,
                        seriesWeights: store.weightsFor(exerciseIndex),
                        seriesRepetitions: store.repetitionsFor(exerciseIndex),
                        onSeriesTap: (seriesIndex) {
                          store.toggleSeries(exerciseIndex, seriesIndex);
                          if (store.seriesFor(exerciseIndex)[seriesIndex]) {
                            store.startRestTimer();
                          }
                        },
                        onWeightChanged: (seriesIndex, raw) => store
                            .setSeriesWeight(exerciseIndex, seriesIndex, raw),
                        onRepetitionsChanged: (seriesIndex, raw) =>
                            store.setSeriesRepetitions(
                              exerciseIndex,
                              seriesIndex,
                              raw,
                            ),
                        canContinue: canContinue,
                        isCompleted: isCompleted,
                        onComplete: () {
                          store.completeExercise(exerciseIndex);
                          _scrollToExercise(exerciseIndex + 1);
                        },
                      ),
                      if (_hasAdditionalMetadata(exercise)) ...[
                        const SizedBox(height: AppSpacing.medium),
                        _WorkoutExerciseMetadataCard(
                          metadata: exercise.metadata!,
                        ),
                      ],
                      if (store.remainingRestSeconds > 0 &&
                          store.activeExerciseIndex == exerciseIndex) ...[
                        const SizedBox(height: AppSpacing.medium),
                        _RestTimerCard(
                          formattedTime: _formatTime(
                            store.remainingRestSeconds,
                          ),
                          onSkip: store.skipRest,
                        ),
                      ],
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _scrollToExercise(int exerciseIndex) {
    final key = _exerciseKeys[exerciseIndex];
    if (key == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final targetContext = key.currentContext;
      if (!mounted || targetContext == null) return;
      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        alignment: 0.08,
      );
    });
  }

  bool _hasAdditionalMetadata(WorkoutExercise exercise) {
    final metadata = exercise.metadata;
    if (metadata == null) return false;
    return (metadata.force?.isNotEmpty == true) ||
        (metadata.level?.isNotEmpty == true) ||
        (metadata.mechanic?.isNotEmpty == true) ||
        (metadata.equipment?.isNotEmpty == true) ||
        (metadata.category?.isNotEmpty == true) ||
        metadata.primaryMuscles.isNotEmpty ||
        metadata.secondaryMuscles.isNotEmpty ||
        metadata.instructions.isNotEmpty ||
        (metadata.notes?.isNotEmpty == true);
  }
}

class _WorkoutVideoCard extends StatelessWidget {
  const _WorkoutVideoCard({required this.primaryColor, this.exerciseImageUrl});

  final Color primaryColor;
  final String? exerciseImageUrl;

  @override
  Widget build(BuildContext context) {
    final resolvedImageUrl = _resolveExerciseImageUrl(exerciseImageUrl);

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
          if (resolvedImageUrl != null)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  resolvedImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: Colors.black.withValues(alpha: 0.12),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      size: 42,
                      color: Colors.white70,
                    ),
                  ),
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: Colors.black.withValues(alpha: 0.2),
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(),
                    );
                  },
                ),
              ),
            ),
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

String? _resolveExerciseImageUrl(String? raw) {
  if (raw == null) return null;

  final value = raw.trim();
  if (value.isEmpty) return null;

  final isHttp = value.startsWith('http://') || value.startsWith('https://');
  return isHttp ? value : null;
}

class _WorkoutExerciseCard extends StatelessWidget {
  const _WorkoutExerciseCard({
    required this.order,
    required this.totalExercises,
    required this.exercise,
    required this.seriesCompleted,
    required this.seriesWeights,
    required this.seriesRepetitions,
    required this.onSeriesTap,
    required this.onWeightChanged,
    required this.onRepetitionsChanged,
    required this.canContinue,
    required this.isCompleted,
    required this.onComplete,
  });

  final int order;
  final int totalExercises;
  final WorkoutExercise exercise;
  final List<bool> seriesCompleted;
  final List<double?> seriesWeights;
  final List<int?> seriesRepetitions;
  final ValueChanged<int> onSeriesTap;
  final void Function(int seriesIndex, String value) onWeightChanged;
  final void Function(int seriesIndex, String value) onRepetitionsChanged;
  final bool canContinue;
  final bool isCompleted;
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
          if (exercise.focus != null && exercise.focus!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.small),
            Text(
              exercise.focus!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF7E8397),
              ),
            ),
          ],
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
                isLocked: false,
                weight: index < seriesWeights.length
                    ? seriesWeights[index]
                    : null,
                repetitions: index < seriesRepetitions.length
                    ? seriesRepetitions[index]
                    : null,
                onTap: () => onSeriesTap(index),
                onWeightChanged: (value) => onWeightChanged(index, value),
                onRepetitionsChanged: (value) =>
                    onRepetitionsChanged(index, value),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.large),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canContinue && !isCompleted ? onComplete : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canContinue && !isCompleted
                    ? null
                    : const Color(0xFFD8D9DF),
                foregroundColor: canContinue && !isCompleted
                    ? null
                    : const Color(0xFF8F95A7),
              ),
              child: Text(
                isCompleted ? l10n.completedStatus : l10n.completeAndContinue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutExerciseMetadataCard extends StatelessWidget {
  const _WorkoutExerciseMetadataCard({required this.metadata});

  final WorkoutExerciseMetadata metadata;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tags = <String>[
      if (metadata.force?.isNotEmpty == true) 'Tipo: ${metadata.force}',
      if (metadata.level?.isNotEmpty == true) 'Nivel: ${metadata.level}',
      if (metadata.mechanic?.isNotEmpty == true)
        'Mecánica: ${metadata.mechanic}',
      if (metadata.equipment?.isNotEmpty == true)
        'Equipo: ${metadata.equipment}',
      if (metadata.category?.isNotEmpty == true)
        'Categoría: ${metadata.category}',
      if (metadata.primaryMuscles.isNotEmpty)
        'Músculos: ${metadata.primaryMuscles.join(', ')}',
      if (metadata.secondaryMuscles.isNotEmpty)
        'Secundarios: ${metadata.secondaryMuscles.join(', ')}',
    ];

    return GymSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detalle del ejercicio',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          if (tags.isNotEmpty) ...[
            Wrap(
              spacing: AppSpacing.small,
              runSpacing: AppSpacing.xSmall,
              children: tags
                  .map(
                    (tag) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F5FF),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0xFFE4E6FF)),
                      ),
                      child: Text(
                        tag,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF444A63),
                        ),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
            const SizedBox(height: AppSpacing.small),
          ],
          if (metadata.instructions.isNotEmpty) ...[
            Text(
              'Instrucciones',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xSmall),
            ...metadata.instructions.map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• $line'),
              ),
            ),
            const SizedBox(height: AppSpacing.small),
          ],
          if (metadata.notes != null && metadata.notes!.isNotEmpty)
            Text(metadata.notes!),
        ],
      ),
    );
  }
}

class _RestTimerCard extends StatelessWidget {
  const _RestTimerCard({required this.formattedTime, required this.onSkip});

  final String formattedTime;
  final VoidCallback onSkip;

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
          const SizedBox(height: AppSpacing.small),
          TextButton(onPressed: onSkip, child: Text(l10n.skipRestLabel)),
        ],
      ),
    );
  }
}

class _SessionElapsedTimer extends StatelessWidget {
  const _SessionElapsedTimer({
    required this.label,
    required this.formattedTime,
  });

  final String label;
  final String formattedTime;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: '$label $formattedTime',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timer_outlined,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Text(
              '$label · $formattedTime',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeriesTile extends StatefulWidget {
  const _SeriesTile({
    required this.label,
    required this.isCompleted,
    required this.isLocked,
    required this.weight,
    required this.repetitions,
    required this.onTap,
    required this.onWeightChanged,
    required this.onRepetitionsChanged,
  });

  final String label;
  final bool isCompleted;
  final bool isLocked;
  final double? weight;
  final int? repetitions;
  final VoidCallback onTap;
  final ValueChanged<String> onWeightChanged;
  final ValueChanged<String> onRepetitionsChanged;

  @override
  State<_SeriesTile> createState() => _SeriesTileState();
}

class _SeriesTileState extends State<_SeriesTile> {
  late final TextEditingController _weightController;
  late final TextEditingController _repetitionsController;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: widget.weight == null ? '' : _formatWeight(widget.weight!),
    );
    _repetitionsController = TextEditingController(
      text: widget.repetitions == null ? '' : widget.repetitions.toString(),
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repetitionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = widget.isCompleted
        ? const Color(0xFF49B55B)
        : widget.isLocked
        ? const Color(0xFFD0D3DE)
        : const Color(0xFF9AA0B2);

    return Material(
      color: widget.isCompleted ? const Color(0xFFC3F0C5) : Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: widget.isCompleted
                ? const Color(0xFF89D88B)
                : const Color(0xFFE2E4EC),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: widget.isLocked ? null : widget.onTap,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Text(
                            widget.label,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            widget.isCompleted
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            color: statusColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                IconButton(
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  tooltip: widget.isCompleted
                      ? 'Serie completada'
                      : 'Marcar serie',
                  onPressed: widget.isLocked ? null : widget.onTap,
                  icon: Icon(
                    widget.isCompleted
                        ? Icons.check_circle_rounded
                        : Icons.circle_outlined,
                    color: statusColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _SeriesMetricField(
                    enabled: !widget.isLocked,
                    label: 'Peso',
                    hint: 'kg',
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: widget.onWeightChanged,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SeriesMetricField(
                    enabled: !widget.isLocked,
                    label: 'Reps',
                    hint: 'reps',
                    controller: _repetitionsController,
                    keyboardType: TextInputType.number,
                    onChanged: widget.onRepetitionsChanged,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SeriesMetricField extends StatelessWidget {
  const _SeriesMetricField({
    required this.enabled,
    required this.label,
    required this.hint,
    required this.controller,
    required this.keyboardType,
    required this.onChanged,
  });

  final bool enabled;
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      onChanged: onChanged,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        labelText: label,
        labelStyle: Theme.of(context).textTheme.bodySmall,
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
      ),
    );
  }
}

String _formatWeight(double value) {
  if (value == value.toInt()) {
    return value.toInt().toString();
  }
  return value.toString();
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
