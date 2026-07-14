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

class WorkflowReportsPage extends ConsumerWidget {
  const WorkflowReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canView = ref.watch(permissionCheckProvider(WorkflowAdminPermissions.admin));
    if (!canView) {
      return const AppScaffold(body: PermissionDeniedWidget(permission: WorkflowAdminPermissions.admin));
    }
    final user = ref.watch(authControllerProvider).user;
    return AppScaffold(
      appBar: const AppAppBar(title: Text('Workflow Reports')),
      body: user == null
          ? const Center(child: Text('Not authenticated'))
          : FutureBuilder(
              future: ref.read(workflowReportServiceProvider).loadStatistics(user),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final stats = snapshot.data?.dataOrNull ?? [];
                if (stats.isEmpty) {
                  return const Center(child: Text('No workflow statistics yet'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: stats.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, i) {
                    final s = stats[i];
                    return Card(
                      child: ListTile(
                        title: Text('Template ${s.templateId}'),
                        subtitle: Text(
                          '${s.periodStart.toLocal()} – ${s.periodEnd.toLocal()}\n'
                          '${s.totalExecutions} runs · ${(s.successRate * 100).toStringAsFixed(0)}% success',
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
