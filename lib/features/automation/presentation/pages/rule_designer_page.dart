import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/entities/automation_rule.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/enums/automation_enums.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/value_objects/automation_value_objects.dart';
import 'package:fashion_pos_enterprise/features/automation/presentation/providers/automation_providers.dart';

class RuleDesignerPage extends ConsumerStatefulWidget {
  const RuleDesignerPage({super.key});

  @override
  ConsumerState<RuleDesignerPage> createState() => _RuleDesignerPageState();
}

class _RuleDesignerPageState extends ConsumerState<RuleDesignerPage> {
  List<AutomationRule> _items = const [];
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
    final page = await ref.read(ruleAutomationServiceProvider).list(user!.tenantId!);
    if (!mounted) return;
    setState(() {
      _items = page.items;
      _loading = false;
    });
  }

  Future<void> _createSample() async {
    final user = ref.read(authControllerProvider).user;
    if (user == null) return;
    final result = await ref.read(ruleAutomationServiceProvider).create(
          user: user,
          name: 'Low stock alert',
          trigger: TriggerEventType.entityUpdated,
          triggerEntityType: 'inventory_item',
          condition: const RuleConditionInput(field: 'quantity', operator: 'lessThan', value: 10),
          action: const RuleActionInput(type: 'notify', parameters: {'title': 'Low stock', 'channel': 'inApp'}),
          priority: 10,
        );
    if (result.isSuccess) {
      await ref.read(ruleAutomationServiceProvider).activate(user: user, rule: result.dataOrNull!);
    }
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final allowed = ref.watch(permissionCheckProvider(AutomationPermissions.view));
    if (!allowed) return const AppScaffold(body: PermissionDeniedWidget(permission: AutomationPermissions.view));
    final canManage = ref.watch(permissionCheckProvider(RulePermissions.manage));
    return AppScaffold(
      appBar: const AppAppBar(title: Text('Rule Designer')),
      floatingActionButton: canManage ? FloatingActionButton.extended(onPressed: _createSample, icon: const Icon(Icons.add), label: const Text('New Rule')) : null,
      body: _loading
          ? const AppLoadingWidget()
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (_, i) {
                  final r = _items[i];
                  return Card(
                    child: ListTile(
                      leading: Icon(r.isActive ? Icons.bolt : Icons.bolt_outlined, color: r.isActive ? Colors.amber : null),
                      title: Text(r.name),
                      subtitle: Text('${r.triggerEvent.value} · priority ${r.priority}'),
                      trailing: Chip(label: Text(r.status.value)),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
