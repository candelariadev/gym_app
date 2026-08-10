import 'package:flutter/material.dart';

class GymSelectOption<T> {
  const GymSelectOption({required this.value, required this.label});

  final T value;
  final String label;
}

class GymDropdownField<T> extends StatelessWidget {
  const GymDropdownField({
    super.key,
    required this.label,
    required this.options,
    required this.onChanged,
    this.value,
  });

  final String label;
  final T? value;
  final List<GymSelectOption<T>> options;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      isExpanded: true,
      items: options
          .map(
            (option) => DropdownMenuItem<T>(
              value: option.value,
              child: Text(option.label, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(growable: false),
      onChanged: onChanged,
    );
  }
}
