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
import 'package:fashion_pos_enterprise/features/purchasing/domain/entities/purchase_return.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/enums/purchasing_enums.dart';
import 'package:fashion_pos_enterprise/features/purchasing/presentation/providers/purchasing_providers.dart';

class PurchaseReturnListPage extends ConsumerStatefulWidget {
  const PurchaseReturnListPage({super.key});

  @override
  ConsumerState<PurchaseReturnListPage> createState() => _PurchaseReturnListPageState();
}

class _PurchaseReturnListPageState extends ConsumerState<PurchaseReturnListPage> {
  List<PurchaseReturn> _items = [];
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
    final page = await ref.read(purchaseReturnRepositoryProvider).getPage(
          RepositoryQuery(tenantId: user!.tenantId!, pageSize: 100, sortBy: 'updated_at'),
        );
    if (!mounted) return;
    setState(() {
      _loading = false;
      _items = page.items;
    });
  }

  Future<void> _create() async {
    final user = ref.read(authControllerProvider).user;
    if (user == null) return;
    final fields = await showDialog<({String supplierId, String warehouseId})>(
      context: context,
      builder: (ctx) {
        final supplier = TextEditingController();
        final warehouse = TextEditingController();
        return AlertDialog(
          title: const Text('New Return'),
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
    if (fields == null || fields.supplierId.isEmpty) return;
    final now = DateTime.now().toUtc();
    await ref.read(purchaseReturnServiceProvider).create(
          user: user,
          draft: PurchaseReturn(
            id: '',
            tenantId: user.tenantId!,
            supplierId: fields.supplierId.trim(),
            warehouseId: fields.warehouseId.trim(),
            returnNumber: '',
            status: PurchaseReturnStatus.draft,
            lines: const [],
            version: 1,
            createdAt: now,
            updatedAt: now,
            syncStatus: LocalSyncStatus.pending,
            isDirty: true,
          ),
        );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final canCreate = ref.watch(permissionCheckProvider(PurchasePermissions.returnCreate));

    return AppScaffold(
      appBar: const AppAppBar(title: Text('Purchase Returns')),
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
                  final r = _items[index];
                  return ListTile(
                    title: Text(r.returnNumber),
                    subtitle: Text('${r.status.value} · ${r.totalAmount.toStringAsFixed(2)}'),
                    trailing: Text('${r.lines.length} lines'),
                  );
                },
              ),
            ),
    );
  }
}
