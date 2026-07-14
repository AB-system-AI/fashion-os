import 'package:flutter/material.dart';

import 'package:fashion_pos_enterprise/design_system/components/app_text_field.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';

/// Material dropdown field.
class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    required this.label,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.value,
    super.key,
  });

  final String label;
  final List<T> items;
  final String Function(T item) itemLabel;
  final ValueChanged<T?> onChanged;
  final T? value;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(itemLabel(item))))
          .toList(),
      onChanged: onChanged,
    );
  }
}

/// Autocomplete lookup field.
class AppAutocompleteField<T extends Object> extends StatelessWidget {
  const AppAutocompleteField({
    required this.label,
    required this.options,
    required this.displayString,
    required this.onSelected,
    this.initialValue,
    super.key,
  });

  final String label;
  final List<T> options;
  final String Function(T option) displayString;
  final ValueChanged<T> onSelected;
  final String? initialValue;

  @override
  Widget build(BuildContext context) {
    return Autocomplete<T>(
      initialValue: TextEditingValue(text: initialValue ?? ''),
      displayStringForOption: displayString,
      optionsBuilder: (text) {
        if (text.text.isEmpty) return options;
        return options.where((o) => displayString(o).toLowerCase().contains(text.text.toLowerCase()));
      },
      onSelected: onSelected,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return AppTextField(
          controller: controller,
          label: label,
          onSubmitted: (_) => onFieldSubmitted(),
        );
      },
    );
  }
}

/// Date picker field.
class AppDateField extends StatelessWidget {
  const AppDateField({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = value == null ? '' : MaterialLocalizations.of(context).formatShortDate(value!);
    return AppTextField(
      label: label,
      readOnly: true,
      controller: TextEditingController(text: text),
      suffixIcon: const Icon(Icons.calendar_today),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          initialDate: value ?? DateTime.now(),
        );
        onChanged(picked);
      },
    );
  }
}

/// Time picker field.
class AppTimeField extends StatelessWidget {
  const AppTimeField({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String label;
  final TimeOfDay? value;
  final ValueChanged<TimeOfDay?> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = value?.format(context) ?? '';
    return AppTextField(
      label: label,
      readOnly: true,
      controller: TextEditingController(text: text),
      suffixIcon: const Icon(Icons.access_time),
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: value ?? TimeOfDay.now(),
        );
        onChanged(picked);
      },
    );
  }
}
