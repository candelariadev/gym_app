import 'package:flutter/material.dart';

class GymTag extends StatelessWidget {
  const GymTag({
    super.key,
    required this.label,
    this.backgroundColor,
    this.foregroundColor,
    this.fontWeight = FontWeight.w600,
  });

  final String label;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: foregroundColor ?? colorScheme.onSurfaceVariant,
          fontWeight: fontWeight,
        ),
      ),
    );
  }
}
