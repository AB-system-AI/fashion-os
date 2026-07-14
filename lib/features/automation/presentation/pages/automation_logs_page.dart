import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/entities/execution.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/enums/automation_enums.dart';
import 'package:fashion_pos_enterprise/features/automation/presentation/providers/automation_providers.dart';

class AutomationLogsPage extends ConsumerStatefulWidget {
  const AutomationLogsPage({super.key});

  @override
  ConsumerState<AutomationLogsPage> createState() => _AutomationLogsPageState();
}

class _AutomationLogsPageState extends ConsumerState<AutomationLogsPage> {
  List<AutomationExecution> _items = const [];
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
    final items = await ref.read(automationExecutionRepositoryProvider).listRecent(user!.tenantId!);
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final allowed = ref.watch(permissionCheckProvider(AutomationPermissions.view));
    if (!allowed) return const AppScaffold(body: PermissionDeniedWidget(permission: AutomationPermissions.view));
    return AppScaffold(
      appBar: const AppAppBar(title: Text('Execution Logs')),
      body: _loading
          ? const AppLoadingWidget()
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (_, i) {
                  final e = _items[i];
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        e.status == ExecutionStatus.succeeded ? Icons.check_circle_outline : Icons.error_outline,
                        color: e.status == ExecutionStatus.succeeded ? Colors.green : Colors.red,
                      ),
                      title: Text('${e.triggerEvent.value} · ${e.status.value}'),
                      subtitle: Text(e.targetEntityType ?? e.id),
                      trailing: Text(e.completedAt?.toLocal().toString().split('.').first ?? ''),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
