import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';

class GymStatusMessage extends StatelessWidget {
  const GymStatusMessage({
    super.key,
    required this.label,
    this.busy = false,
    this.warning = false,
  });
  final String label;
  final bool busy, warning;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context), colors = Theme.of(context).colorScheme;
    final color = warning ? colors.error : colors.onSurfaceVariant;
    return Semantics(
      liveRegion: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (busy)
            SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: color),
            )
          else
            Icon(
              warning ? Icons.info_outline : Icons.notifications_outlined,
              size: 20,
              color: color,
            ),
          const SizedBox(width: AppSpacing.small),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
