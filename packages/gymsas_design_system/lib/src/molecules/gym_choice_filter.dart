import 'package:flutter/material.dart';

import 'gym_labeled_field.dart';

class GymChoiceFilter extends StatelessWidget {
  const GymChoiceFilter({
    super.key,
    required this.label,
    required this.values,
    required this.selectedValue,
    required this.onSelected,
  });

  final String label;
  final List<String> values;
  final String selectedValue;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return GymLabeledField(
      label: label,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: values
            .map(
              (value) => ChoiceChip(
                label: Text(value),
                selected: selectedValue == value,
                onSelected: (_) => onSelected(value),
                labelStyle: theme.textTheme.bodySmall?.copyWith(
                  color: selectedValue == value
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
                backgroundColor: colorScheme.surfaceContainerHighest,
                selectedColor: colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}
