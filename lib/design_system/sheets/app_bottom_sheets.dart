import 'package:flutter/material.dart';

import 'package:fashion_pos_enterprise/design_system/components/semantic_button.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';

/// Filter options bottom sheet.
Future<T?> showFilterSheet<T>({
  required BuildContext context,
  required String title,
  required List<Widget> children,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.md,
        bottom: MediaQuery.paddingOf(ctx).bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(ctx).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.lg),
          ...children,
        ],
      ),
    ),
  );
}

/// Sort options bottom sheet.
Future<String?> showSortSheet({
  required BuildContext context,
  required List<String> options,
  String? selected,
}) {
  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => ListView(
      shrinkWrap: true,
      children: [
        for (final option in options)
          ListTile(
            title: Text(option),
            trailing: selected == option ? const Icon(Icons.check) : null,
            onTap: () => Navigator.pop(ctx, option),
          ),
      ],
    ),
  );
}

/// Quick actions bottom sheet.
Future<void> showQuickActionsSheet({
  required BuildContext context,
  required List<({String label, IconData icon, VoidCallback onTap})> actions,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final action in actions)
            ListTile(
              leading: Icon(action.icon),
              title: Text(action.label),
              onTap: () {
                Navigator.pop(ctx);
                action.onTap();
              },
            ),
        ],
      ),
    ),
  );
}
