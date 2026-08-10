import 'package:flutter/material.dart';

class GymLabelValue extends StatelessWidget {
  const GymLabelValue({
    super.key,
    required this.label,
    required this.value,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.labelStyle,
    this.valueStyle,
    this.gap = 4,
  });

  final String label;
  final String value;
  final CrossAxisAlignment crossAxisAlignment;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          label,
          style:
              labelStyle ??
              theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
        ),
        SizedBox(height: gap),
        Text(
          value,
          style:
              valueStyle ??
              theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
