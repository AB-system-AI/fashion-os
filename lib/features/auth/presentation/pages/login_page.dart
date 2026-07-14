import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';

import 'package:fashion_pos_enterprise/core/extensions/context_extensions.dart';
import 'package:fashion_pos_enterprise/core/helpers/validation_helper.dart';
import 'package:fashion_pos_enterprise/design_system/components/app_button.dart';
import 'package:fashion_pos_enterprise/design_system/components/app_text_field.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/constants/auth_storage_keys.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:fashion_pos_enterprise/features/auth/routing/auth_route_paths.dart';
import 'package:fashion_pos_enterprise/core/services/local_storage_service.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = true;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lastEmail =
          ref.read(localStorageServiceProvider).getString(AuthStorageKeys.lastEmail);
      if (lastEmail != null) _emailController.text = lastEmail;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    if (!ValidationHelper.isEmail(email)) {
      _showError(context.l10n.invalidEmail);
      return;
    }
    if (_passwordController.text.isEmpty) {
      _showError(context.l10n.passwordRequired);
      return;
    }

    final success = await ref.read(authControllerProvider.notifier).signIn(
          email: email,
          password: _passwordController.text,
          rememberMe: _rememberMe,
        );

    if (success && mounted) context.go(AuthRoutePaths.home);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);

    return AuthScaffold(
      title: context.l10n.login,
      subtitle: context.l10n.loginSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: _emailController,
            label: context.l10n.email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            prefixIcon: const Icon(Icons.email_outlined),
          ),
          const Gap(AppSpacing.lg),
          AppTextField(
            controller: _passwordController,
            label: context.l10n.password,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          const Gap(AppSpacing.md),
          Row(
            children: [
              Checkbox(
                value: _rememberMe,
                onChanged: (v) => setState(() => _rememberMe = v ?? true),
              ),
              Text(context.l10n.rememberMe),
              const Spacer(),
              TextButton(
                onPressed: () => context.go(AuthRoutePaths.forgotPassword),
                child: Text(context.l10n.forgotPassword),
              ),
            ],
          ),
          const Gap(AppSpacing.lg),
          AppButton(
            label: context.l10n.login,
            onPressed: auth.isLoading ? null : _submit,
            isLoading: auth.isLoading,
            isExpanded: true,
          ),
          const Gap(AppSpacing.md),
          TextButton(
            onPressed: () => context.go(AuthRoutePaths.register),
            child: Text(context.l10n.noAccountRegister),
          ),
        ],
      ),
    );
  }
}
