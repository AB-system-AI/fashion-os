import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/entities/approval.dart';
import 'package:fashion_pos_enterprise/features/workflow/presentation/providers/workflow_providers.dart';

class ApprovalsDashboardPage extends ConsumerWidget {
  const ApprovalsDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canView = ref.watch(permissionCheckProvider(ApprovalPermissions.view));
    if (!canView) {
      return const AppScaffold(body: PermissionDeniedWidget(permission: ApprovalPermissions.view));
    }
    final user = ref.watch(authControllerProvider).user;
    if (user == null) {
      return const AppScaffold(body: Center(child: Text('Not authenticated')));
    }
    return AppScaffold(
      appBar: const AppAppBar(title: Text('Approvals')),
      body: FutureBuilder(
        future: ref.read(approvalServiceProvider).listPending(user),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final result = snapshot.data;
          if (result == null || result.isFailure) {
            return Center(child: Text(result?.failureOrNull?.message ?? 'Failed to load approvals'));
          }
          final items = result.dataOrNull ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('No pending approvals'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, i) => _ApprovalTile(request: items[i]),
          );
        },
      ),
    );
  }
}

class _ApprovalTile extends StatelessWidget {
  const _ApprovalTile({required this.request});

  final ApprovalRequest request;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.pending_actions),
        title: Text(request.targetEntityType ?? 'Approval request'),
        subtitle: Text('Status: ${request.status.value} · Step ${request.currentStepIndex + 1}'),
        trailing: Text(request.amount?.toStringAsFixed(2) ?? ''),
      ),
    );
  }
}
