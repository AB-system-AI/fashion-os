import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/entities/template.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/enums/automation_enums.dart';
import 'package:fashion_pos_enterprise/features/automation/presentation/providers/automation_providers.dart';

class DocumentTemplatesPage extends ConsumerStatefulWidget {
  const DocumentTemplatesPage({super.key});

  @override
  ConsumerState<DocumentTemplatesPage> createState() => _DocumentTemplatesPageState();
}

class _DocumentTemplatesPageState extends ConsumerState<DocumentTemplatesPage> {
  List<DocumentTemplate> _items = const [];
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
    final items = await ref.read(templateServiceProvider).list(user!.tenantId!);
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  Future<void> _createSample() async {
    final user = ref.read(authControllerProvider).user;
    if (user == null) return;
    await ref.read(templateServiceProvider).create(
          user: user,
          name: 'Order confirmation',
          type: TemplateType.email,
          subject: 'Order {{order_number}} confirmed',
          body: 'Hello {{customer_name}}, your order {{order_number}} has been confirmed.',
          variables: const ['order_number', 'customer_name'],
        );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final allowed = ref.watch(permissionCheckProvider(AutomationPermissions.view));
    if (!allowed) return const AppScaffold(body: PermissionDeniedWidget(permission: AutomationPermissions.view));
    final canManage = ref.watch(permissionCheckProvider(AutomationPermissions.manage));
    return AppScaffold(
      appBar: const AppAppBar(title: Text('Document Templates')),
      floatingActionButton: canManage ? FloatingActionButton.extended(onPressed: _createSample, icon: const Icon(Icons.add), label: const Text('New Template')) : null,
      body: _loading
          ? const AppLoadingWidget()
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (_, i) {
                  final t = _items[i];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.description_outlined),
                      title: Text(t.name),
                      subtitle: Text('${t.templateType.value} · ${t.variables.length} variables'),
                      trailing: Icon(t.isActive ? Icons.check_circle : Icons.pause_circle_outline),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
