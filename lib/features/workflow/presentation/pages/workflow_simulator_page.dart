import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/workflow/presentation/providers/workflow_providers.dart';

class WorkflowSimulatorPage extends ConsumerWidget {
  const WorkflowSimulatorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canView = ref.watch(permissionCheckProvider(WorkflowAdminPermissions.admin));
    if (!canView) {
      return const AppScaffold(body: PermissionDeniedWidget(permission: WorkflowAdminPermissions.admin));
    }
    final user = ref.watch(authControllerProvider).user;
    return AppScaffold(
      appBar: const AppAppBar(title: Text('Workflow Simulator')),
      body: user == null
          ? const Center(child: Text('Not authenticated'))
          : Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Dry-run workflow execution', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.md),
                  const TextField(
                    decoration: InputDecoration(labelText: 'Template ID'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const TextField(
                    decoration: InputDecoration(labelText: 'Version ID'),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Select a published template version to simulate')),
                      );
                    },
                    child: const Text('Run simulation'),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Text(
                          'Simulation trace will appear here after running.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
