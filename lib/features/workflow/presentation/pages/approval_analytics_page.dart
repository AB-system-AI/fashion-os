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

class ApprovalAnalyticsPage extends ConsumerWidget {
  const ApprovalAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canView = ref.watch(permissionCheckProvider(ApprovalPermissions.view));
    if (!canView) {
      return const AppScaffold(body: PermissionDeniedWidget(permission: ApprovalPermissions.view));
    }
    final user = ref.watch(authControllerProvider).user;
    return AppScaffold(
      appBar: const AppAppBar(title: Text('Approval Analytics')),
      body: user == null
          ? const Center(child: Text('Not authenticated'))
          : FutureBuilder(
              future: ref.read(approvalExtendedServiceProvider).loadAnalytics(user),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final analytics = snapshot.data?.dataOrNull;
                if (analytics == null) {
                  return const Center(child: Text('Unable to load analytics'));
                }
                return Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppSpacing.md,
                    crossAxisSpacing: AppSpacing.md,
                    children: [
                      _StatCard(label: 'Total requests', value: '${analytics.totalRequests}'),
                      _StatCard(label: 'Approved', value: '${analytics.approvedCount}'),
                      _StatCard(label: 'Rejected', value: '${analytics.rejectedCount}'),
                      _StatCard(
                        label: 'Approval rate',
                        value: '${(analytics.approvalRate * 100).toStringAsFixed(0)}%',
                      ),
                      _StatCard(
                        label: 'Avg resolution',
                        value: '${analytics.avgResolutionHours.toStringAsFixed(0)}h',
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(label, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
