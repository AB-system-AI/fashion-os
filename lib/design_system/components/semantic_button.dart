import 'package:flutter/material.dart';

import 'package:fashion_pos_enterprise/design_system/components/app_button.dart';
import 'package:fashion_pos_enterprise/design_system/components/app_icon_button.dart';

enum SemanticButtonType { primary, secondary, danger, success, text }

/// Semantic button presets built on [AppButton] — no duplicate button logic.
class SemanticButton extends StatelessWidget {
  const SemanticButton({
    required this.label,
    required this.onPressed,
    this.type = SemanticButtonType.primary,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final SemanticButtonType type;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (variant, fg, bg) = switch (type) {
      SemanticButtonType.primary => (AppButtonVariant.filled, scheme.onPrimary, scheme.primary),
      SemanticButtonType.secondary => (AppButtonVariant.outlined, scheme.primary, null),
      SemanticButtonType.danger => (AppButtonVariant.filled, scheme.onError, scheme.error),
      SemanticButtonType.success => (AppButtonVariant.filled, scheme.onPrimary, const Color(0xFF2E7D32)),
      SemanticButtonType.text => (AppButtonVariant.text, scheme.primary, null),
    };

    final button = AppButton(
      label: label,
      onPressed: onPressed,
      variant: variant,
      icon: icon,
      isLoading: isLoading,
      isExpanded: isExpanded,
    );

    if (bg == null) return button;
    return Theme(
      data: Theme.of(context).copyWith(
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(backgroundColor: bg, foregroundColor: fg),
        ),
      ),
      child: button,
    );
  }
}

/// Icon-only semantic action.
class SemanticIconButton extends StatelessWidget {
  const SemanticIconButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.type = SemanticButtonType.secondary,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final SemanticButtonType type;

  @override
  Widget build(BuildContext context) {
    return AppIconButton(
      icon: icon,
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }
}
