import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/sales/domain/entities/quotation.dart';
import 'package:fashion_pos_enterprise/features/sales/domain/value_objects/sales_value_objects.dart';
import 'package:fashion_pos_enterprise/features/sales/presentation/providers/sales_providers.dart';
import 'package:fashion_pos_enterprise/features/sales/routing/sales_route_paths.dart';

class QuotationListPage extends ConsumerStatefulWidget {
  const QuotationListPage({super.key});

  @override
  ConsumerState<QuotationListPage> createState() => _QuotationListPageState();
}

class _QuotationListPageState extends ConsumerState<QuotationListPage> {
  List<Quotation> _items = const [];
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
    final page = await ref.read(quotationServiceProvider).list(user!.tenantId!);
    if (!mounted) return;
    setState(() {
      _items = page.items;
      _loading = false;
    });
  }

  Future<void> _createSample() async {
    final user = ref.read(authControllerProvider).user;
    if (user == null) return;
    await ref.read(quotationServiceProvider).create(
          user: user,
          customerId: 'sample-customer',
          lines: const [QuotationLineInput(productId: 'product-1', quantity: 2, unitPrice: 99.99, taxRate: 10)],
        );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final allowed = ref.watch(permissionCheckProvider(SalesOmsPermissions.view));
    if (!allowed) return const AppScaffold(body: PermissionDeniedWidget(permission: SalesOmsPermissions.view));
    final canCreate = ref.watch(permissionCheckProvider(QuotationPermissions.create));
    return AppScaffold(
      appBar: const AppAppBar(title: Text('Quotations')),
      floatingActionButton: canCreate ? FloatingActionButton.extended(onPressed: _createSample, icon: const Icon(Icons.add), label: const Text('New')) : null,
      body: _loading
          ? const AppLoadingWidget()
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (_, i) {
                  final q = _items[i];
                  return Card(
                    child: ListTile(
                      title: Text(q.quotationNumber),
                      subtitle: Text('${q.status.value} · ${q.grandTotal.toStringAsFixed(2)}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push(SalesRoutePaths.quotationDetail(q.id)),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
