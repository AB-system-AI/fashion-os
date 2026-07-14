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

class VerifyEmailPage extends ConsumerWidget {
  const VerifyEmailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);

    return AuthScaffold(
      title: context.l10n.verifyEmail,
      subtitle: context.l10n.verifyEmailSubtitle,
      child: Column(
        children: [
          Icon(Icons.mark_email_unread_outlined, size: 64, color: context.colorScheme.primary),
          const Gap(AppSpacing.lg),
          Text(auth.user?.email ?? '', style: context.textTheme.titleMedium),
          const Gap(AppSpacing.xl),
          AppButton(
            label: context.l10n.resendVerification,
            onPressed: auth.isLoading
                ? null
                : () => ref.read(authControllerProvider.notifier).resendVerification(),
            isLoading: auth.isLoading,
            isExpanded: true,
          ),
          const Gap(AppSpacing.md),
          AppButton(
            label: context.l10n.backToLogin,
            onPressed: () => context.go(AuthRoutePaths.login),
            variant: AppButtonVariant.outlined,
            isExpanded: true,
          ),
        ],
      ),
    );
  }
}
