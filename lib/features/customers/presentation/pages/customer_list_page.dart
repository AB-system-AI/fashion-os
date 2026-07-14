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
import 'package:fashion_pos_enterprise/features/customers/domain/entities/customer.dart';
import 'package:fashion_pos_enterprise/features/customers/presentation/providers/customer_providers.dart';
import 'package:fashion_pos_enterprise/features/customers/routing/customer_route_paths.dart';

class CustomerListPage extends ConsumerStatefulWidget {
  const CustomerListPage({super.key});

  @override
  ConsumerState<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends ConsumerState<CustomerListPage> {
  List<Customer> _items = [];
  bool _loading = true;
  String _search = '';
  bool _activeOnly = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final user = ref.read(authControllerProvider).user;
    if (user?.tenantId == null) return;
    setState(() => _loading = true);
    final page = await ref.read(customerServiceProvider).list(
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

  @override
  Widget build(BuildContext context) {
    final canCreate = ref.watch(permissionCheckProvider(CustomerPermissions.create));

    return AppScaffold(
      appBar: const AppAppBar(title: Text('Customers')),
      floatingActionButton: canCreate
          ? FloatingActionButton(onPressed: () => context.push(CustomerRoutePaths.create), child: const Icon(Icons.add))
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(child: AppTextField(label: 'Search', onChanged: (v) => _search = v, onSubmitted: (_) => _load())),
                const Gap(AppSpacing.sm),
                FilterChip(label: const Text('Active'), selected: _activeOnly, onSelected: (v) { setState(() => _activeOnly = v); _load(); }),
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
                        final c = _items[index];
                        return ListTile(
                          title: Text(c.fullName),
                          subtitle: Text('${c.customerCode} · ${c.phone ?? c.mobile ?? 'No phone'}'),
                          trailing: Text('${c.loyaltyPoints} pts'),
                          onTap: () => context.push(CustomerRoutePaths.detail(c.id)),
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
