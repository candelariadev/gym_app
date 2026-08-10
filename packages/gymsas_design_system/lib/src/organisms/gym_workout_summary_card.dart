import 'package:flutter/material.dart';

import '../atoms/gym_surface.dart';
import '../atoms/gym_tag.dart';
import '../theme/app_spacing.dart';

class GymWorkoutSummaryCard extends StatelessWidget {
  const GymWorkoutSummaryCard({
    super.key,
    required this.title,
    required this.statusLabel,
    required this.metadata,
    required this.tags,
    required this.actionLabel,
    required this.onTap,
  });

  final String title;
  final String statusLabel;
  final String metadata;
  final List<String> tags;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label: '$title, $actionLabel',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: GymSurface(
          width: double.infinity,
          backgroundColor: theme.colorScheme.surfaceContainerLowest,
          borderColor: theme.colorScheme.outlineVariant,
          elevation: GymSurfaceElevation.none,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    foregroundColor: theme.colorScheme.onPrimaryContainer,
                    child: const Icon(Icons.calendar_month_rounded),
                  ),
                  const SizedBox(width: AppSpacing.small),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          metadata,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.small),
                  GymTag(label: statusLabel),
                ],
              ),
              if (tags.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.medium),
                Wrap(
                  spacing: AppSpacing.small,
                  runSpacing: AppSpacing.xSmall,
                  children: tags
                      .map((label) => GymTag(label: label))
                      .toList(growable: false),
                ),
              ],
              const SizedBox(height: AppSpacing.medium),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    actionLabel,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: theme.colorScheme.primary,
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
