import 'package:flutter/material.dart';
import '../atoms/gym_surface.dart';
import '../molecules/gym_status_message.dart';
import '../theme/app_spacing.dart';

class GymActionStatusCard extends StatelessWidget {
  const GymActionStatusCard({
    super.key,
    required this.title,
    required this.status,
    this.subtitle,
    this.detail,
    this.actionLabel,
    this.onAction,
    this.busy = false,
    this.warning = false,
  });
  final String title, status;
  final String? subtitle, detail, actionLabel;
  final VoidCallback? onAction;
  final bool busy, warning;
  @override
  Widget build(BuildContext context) => GymSurface(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        if (subtitle != null)
          Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: AppSpacing.small),
        GymStatusMessage(label: status, busy: busy, warning: warning),
        if (detail != null) ...[
          const SizedBox(height: AppSpacing.small),
          Text(detail!),
        ],
        if (actionLabel != null) ...[
          const SizedBox(height: AppSpacing.small),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: OutlinedButton(
              onPressed: busy ? null : onAction,
              child: Text(actionLabel!),
            ),
          ),
        ],
      ],
    ),
  );
}
