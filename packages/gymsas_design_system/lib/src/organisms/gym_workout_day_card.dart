import 'package:flutter/material.dart';

import '../atoms/gym_surface.dart';
import '../theme/app_spacing.dart';

class GymWorkoutDayCard extends StatelessWidget {
  const GymWorkoutDayCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.exercises,
    this.initiallyExpanded = false,
  });

  final String title;
  final String subtitle;
  final List<Widget> exercises;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GymSurface(
      padding: EdgeInsets.zero,
      elevation: GymSurfaceElevation.none,
      borderColor: theme.colorScheme.outlineVariant,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Material(
          color: Colors.transparent,
          child: ExpansionTile(
            initiallyExpanded: initiallyExpanded,
            tilePadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.medium,
              vertical: AppSpacing.xSmall,
            ),
            childrenPadding: const EdgeInsets.fromLTRB(
              AppSpacing.medium,
              0,
              AppSpacing.medium,
              AppSpacing.medium,
            ),
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              foregroundColor: theme.colorScheme.onPrimaryContainer,
              child: const Icon(Icons.event_note_rounded),
            ),
            title: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            subtitle: Text(subtitle),
            children: [
              for (var index = 0; index < exercises.length; index++) ...[
                if (index > 0) const SizedBox(height: AppSpacing.small),
                exercises[index],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
