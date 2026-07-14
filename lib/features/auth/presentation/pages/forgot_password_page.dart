import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';

import 'package:fashion_pos_enterprise/core/extensions/context_extensions.dart';
import 'package:fashion_pos_enterprise/core/helpers/validation_helper.dart';
import 'package:fashion_pos_enterprise/design_system/components/app_button.dart';
import 'package:fashion_pos_enterprise/design_system/components/app_text_field.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:fashion_pos_enterprise/features/auth/routing/auth_route_paths.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    if (!ValidationHelper.isEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.invalidEmail)),
      );
      return;
    }
    final success = await ref.read(authControllerProvider.notifier).sendPasswordReset(email);
    if (success && mounted) setState(() => _sent = true);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);

    return AuthScaffold(
      title: context.l10n.forgotPassword,
      subtitle: _sent ? context.l10n.resetEmailSent : context.l10n.forgotPasswordSubtitle,
      child: _sent
          ? AppButton(
              label: context.l10n.backToLogin,
              onPressed: () => context.go(AuthRoutePaths.login),
              isExpanded: true,
            )
          : Column(
              children: [
                AppTextField(
                  controller: _emailController,
                  label: context.l10n.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const Gap(AppSpacing.xl),
                AppButton(
                  label: context.l10n.sendResetLink,
                  onPressed: auth.isLoading ? null : _submit,
                  isLoading: auth.isLoading,
                  isExpanded: true,
                ),
              ],
            ),
    );
  }
}
