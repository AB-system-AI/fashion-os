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
import 'package:fashion_pos_enterprise/features/purchasing/domain/entities/purchase_order.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/enums/purchasing_enums.dart';
import 'package:fashion_pos_enterprise/features/purchasing/presentation/providers/purchasing_providers.dart';
import 'package:fashion_pos_enterprise/features/purchasing/routing/purchasing_route_paths.dart';

class PurchaseOrderListPage extends ConsumerStatefulWidget {
  const PurchaseOrderListPage({super.key});

  @override
  ConsumerState<PurchaseOrderListPage> createState() => _PurchaseOrderListPageState();
}

class _PurchaseOrderListPageState extends ConsumerState<PurchaseOrderListPage> {
  List<PurchaseOrder> _items = [];
  bool _loading = true;
  PurchaseOrderStatus? _filter;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final user = ref.read(authControllerProvider).user;
    if (user?.tenantId == null) return;
    setState(() => _loading = true);
    final page = await ref.read(purchaseOrderServiceProvider).list(
          user: user!,
          tenantId: user.tenantId!,
          status: _filter,
        );
    if (!mounted) return;
    setState(() {
      _loading = false;
      _items = page.items;
    });
  }

  Future<void> _createDraft() async {
    final user = ref.read(authControllerProvider).user;
    if (user?.tenantId == null) return;

    final fields = await showDialog<({String supplierId, String warehouseId})>(
      context: context,
      builder: (ctx) {
        final supplier = TextEditingController();
        final warehouse = TextEditingController();
        return AlertDialog(
          title: const Text('New Purchase Order'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(controller: supplier, label: 'Supplier ID'),
              const Gap(AppSpacing.sm),
              AppTextField(controller: warehouse, label: 'Warehouse ID'),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, (supplierId: supplier.text, warehouseId: warehouse.text)),
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
    if (fields == null || fields.supplierId.isEmpty || fields.warehouseId.isEmpty) return;

    final now = DateTime.now().toUtc();
    final result = await ref.read(purchaseOrderServiceProvider).create(
          user: user!,
          draft: PurchaseOrder(
            id: '',
            tenantId: user.tenantId!,
            supplierId: fields.supplierId.trim(),
            warehouseId: fields.warehouseId.trim(),
            poNumber: '',
            status: PurchaseOrderStatus.draft,
            lines: const [],
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
    final canCreate = ref.watch(permissionCheckProvider(PurchasePermissions.create));

    return AppScaffold(
      appBar: const AppAppBar(title: Text('Purchase Orders')),
      floatingActionButton: canCreate ? FloatingActionButton(onPressed: _createDraft, child: const Icon(Icons.add)) : null,
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _filter == null,
                  onSelected: (_) {
                    setState(() => _filter = null);
                    _load();
                  },
                ),
                ...PurchaseOrderStatus.values.map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.sm),
                    child: FilterChip(
                      label: Text(s.value),
                      selected: _filter == s,
                      onSelected: (_) {
                        setState(() => _filter = s);
                        _load();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const AppLoadingWidget()
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const Gap(AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final o = _items[index];
                        return ListTile(
                          title: Text(o.poNumber),
                          subtitle: Text('${o.status.value} · ${o.grandTotal.toStringAsFixed(2)} ${o.currency}'),
                          trailing: Text('${o.lines.length} lines'),
                          onTap: () => context.push(PurchasingRoutePaths.orderDetail(o.id)),
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
