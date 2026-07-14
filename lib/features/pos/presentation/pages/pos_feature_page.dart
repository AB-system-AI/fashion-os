import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/empty/app_empty_state.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';

class PosFeaturePage extends ConsumerWidget {
  const PosFeaturePage({super.key, required this.title, required this.description, this.permission});

  final String title;
  final String description;
  final String? permission;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (permission != null) {
      final allowed = ref.watch(permissionCheckProvider(permission!));
      if (!allowed) {
        return AppScaffold(body: PermissionDeniedWidget(permission: permission!));
      }
    }

    return AppScaffold(
      appBar: AppAppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: AppSpacing.xl),
            const AppEmptyState(message: 'Use Sales screen and services for full workflow. Offline queue active.'),
          ],
        ),
      ),
    );
  }
}
