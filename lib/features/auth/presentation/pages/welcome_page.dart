import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';

import 'package:fashion_pos_enterprise/core/extensions/context_extensions.dart';
import 'package:fashion_pos_enterprise/design_system/components/app_button.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:fashion_pos_enterprise/features/auth/routing/auth_route_paths.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: context.l10n.welcomeTitle,
      subtitle: context.l10n.welcomeSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton(
            label: context.l10n.login,
            onPressed: () => context.go(AuthRoutePaths.login),
            isExpanded: true,
          ),
          const Gap(AppSpacing.md),
          AppButton(
            label: context.l10n.registerStore,
            onPressed: () => context.go(AuthRoutePaths.register),
            variant: AppButtonVariant.outlined,
            isExpanded: true,
          ),
        ],
      ),
    );
  }
}
