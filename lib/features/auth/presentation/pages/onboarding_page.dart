import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';

import 'package:fashion_pos_enterprise/core/extensions/context_extensions.dart';
import 'package:fashion_pos_enterprise/design_system/components/app_button.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:fashion_pos_enterprise/features/auth/routing/auth_route_paths.dart';

class OnboardingPage extends ConsumerWidget {
  const OnboardingPage({super.key});

  static const _pages = [
    (icon: Icons.storefront, titleKey: 'onboardingTitle1', descKey: 'onboardingDesc1'),
    (icon: Icons.point_of_sale, titleKey: 'onboardingTitle2', descKey: 'onboardingDesc2'),
    (icon: Icons.cloud_off, titleKey: 'onboardingTitle3', descKey: 'onboardingDesc3'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AuthScaffold(
      title: context.l10n.onboardingWelcome,
      subtitle: context.l10n.onboardingSubtitle,
      child: Column(
        children: [
          for (final page in _pages) ...[
            ListTile(
              leading: CircleAvatar(
                backgroundColor: context.colorScheme.primaryContainer,
                child: Icon(page.icon, color: context.colorScheme.primary),
              ),
              title: Text(_title(context, page.titleKey)),
              subtitle: Text(_desc(context, page.descKey)),
            ),
            const Gap(AppSpacing.md),
          ],
          const Gap(AppSpacing.xl),
          AppButton(
            label: context.l10n.getStarted,
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).markOnboardingSeen();
              if (context.mounted) context.go(AuthRoutePaths.welcome);
            },
            isExpanded: true,
          ),
        ],
      ),
    );
  }

  String _title(BuildContext context, String key) => switch (key) {
        'onboardingTitle1' => context.l10n.onboardingTitle1,
        'onboardingTitle2' => context.l10n.onboardingTitle2,
        _ => context.l10n.onboardingTitle3,
      };

  String _desc(BuildContext context, String key) => switch (key) {
        'onboardingDesc1' => context.l10n.onboardingDesc1,
        'onboardingDesc2' => context.l10n.onboardingDesc2,
        _ => context.l10n.onboardingDesc3,
      };
}
