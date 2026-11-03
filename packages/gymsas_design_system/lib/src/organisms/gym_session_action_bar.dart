import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

class GymSessionActionBar extends StatelessWidget {
  const GymSessionActionBar({
    super.key,
    required this.statusText,
    required this.pauseLabel,
    required this.finishLabel,
    required this.onPause,
    required this.onFinish,
    this.canPause = true,
    this.canFinish = false,
    this.isLoading = false,
  });

  final String statusText;
  final String pauseLabel;
  final String finishLabel;
  final VoidCallback? onPause;
  final VoidCallback? onFinish;
  final bool canPause;
  final bool canFinish;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surface,
      elevation: 12,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.18),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.medium,
            AppSpacing.small,
            AppSpacing.medium,
            AppSpacing.medium,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                statusText,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: canFinish
                      ? colorScheme.tertiary
                      : colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: canPause && !isLoading ? onPause : null,
                      icon: const Icon(Icons.pause_rounded),
                      label: Text(pauseLabel),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.small),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: canFinish && !isLoading ? onFinish : null,
                      icon: isLoading
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.flag_rounded),
                      label: Text(finishLabel),
                    ),
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
