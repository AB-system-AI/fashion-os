import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:fashion_pos_enterprise/core/extensions/context_extensions.dart';
import 'package:fashion_pos_enterprise/design_system/breakpoints/responsive_builder.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';

/// Shared auth screen layout with branding panel for tablet/desktop.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    required this.child,
    this.title,
    this.subtitle,
    super.key,
  });

  final Widget child;
  final String? title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveBuilder(
        phone: (ctx) => _AuthFormPanel(
          title: title,
          subtitle: subtitle,
          child: child,
        ),
        tablet: (ctx) => Row(
          children: [
            const Expanded(child: _BrandPanel()),
            Expanded(
              child: _AuthFormPanel(
                title: title,
                subtitle: subtitle,
                child: child,
              ),
            ),
          ],
        ),
        desktop: (ctx) => Row(
          children: [
            const Expanded(flex: 5, child: _BrandPanel()),
            Expanded(
              flex: 4,
              child: _AuthFormPanel(
                title: title,
                subtitle: subtitle,
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.colorScheme.primary,
            context.colorScheme.primaryContainer,
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.storefront, size: 72, color: context.colorScheme.onPrimary),
              const Gap(AppSpacing.xl),
              Text(
                context.l10n.appTitle,
                style: context.textTheme.headlineMedium?.copyWith(
                  color: context.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(AppSpacing.md),
              Text(
                context.l10n.authBrandTagline,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colorScheme.onPrimary.withValues(alpha: 0.85),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthFormPanel extends StatelessWidget {
  const _AuthFormPanel({
    required this.child,
    this.title,
    this.subtitle,
  });

  final Widget child;
  final String? title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (title != null) ...[
                  Text(title!, style: context.textTheme.headlineSmall),
                  if (subtitle != null) ...[
                    const Gap(AppSpacing.sm),
                    Text(
                      subtitle!,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const Gap(AppSpacing.xxl),
                ],
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
