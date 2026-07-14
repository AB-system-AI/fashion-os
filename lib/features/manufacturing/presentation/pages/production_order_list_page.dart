import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/components/app_text_field.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/entities/production.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/enums/manufacturing_enums.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/presentation/providers/manufacturing_providers.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/routing/manufacturing_route_paths.dart';

class ProductionOrderListPage extends ConsumerStatefulWidget {
  const ProductionOrderListPage({super.key});

  @override
  ConsumerState<ProductionOrderListPage> createState() => _ProductionOrderListPageState();
}

class _ProductionOrderListPageState extends ConsumerState<ProductionOrderListPage> {
  List<ProductionOrder> _items = [];
  bool _loading = true;
  ProductionStatus? _filter;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final user = ref.read(authControllerProvider).user;
    if (user?.tenantId == null) return;
    setState(() => _loading = true);
    final statuses = _filter != null ? [_filter!] : ProductionStatus.values;
    final all = <ProductionOrder>[];
    for (final s in statuses) {
      all.addAll(await ref.read(productionOrderServiceProvider).listByStatus(user!.tenantId!, s));
    }
    if (!mounted) return;
    setState(() {
      _items = all;
      _loading = false;
    });
  }

  Future<void> _create() async {
    final user = ref.read(authControllerProvider).user;
    if (user == null) return;
    final data = await showDialog<({String productId, String qty})>(
      context: context,
      builder: (ctx) {
        final product = TextEditingController();
        final qty = TextEditingController(text: '1');
        return AlertDialog(
          title: const Text('New Production Order'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(controller: product, label: 'Product ID'),
              const Gap(AppSpacing.sm),
              AppTextField(controller: qty, label: 'Planned Qty'),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, (productId: product.text.trim(), qty: qty.text.trim())),
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
    if (data == null || data.productId.isEmpty) return;
    final now = DateTime.now().toUtc();
    final result = await ref.read(productionOrderServiceProvider).create(
          user: user,
          draft: ProductionOrder(
            id: '',
            tenantId: user.tenantId!,
            orderNumber: '',
            productId: data.productId,
            plannedQty: double.tryParse(data.qty) ?? 1,
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
      appBar: const AppAppBar(title: Text('Production Orders')),
      floatingActionButton: canCreate ? FloatingActionButton(onPressed: _create, child: const Icon(Icons.add)) : null,
      body: _loading
          ? const AppLoadingWidget()
          : Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      FilterChip(label: const Text('All'), selected: _filter == null, onSelected: (_) => setState(() { _filter = null; _load(); })),
                      ...ProductionStatus.values.map((s) => Padding(
                            padding: const EdgeInsets.only(left: AppSpacing.sm),
                            child: FilterChip(
                              label: Text(s.name),
                              selected: _filter == s,
                              onSelected: (_) => setState(() { _filter = s; _load(); }),
                            ),
                          )),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const Gap(AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final o = _items[index];
                        return ListTile(
                          title: Text('${o.orderNumber} — ${o.status.name}'),
                          subtitle: Text('Qty ${o.plannedQty} / ${o.completedQty}'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push('${ManufacturingRoutePaths.production}/${o.id}'),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
