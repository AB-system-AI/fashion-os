import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/components/app_text_field.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/entities/work_order.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/presentation/providers/manufacturing_providers.dart';

class WorkOrderListPage extends ConsumerStatefulWidget {
  const WorkOrderListPage({super.key});

  @override
  ConsumerState<WorkOrderListPage> createState() => _WorkOrderListPageState();
}

class _WorkOrderListPageState extends ConsumerState<WorkOrderListPage> {
  List<WorkOrder> _items = [];
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
    final page = await ref.read(workOrderRepositoryProvider).getPage(
          RepositoryQuery(tenantId: user!.tenantId!, pageSize: 200),
        );
    if (!mounted) return;
    setState(() {
      _items = page.items;
      _loading = false;
    });
  }

  Future<void> _create() async {
    final user = ref.read(authControllerProvider).user;
    if (user == null) return;
    final data = await showDialog<({String moId, String hours})>(
      context: context,
      builder: (ctx) {
        final mo = TextEditingController();
        final hours = TextEditingController(text: '1');
        return AlertDialog(
          title: const Text('New Work Order'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(controller: mo, label: 'Production Order ID'),
              const Gap(AppSpacing.sm),
              AppTextField(controller: hours, label: 'Planned Hours'),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, (moId: mo.text.trim(), hours: hours.text.trim())), child: const Text('Create')),
          ],
        );
      },
    );
    if (data == null || data.moId.isEmpty) return;
    final now = DateTime.now().toUtc();
    final result = await ref.read(workOrderServiceProvider).create(
          user: user,
          draft: WorkOrder(
            id: '',
            tenantId: user.tenantId!,
            workOrderNumber: '',
            productionOrderId: data.moId,
            plannedHours: double.tryParse(data.hours) ?? 1,
            version: 1,
            createdAt: now,
            updatedAt: now,
            syncStatus: LocalSyncStatus.pending,
            isDirty: true,
          ),
        );
    if (result.isFailure && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.failureOrNull!.message)));
    }
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final canCreate = ref.watch(permissionCheckProvider(ProductionPermissions.create));

    return AppScaffold(
      appBar: const AppAppBar(title: Text('Work Orders')),
      floatingActionButton: canCreate ? FloatingActionButton(onPressed: _create, child: const Icon(Icons.add)) : null,
      body: _loading
          ? const AppLoadingWidget()
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const Gap(AppSpacing.sm),
                itemBuilder: (context, index) {
                  final w = _items[index];
                  return ListTile(
                    title: Text('${w.workOrderNumber} — ${w.status.name}'),
                    subtitle: Text('MO ${w.productionOrderId} • ${w.plannedHours}h planned'),
                  );
                },
              ),
            ),
    );
  }
}
