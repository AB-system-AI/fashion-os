import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/enums/workflow_enums.dart';
import 'package:fashion_pos_enterprise/features/workflow/presentation/providers/workflow_providers.dart';

class WorkflowDesignerPage extends ConsumerStatefulWidget {
  const WorkflowDesignerPage({super.key});

  @override
  ConsumerState<WorkflowDesignerPage> createState() => _WorkflowDesignerPageState();
}

class _WorkflowDesignerPageState extends ConsumerState<WorkflowDesignerPage> {
  final _steps = <String>[];

  @override
  Widget build(BuildContext context) {
    final canView = ref.watch(permissionCheckProvider(WorkflowAdminPermissions.admin));
    if (!canView) {
      return const AppScaffold(body: PermissionDeniedWidget(permission: WorkflowAdminPermissions.admin));
    }
    final user = ref.watch(authControllerProvider).user;
    return AppScaffold(
      appBar: const AppAppBar(title: Text('Workflow Designer')),
      body: user == null
          ? const Center(child: Text('Not authenticated'))
          : FutureBuilder(
              future: ref.read(workflowDesignerServiceProvider).listTemplates(user),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final templates = snapshot.data?.dataOrNull ?? [];
                return ListView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    Text('Templates', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.md),
                    if (templates.isEmpty)
                      const Text('No templates yet. Add steps below to start designing.')
                    else
                      ...templates.map((t) => ListTile(
                            title: Text(t.name),
                            subtitle: Text(t.status.value),
                            trailing: const Icon(Icons.chevron_right),
                          )),
                    const Divider(height: AppSpacing.xl),
                    Text('Step builder', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    FilledButton.icon(
                      onPressed: () => setState(() => _steps.add('Step ${_steps.length + 1}')),
                      icon: const Icon(Icons.add),
                      label: const Text('Add step'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ..._steps.asMap().entries.map((e) => Card(
                          child: ListTile(
                            leading: CircleAvatar(child: Text('${e.key + 1}')),
                            title: Text(e.value),
                            subtitle: Text(WorkflowActionType.approval.value),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => setState(() => _steps.removeAt(e.key)),
                            ),
                          ),
                        )),
                  ],
                );
              },
            ),
    );
  }
}
