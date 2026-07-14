import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/entities/approval_template.dart';
import 'package:fashion_pos_enterprise/features/workflow/presentation/providers/workflow_providers.dart';

class ApprovalTemplatesPage extends ConsumerWidget {
  const ApprovalTemplatesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canView = ref.watch(permissionCheckProvider(WorkflowAdminPermissions.admin));
    if (!canView) {
      return const AppScaffold(body: PermissionDeniedWidget(permission: WorkflowAdminPermissions.admin));
    }
    final user = ref.watch(authControllerProvider).user;
    if (user == null) {
      return const AppScaffold(body: Center(child: Text('Not authenticated')));
    }
    return AppScaffold(
      appBar: const AppAppBar(title: Text('Approval Templates')),
      body: FutureBuilder(
        future: ref.read(approvalTemplateRepositoryProvider).listActive(user.tenantId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('No approval templates configured'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, i) => _TemplateTile(template: items[i]),
          );
        },
      ),
    );
  }
}

class _TemplateTile extends StatelessWidget {
  const _TemplateTile({required this.template});

  final ApprovalTemplate template;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.account_tree),
        title: Text(template.name),
        subtitle: Text(template.entityType ?? 'Any entity · min ${template.minApprovers} approvers'),
        trailing: template.isActive ? const Icon(Icons.check_circle, color: Colors.green) : const Icon(Icons.pause_circle),
      ),
    );
  }
}
