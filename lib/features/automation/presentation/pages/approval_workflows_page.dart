import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/entities/approval.dart';
import 'package:fashion_pos_enterprise/features/automation/presentation/providers/automation_providers.dart';

class ApprovalWorkflowsPage extends ConsumerStatefulWidget {
  const ApprovalWorkflowsPage({super.key});

  @override
  ConsumerState<ApprovalWorkflowsPage> createState() => _ApprovalWorkflowsPageState();
}

class _ApprovalWorkflowsPageState extends ConsumerState<ApprovalWorkflowsPage> {
  List<ApprovalRequest> _pending = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final user = ref.read(authControllerProvider).user;
    if (user?.tenantId == null) return;
    setState(() => _loading = true);
    final items = await ref.read(approvalServiceProvider).listPending(user!.tenantId!);
    if (!mounted) return;
    setState(() {
      _pending = items;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final allowed = ref.watch(permissionCheckProvider(AutomationPermissions.view));
    if (!allowed) return const AppScaffold(body: PermissionDeniedWidget(permission: AutomationPermissions.view));
    return AppScaffold(
      appBar: const AppAppBar(title: Text('Approval Workflows')),
      body: _loading
          ? const AppLoadingWidget()
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: _pending.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (_, i) {
                  final r = _pending[i];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.approval),
                      title: Text('${r.targetEntityType ?? 'Entity'} · ${r.status.value}'),
                      subtitle: Text('Workflow ${r.approvalWorkflowId}'),
                      trailing: r.expiresAt != null ? Text('Expires ${r.expiresAt!.toLocal().toString().split(' ').first}') : null,
                    ),
                  );
                },
              ),
            ),
    );
  }
}
