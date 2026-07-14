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
import 'package:fashion_pos_enterprise/features/inventory/domain/entities/warehouse.dart';
import 'package:fashion_pos_enterprise/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:fashion_pos_enterprise/features/inventory/routing/inventory_route_paths.dart';

class WarehouseListPage extends ConsumerStatefulWidget {
  const WarehouseListPage({super.key});

  @override
  ConsumerState<WarehouseListPage> createState() => _WarehouseListPageState();
}

class _WarehouseListPageState extends ConsumerState<WarehouseListPage> {
  List<Warehouse> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final user = ref.read(authControllerProvider).user;
    if (user?.tenantId == null) {
      setState(() {
        _loading = false;
        _error = 'No tenant context';
      });
      return;
    }
    setState(() => _loading = true);
    final page = await ref.read(warehouseServiceProvider).list(tenantId: user!.tenantId!);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _items = page.items;
    });
  }

  Future<void> _create() async {
    final user = ref.read(authControllerProvider).user;
    if (user == null) return;
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('New Warehouse'),
          content: AppTextField(controller: controller, label: 'Name'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, controller.text), child: const Text('Create')),
          ],
        );
      },
    );
    if (name == null || name.trim().isEmpty) return;
    final now = DateTime.now().toUtc();
    final result = await ref.read(warehouseServiceProvider).create(
          user: user,
          draft: Warehouse(
            id: '',
            tenantId: user.tenantId!,
            name: name.trim(),
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
    final canCreate = ref.watch(permissionCheckProvider(WarehousePermissions.create));

    return AppScaffold(
      appBar: const AppAppBar(title: Text('Warehouses')),
      floatingActionButton: canCreate
          ? FloatingActionButton(onPressed: _create, child: const Icon(Icons.add))
          : null,
      body: _loading
          ? const AppLoadingWidget()
          : _error != null
              ? AppErrorWidget(message: _error!, onRetry: _load)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const Gap(AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final w = _items[index];
                      return ListTile(
                        title: Text(w.name),
                        subtitle: Text(w.code ?? w.storeId ?? 'No store'),
                        trailing: w.isActive ? null : const Text('Archived'),
                        onTap: () => context.push(InventoryRoutePaths.warehouseDetail(w.id)),
                      );
                    },
                  ),
                ),
    );
  }
}
