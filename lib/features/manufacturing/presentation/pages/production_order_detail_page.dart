import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/entities/production.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/enums/manufacturing_enums.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/presentation/providers/manufacturing_providers.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/presentation/widgets/manufacturing_audit_timeline.dart';

class ProductionOrderDetailPage extends ConsumerStatefulWidget {
  const ProductionOrderDetailPage({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<ProductionOrderDetailPage> createState() => _ProductionOrderDetailPageState();
}

class _ProductionOrderDetailPageState extends ConsumerState<ProductionOrderDetailPage> {
  ProductionOrder? _order;
  List<dynamic> _lines = [];
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
    final order = await ref.read(productionRepositoryProvider).getById(widget.orderId, tenantId: user!.tenantId);
    final lines = order != null ? await ref.read(productionRepositoryProvider).listLines(user.tenantId!, order.id) : <dynamic>[];
    if (!mounted) return;
    setState(() {
      _order = order;
      _lines = lines;
      _loading = false;
    });
  }

  Future<void> _release() async {
    final user = ref.read(authControllerProvider).user;
    final order = _order;
    if (user == null || order == null) return;
    final result = await ref.read(productionOrderServiceProvider).release(user: user, order: order);
    if (result.isFailure && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.failureOrNull!.message)));
    }
    await _load();
  }

  Future<void> _start() async {
    final user = ref.read(authControllerProvider).user;
    final order = _order;
    if (user == null || order == null) return;
    await ref.read(productionOrderServiceProvider).start(user: user, order: order);
    await _load();
  }

  Future<void> _complete() async {
    final user = ref.read(authControllerProvider).user;
    final order = _order;
    if (user == null || order == null) return;
    await ref.read(productionOrderServiceProvider).complete(user: user, order: order, completedQty: order.plannedQty);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const AppScaffold(body: AppLoadingWidget());
    final order = _order;
    if (order == null) return const AppScaffold(body: AppErrorWidget(message: 'Order not found'));

    final canRelease = ref.watch(permissionCheckProvider(ProductionPermissions.release));
    final canComplete = ref.watch(permissionCheckProvider(ProductionPermissions.complete));

    return AppScaffold(
      appBar: AppAppBar(title: Text(order.orderNumber)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text('Status: ${order.status.name}', style: Theme.of(context).textTheme.titleMedium),
          Text('Product: ${order.productId}'),
          Text('Planned: ${order.plannedQty}  Completed: ${order.completedQty}'),
          const Gap(AppSpacing.lg),
          if (order.status == ProductionStatus.draft && canRelease)
            FilledButton(onPressed: _release, child: const Text('Release (reserve + MRP)')),
          if (order.status == ProductionStatus.released)
            FilledButton(onPressed: _start, child: const Text('Start Production')),
          if (order.status == ProductionStatus.inProgress && canComplete)
            FilledButton(onPressed: _complete, child: const Text('Complete')),
          const Gap(AppSpacing.lg),
          const Text('Material lines', style: TextStyle(fontWeight: FontWeight.bold)),
          ..._lines.map((l) => ListTile(title: Text(l.componentProductId), subtitle: Text('Required ${l.requiredQty}'))),
          const Gap(AppSpacing.lg),
          const Text('Audit', style: TextStyle(fontWeight: FontWeight.bold)),
          ManufacturingAuditTimeline(entityType: ProductionOrder.entityTypeName, entityId: order.id),
        ],
      ),
    );
  }
}
