import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/entities/workflow.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/enums/automation_enums.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/value_objects/automation_value_objects.dart';
import 'package:fashion_pos_enterprise/features/automation/presentation/providers/automation_providers.dart';

class WorkflowListPage extends ConsumerStatefulWidget {
  const WorkflowListPage({super.key});

  @override
  ConsumerState<WorkflowListPage> createState() => _WorkflowListPageState();
}

class _WorkflowListPageState extends ConsumerState<WorkflowListPage> {
  List<AutomationWorkflow> _items = const [];
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
    final page = await ref.read(workflowAutomationServiceProvider).list(user!.tenantId!);
    if (!mounted) return;
    setState(() {
      _items = page.items;
      _loading = false;
    });
  }

  Future<void> _createSample() async {
    final user = ref.read(authControllerProvider).user;
    if (user == null) return;
    await ref.read(workflowAutomationServiceProvider).create(
          user: user,
          name: 'Order Approval Flow',
          steps: const [
            WorkflowStepInput(name: 'Validate', stepType: WorkflowStepType.condition, stepOrder: 0),
            WorkflowStepInput(name: 'Approve', stepType: WorkflowStepType.approval, stepOrder: 1, requiredRole: 'manager'),
            WorkflowStepInput(name: 'Notify', stepType: WorkflowStepType.notification, stepOrder: 2),
          ],
          trigger: TriggerEventType.entityCreated,
          triggerEntityType: 'sales_order',
        );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final allowed = ref.watch(permissionCheckProvider(AutomationPermissions.view));
    if (!allowed) return const AppScaffold(body: PermissionDeniedWidget(permission: AutomationPermissions.view));
    final canManage = ref.watch(permissionCheckProvider(WorkflowPermissions.manage));
    return AppScaffold(
      appBar: const AppAppBar(title: Text('Workflows')),
      floatingActionButton: canManage ? FloatingActionButton.extended(onPressed: _createSample, icon: const Icon(Icons.add), label: const Text('New')) : null,
      body: _loading
          ? const AppLoadingWidget()
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (_, i) {
                  final w = _items[i];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.account_tree),
                      title: Text(w.name),
                      subtitle: Text('${w.status.value} · ${w.triggerEvent.value}'),
                      trailing: Chip(label: Text(w.status.value)),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
