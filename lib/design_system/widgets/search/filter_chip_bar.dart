import 'package:flutter/material.dart';

import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';

/// Horizontal filter chip row.
class FilterChipBar extends StatelessWidget {
  const FilterChipBar({
    required this.chips,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final List<String> chips;
  final Set<String> selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          for (final chip in chips)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: FilterChip(
                label: Text(chip),
                selected: selected.contains(chip),
                onSelected: (_) => onSelected(chip),
              ),
            ),
        ],
      ),
    );
  }
}
