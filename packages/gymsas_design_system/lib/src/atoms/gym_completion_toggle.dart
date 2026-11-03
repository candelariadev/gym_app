import 'package:flutter/material.dart';

class GymCompletionToggle extends StatelessWidget {
  const GymCompletionToggle({
    super.key,
    required this.isCompleted,
    required this.label,
    required this.completedLabel,
    required this.onPressed,
  });

  final bool isCompleted;
  final String label;
  final String completedLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusColor = isCompleted
        ? colorScheme.tertiary
        : colorScheme.onSurfaceVariant;
    final currentLabel = isCompleted ? completedLabel : label;

    return Semantics(
      button: true,
      checked: isCompleted,
      label: currentLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isCompleted
                  ? colorScheme.tertiary.withValues(alpha: 0.12)
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCompleted ? colorScheme.tertiary : colorScheme.outline,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isCompleted
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: statusColor,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    currentLabel,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
