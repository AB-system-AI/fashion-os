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

class SchedulerDashboardPage extends ConsumerWidget {
  const SchedulerDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canView = ref.watch(permissionCheckProvider(WorkflowAdminPermissions.admin));
    if (!canView) {
      return const AppScaffold(body: PermissionDeniedWidget(permission: WorkflowAdminPermissions.admin));
    }
    final user = ref.watch(authControllerProvider).user;
    return AppScaffold(
      appBar: AppAppBar(
        title: const Text('Scheduler'),
        actions: [
          if (user != null)
            IconButton(
              icon: const Icon(Icons.play_arrow),
              tooltip: 'Process due jobs',
              onPressed: () async {
                final result = await ref.read(schedulerServiceProvider).processDueJobs(user);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Processed ${result.dataOrNull ?? 0} jobs')),
                  );
                }
              },
            ),
        ],
      ),
      body: user == null
          ? const Center(child: Text('Not authenticated'))
          : FutureBuilder(
              future: ref.read(schedulerServiceProvider).loadHealth(user),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final health = snapshot.data?.dataOrNull;
                if (health == null) {
                  return const Center(child: Text('Unable to load scheduler health'));
                }
                return Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppSpacing.md,
                    crossAxisSpacing: AppSpacing.md,
                    children: [
                      _MetricCard(
                        label: 'Status',
                        value: health.isHealthy ? 'Healthy' : 'Degraded',
                        icon: health.isHealthy ? Icons.check_circle : Icons.warning,
                      ),
                      _MetricCard(label: 'Due jobs', value: '${health.dueJobCount}', icon: Icons.schedule),
                      _MetricCard(label: 'Running', value: '${health.runningJobCount}', icon: Icons.sync),
                      _MetricCard(label: 'Failed', value: '${health.failedJobCount}', icon: Icons.error_outline),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: AppSpacing.sm),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
