import 'package:flutter/material.dart';

import 'package:fashion_pos_enterprise/design_system/components/semantic_button.dart';

/// Standard confirmation dialog.
Future<bool?> showConfirmationDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  SemanticButtonType confirmType = SemanticButtonType.primary,
}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(cancelLabel)),
        SemanticButton(
          label: confirmLabel,
          type: confirmType,
          onPressed: () => Navigator.pop(ctx, true),
        ),
      ],
    ),
  );
}

Future<bool?> showDeleteDialog(BuildContext context, {required String itemName}) {
  return showConfirmationDialog(
    context,
    title: 'Delete',
    message: 'Delete "$itemName"? This action can be undone from archive.',
    confirmLabel: 'Delete',
    confirmType: SemanticButtonType.danger,
  );
}

void showSuccessDialog(BuildContext context, {required String message}) {
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.check_circle_outline, color: Colors.green),
      title: const Text('Success'),
      content: Text(message),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
    ),
  );
}

void showErrorDialog(BuildContext context, {required String message}) {
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: Icon(Icons.error_outline, color: Theme.of(ctx).colorScheme.error),
      title: const Text('Error'),
      content: Text(message),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
    ),
  );
}

void showWarningDialog(BuildContext context, {required String title, required String message}) {
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.warning_amber_outlined, color: Colors.orange),
      title: Text(title),
      content: Text(message),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
    ),
  );
}
