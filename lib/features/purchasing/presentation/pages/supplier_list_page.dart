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
import 'package:fashion_pos_enterprise/features/purchasing/domain/entities/supplier.dart';
import 'package:fashion_pos_enterprise/features/purchasing/presentation/providers/purchasing_providers.dart';
import 'package:fashion_pos_enterprise/features/purchasing/routing/purchasing_route_paths.dart';

class SupplierListPage extends ConsumerStatefulWidget {
  const SupplierListPage({super.key});

  @override
  ConsumerState<SupplierListPage> createState() => _SupplierListPageState();
}

class _SupplierListPageState extends ConsumerState<SupplierListPage> {
  List<Supplier> _items = [];
  bool _loading = true;
  String? _error;
  String _search = '';
  bool _activeOnly = false;

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
    final page = await ref.read(supplierServiceProvider).list(
          tenantId: user!.tenantId!,
          search: _search.isEmpty ? null : _search,
          activeOnly: _activeOnly ? true : null,
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
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('New Supplier'),
          content: AppTextField(controller: controller, label: 'Company Name'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, controller.text), child: const Text('Create')),
          ],
        );
      },
    );
    if (name == null || name.trim().isEmpty) return;
    final now = DateTime.now().toUtc();
    final result = await ref.read(supplierServiceProvider).create(
          user: user,
          draft: Supplier(
            id: '',
            tenantId: user.tenantId!,
            supplierCode: '',
            companyName: name.trim(),
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
    final canCreate = ref.watch(permissionCheckProvider(SupplierPermissions.create));

    return AppScaffold(
      appBar: const AppAppBar(title: Text('Suppliers')),
      floatingActionButton: canCreate ? FloatingActionButton(onPressed: _create, child: const Icon(Icons.add)) : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Search',
                    onChanged: (v) => _search = v,
                    onSubmitted: (_) => _load(),
                  ),
                ),
                const Gap(AppSpacing.sm),
                FilterChip(
                  label: const Text('Active only'),
                  selected: _activeOnly,
                  onSelected: (v) {
                    setState(() => _activeOnly = v);
                    _load();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
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
                            final s = _items[index];
                            return ListTile(
                              title: Text(s.companyName),
                              subtitle: Text('${s.supplierCode} · Balance: ${s.currentBalance.toStringAsFixed(2)}'),
                              trailing: s.active ? null : const Text('Archived'),
                              onTap: () => context.push(PurchasingRoutePaths.supplierDetail(s.id)),
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
