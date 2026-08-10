import 'package:flutter/material.dart';

import '../atoms/gym_compact_metric.dart';
import '../theme/app_spacing.dart';

class GymWorkoutExerciseTile extends StatelessWidget {
  const GymWorkoutExerciseTile({
    super.key,
    required this.position,
    required this.title,
    required this.setsLabel,
    required this.setsValue,
    required this.repsLabel,
    required this.repsValue,
    required this.restLabel,
    required this.restValue,
    this.notes,
  });

  final int position;
  final String title;
  final String setsLabel;
  final String setsValue;
  final String repsLabel;
  final String repsValue;
  final String restLabel;
  final String restValue;
  final String? notes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.small),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: theme.colorScheme.secondaryContainer,
                foregroundColor: theme.colorScheme.onSecondaryContainer,
                child: Text(
                  '$position',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.small),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.small),
          Row(
            children: [
              Expanded(
                child: GymCompactMetric(
                  icon: Icons.repeat_rounded,
                  label: setsLabel,
                  value: setsValue,
                ),
              ),
              const SizedBox(width: AppSpacing.xSmall),
              Expanded(
                child: GymCompactMetric(
                  icon: Icons.fitness_center_rounded,
                  label: repsLabel,
                  value: repsValue,
                ),
              ),
              const SizedBox(width: AppSpacing.xSmall),
              Expanded(
                child: GymCompactMetric(
                  icon: Icons.timer_outlined,
                  label: restLabel,
                  value: restValue,
                ),
              ),
            ],
          ),
          if (notes != null && notes!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.small),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.xSmall),
                Expanded(
                  child: Text(
                    notes!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
