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
import 'package:fashion_pos_enterprise/features/manufacturing/domain/entities/bom.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/presentation/providers/manufacturing_providers.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/presentation/widgets/manufacturing_audit_timeline.dart';

class BomListPage extends ConsumerStatefulWidget {
  const BomListPage({super.key});

  @override
  ConsumerState<BomListPage> createState() => _BomListPageState();
}

class _BomListPageState extends ConsumerState<BomListPage> {
  List<BillOfMaterial> _items = [];
  List<BillOfMaterial> _filtered = [];
  bool _loading = true;
  String _search = '';
  final _selected = <String>{};

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final user = ref.read(authControllerProvider).user;
    if (user?.tenantId == null) return;
    setState(() => _loading = true);
    final page = await ref.read(bomServiceProvider).list(user!.tenantId!);
    if (!mounted) return;
    setState(() {
      _items = page.items;
      _applyFilter();
      _loading = false;
    });
  }

  void _applyFilter() {
    _filtered = _items.where((b) {
      if (_search.isEmpty) return true;
      final q = _search.toLowerCase();
      return b.code.toLowerCase().contains(q) || b.name.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _create() async {
    final user = ref.read(authControllerProvider).user;
    if (user == null) return;
    final result = await showDialog<({String code, String name, String productId})>(
      context: context,
      builder: (ctx) {
        final code = TextEditingController();
        final name = TextEditingController();
        final product = TextEditingController();
        return AlertDialog(
          title: const Text('New BOM'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(controller: code, label: 'Code'),
              const Gap(AppSpacing.sm),
              AppTextField(controller: name, label: 'Name'),
              const Gap(AppSpacing.sm),
              AppTextField(controller: product, label: 'Finished Product ID'),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, (code: code.text.trim(), name: name.text.trim(), productId: product.text.trim())),
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
    if (result == null || result.code.isEmpty) return;
    final now = DateTime.now().toUtc();
    final created = await ref.read(bomServiceProvider).create(
          user: user,
          bom: BillOfMaterial(
            id: '',
            tenantId: user.tenantId!,
            code: result.code,
            name: result.name.isEmpty ? result.code : result.name,
            finishedProductId: result.productId,
            version: 1,
            createdAt: now,
            updatedAt: now,
            syncStatus: LocalSyncStatus.pending,
            isDirty: true,
          ),
        );
    if (created.isFailure && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(created.failureOrNull!.message)));
    }
    await _load();
  }

  Future<void> _archiveSelected() async {
    final user = ref.read(authControllerProvider).user;
    if (user == null || _selected.isEmpty) return;
    for (final id in _selected) {
      final bom = _items.firstWhere((b) => b.id == id);
      await ref.read(bomServiceProvider).archive(user: user, bom: bom);
    }
    _selected.clear();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final canManage = ref.watch(permissionCheckProvider(BomPermissions.manage));

    return AppScaffold(
      appBar: AppAppBar(
        title: const Text('Bill of Materials'),
        actions: [
          if (_selected.isNotEmpty && canManage)
            IconButton(icon: const Icon(Icons.archive_outlined), onPressed: _archiveSelected, tooltip: 'Archive selected'),
        ],
      ),
      floatingActionButton: canManage ? FloatingActionButton(onPressed: _create, child: const Icon(Icons.add)) : null,
      body: _loading
          ? const AppLoadingWidget()
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: AppTextField(
                    label: 'Search BOMs',
                    onChanged: (v) => setState(() {
                      _search = v;
                      _applyFilter();
                    }),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) => const Gap(AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final b = _filtered[index];
                        return Card(
                          child: ListTile(
                            leading: canManage
                                ? Checkbox(
                                    value: _selected.contains(b.id),
                                    onChanged: (v) => setState(() {
                                      if (v == true) {
                                        _selected.add(b.id);
                                      } else {
                                        _selected.remove(b.id);
                                      }
                                    }),
                                  )
                                : null,
                            title: Text('${b.code} — ${b.name}'),
                            subtitle: Text('Product: ${b.finishedProductId}${b.active ? '' : ' (archived)'}'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _showDetail(b),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _showDetail(BillOfMaterial bom) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        builder: (_, controller) => Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ListView(
            controller: controller,
            children: [
              Text(bom.name, style: Theme.of(ctx).textTheme.titleLarge),
              Text('Code: ${bom.code}'),
              Text('Finished product: ${bom.finishedProductId}'),
              Text('Quantity: ${bom.quantity}'),
              const Gap(AppSpacing.lg),
              const Text('Audit timeline', style: TextStyle(fontWeight: FontWeight.bold)),
              ManufacturingAuditTimeline(entityType: BillOfMaterial.entityTypeName, entityId: bom.id),
            ],
          ),
        ),
      ),
    );
  }
}
