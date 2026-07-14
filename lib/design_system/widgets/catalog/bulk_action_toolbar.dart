import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:fashion_pos_enterprise/design_system/components/semantic_button.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';

/// Floating bulk action toolbar for multi-select lists.
class BulkActionToolbar extends StatelessWidget {
  const BulkActionToolbar({
    required this.selectedCount,
    required this.onClear,
    required this.actions,
    super.key,
  });

  final int selectedCount;
  final VoidCallback onClear;
  final List<BulkAction> actions;

  @override
  Widget build(BuildContext context) {
    if (selectedCount == 0) return const SizedBox.shrink();
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(12),
      color: Theme.of(context).colorScheme.inverseSurface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Row(
          children: [
            Text('$selectedCount selected', style: TextStyle(color: Theme.of(context).colorScheme.onInverseSurface)),
            const Gap(AppSpacing.md),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final action in actions) ...[
                      SemanticButton(
                        label: action.label,
                        type: action.danger ? SemanticButtonType.danger : SemanticButtonType.secondary,
                        icon: action.icon,
                        onPressed: action.onPressed,
                      ),
                      const Gap(AppSpacing.sm),
                    ],
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              color: Theme.of(context).colorScheme.onInverseSurface,
              onPressed: onClear,
            ),
          ],
        ),
      ),
    );
  }
}

class BulkAction {
  const BulkAction({required this.label, required this.onPressed, this.icon, this.danger = false});

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool danger;
}
