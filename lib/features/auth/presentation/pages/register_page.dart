import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';

import 'package:fashion_pos_enterprise/core/extensions/context_extensions.dart';
import 'package:fashion_pos_enterprise/core/helpers/validation_helper.dart';
import 'package:fashion_pos_enterprise/core/security/password_validator.dart';
import 'package:fashion_pos_enterprise/design_system/components/app_button.dart';
import 'package:fashion_pos_enterprise/design_system/components/app_text_field.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/owner_registration.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:fashion_pos_enterprise/features/auth/routing/auth_route_paths.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _tenantNameController = TextEditingController();
  final _storeNameController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    for (final c in [
      _fullNameController,
      _emailController,
      _passwordController,
      _confirmPasswordController,
      _tenantNameController,
      _storeNameController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String _slugify(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-');
  }

  String _mapPasswordError(String? code) => switch (code) {
        'password_required' => context.l10n.passwordRequired,
        'password_too_short' => context.l10n.passwordTooShort,
        'password_missing_uppercase' => context.l10n.passwordMissingUppercase,
        'password_missing_lowercase' => context.l10n.passwordMissingLowercase,
        'password_missing_digit' => context.l10n.passwordMissingDigit,
        'password_missing_special' => context.l10n.passwordMissingSpecial,
        _ => context.l10n.passwordRequired,
      };

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    if (!ValidationHelper.isEmail(email)) {
      _showError(context.l10n.invalidEmail);
      return;
    }
    final passwordError = PasswordValidator.validate(_passwordController.text);
    if (passwordError != null) {
      _showError(_mapPasswordError(passwordError));
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showError(context.l10n.passwordMismatch);
      return;
    }
    if (_tenantNameController.text.trim().isEmpty || _storeNameController.text.trim().isEmpty) {
      _showError(context.l10n.fillRequiredFields);
      return;
    }

    final registration = OwnerRegistration(
      email: email,
      password: _passwordController.text,
      fullName: _fullNameController.text.trim(),
      tenantName: _tenantNameController.text.trim(),
      tenantSlug: _slugify(_tenantNameController.text),
      storeName: _storeNameController.text.trim(),
    );

    final success = await ref.read(authControllerProvider.notifier).registerOwner(registration);
    if (success && mounted) context.go(AuthRoutePaths.verifyEmail);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final passwordScore = PasswordValidator.strengthScore(_passwordController.text);

    return AuthScaffold(
      title: context.l10n.registerStore,
      subtitle: context.l10n.registerSubtitle,
      child: Column(
        children: [
          AppTextField(controller: _fullNameController, label: context.l10n.fullName),
          const Gap(AppSpacing.md),
          AppTextField(
            controller: _emailController,
            label: context.l10n.email,
            keyboardType: TextInputType.emailAddress,
          ),
          const Gap(AppSpacing.md),
          AppTextField(
            controller: _passwordController,
            label: context.l10n.password,
            obscureText: _obscurePassword,
            onChanged: (_) => setState(() {}),
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          LinearProgressIndicator(value: passwordScore, minHeight: 4),
          const Gap(AppSpacing.md),
          AppTextField(
            controller: _confirmPasswordController,
            label: context.l10n.confirmPassword,
            obscureText: true,
          ),
          const Gap(AppSpacing.md),
          AppTextField(controller: _tenantNameController, label: context.l10n.businessName),
          const Gap(AppSpacing.md),
          AppTextField(controller: _storeNameController, label: context.l10n.storeName),
          const Gap(AppSpacing.xl),
          AppButton(
            label: context.l10n.createAccount,
            onPressed: auth.isLoading ? null : _submit,
            isLoading: auth.isLoading,
            isExpanded: true,
          ),
          TextButton(
            onPressed: () => context.go(AuthRoutePaths.login),
            child: Text(context.l10n.haveAccountLogin),
          ),
        ],
      ),
    );
  }
}
