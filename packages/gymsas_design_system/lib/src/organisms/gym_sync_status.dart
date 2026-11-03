import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';

/// Host supplies localized state and actions; no persistence dependency here.
class GymSyncStatus extends StatelessWidget {
  const GymSyncStatus({
    super.key,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    this.busy = false,
    this.warning = false,
  });
  final String message, actionLabel;
  final VoidCallback? onAction;
  final bool busy, warning;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final foreground = warning
        ? colors.onErrorContainer
        : colors.onSecondaryContainer;
    final indicator = busy
        ? SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(foreground),
            ),
          )
        : Icon(
            warning ? Icons.sync_problem : Icons.cloud_off_outlined,
            size: 20,
            color: foreground,
          );
    final action = TextButton(
      onPressed: busy ? null : onAction,
      style: TextButton.styleFrom(foregroundColor: foreground),
      child: Text(actionLabel),
    );
    final text = Text(
      message,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: foreground),
    );
    return Semantics(
      liveRegion: true,
      child: Material(
        color: warning ? colors.errorContainer : colors.secondaryContainer,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.medium,
            vertical: 4,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final narrow =
                  constraints.maxWidth < 340 ||
                  MediaQuery.textScalerOf(context).scale(1) > 1.3;
              final messageRow = Row(
                children: [
                  indicator,
                  const SizedBox(width: AppSpacing.xSmall),
                  Expanded(child: text),
                ],
              );
              if (narrow) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    messageRow,
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: action,
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: messageRow),
                  action,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
