import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/entities/notification.dart';
import 'package:fashion_pos_enterprise/features/workflow/presentation/providers/workflow_providers.dart';

class EscalationRulesPage extends ConsumerWidget {
  const EscalationRulesPage({super.key});

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
      appBar: const AppAppBar(title: Text('Escalation Rules')),
      body: FutureBuilder(
        future: ref.read(escalationRuleRepositoryProvider).listActive(user.tenantId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('No escalation rules configured'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, i) => _RuleTile(rule: items[i]),
          );
        },
      ),
    );
  }
}

class _RuleTile extends StatelessWidget {
  const _RuleTile({required this.rule});

  final EscalationRule rule;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.trending_up),
        title: Text(rule.name),
        subtitle: Text('${rule.triggerType.value} · ${rule.timeoutHours}h → ${rule.escalateToRole ?? 'default'}'),
        trailing: rule.isActive ? const Icon(Icons.check_circle, color: Colors.green) : const Icon(Icons.pause_circle),
      ),
    );
  }
}
