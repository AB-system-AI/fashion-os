import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:fashion_pos_enterprise/core/extensions/context_extensions.dart';
import 'package:fashion_pos_enterprise/design_system/components/app_button.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/empty/app_empty_state.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/error_state_widget.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/loading/app_loading_indicator.dart';

/// Offline mode banner state.
class OfflineStateWidget extends StatelessWidget {
  const OfflineStateWidget({this.onRetry, super.key});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 64, color: context.colorScheme.outline),
            const Gap(AppSpacing.lg),
            Text('You are offline', style: context.textTheme.titleMedium),
            const Gap(AppSpacing.sm),
            Text(
              'Changes are saved locally and will sync when connection returns.',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium,
            ),
            if (onRetry != null) ...[
              const Gap(AppSpacing.xl),
              AppButton(label: 'Retry', onPressed: onRetry, icon: Icons.refresh),
            ],
          ],
        ),
      ),
    );
  }
}

/// Permission denied state.
class PermissionDeniedWidget extends StatelessWidget {
  const PermissionDeniedWidget({this.permission, super.key});

  final String? permission;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, size: 64, color: context.colorScheme.error),
            const Gap(AppSpacing.lg),
            Text('Access denied', style: context.textTheme.titleMedium),
            if (permission != null)
              Text(permission!, style: context.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

/// Unified async content state renderer.
class AppStateView extends StatelessWidget {
  const AppStateView({
    required this.isLoading,
    required this.error,
    required this.isEmpty,
    required this.child,
    this.emptyMessage,
    this.onRetry,
    this.isOffline = false,
    super.key,
  });

  final bool isLoading;
  final String? error;
  final bool isEmpty;
  final Widget child;
  final String? emptyMessage;
  final VoidCallback? onRetry;
  final bool isOffline;

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const LoadingStateWidget();
    if (isOffline && error != null) return OfflineStateWidget(onRetry: onRetry);
    if (error != null) {
      return ErrorStateWidget(message: error, onRetry: onRetry);
    }
    if (isEmpty) {
      return AppEmptyState(message: emptyMessage ?? 'No items found');
    }
    return child;
  }
}

/// Full-screen loading placeholder used by feature pages.
class AppLoadingWidget extends StatelessWidget {
  const AppLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) => const AppLoadingIndicator();
}

/// Full-screen error placeholder used by feature pages.
class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({required this.message, this.onRetry, super.key});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => ErrorStateWidget(message: message, onRetry: onRetry);
}
