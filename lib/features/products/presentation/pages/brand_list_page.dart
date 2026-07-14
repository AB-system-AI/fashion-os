import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/dialogs/app_dialogs.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/products/domain/entities/brand.dart';
import 'package:fashion_pos_enterprise/features/products/presentation/providers/product_providers.dart';
import 'package:fashion_pos_enterprise/features/products/routing/product_route_paths.dart';

final brandListProvider = FutureProvider<List<Brand>>((ref) async {
  final user = ref.watch(authControllerProvider).user;
  if (user?.tenantId == null) return [];
  final page = await ref.watch(brandRepositoryProvider).getPage(
        RepositoryQuery(tenantId: user!.tenantId!, pageSize: 500, sortBy: 'name'),
      );
  return page.items;
});

class BrandListPage extends ConsumerWidget {
  const BrandListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canRead = ref.watch(permissionCheckProvider(BrandPermissions.read));
    final canManage = ref.watch(permissionCheckProvider(BrandPermissions.manage));
    if (!canRead) {
      return const AppScaffold(body: PermissionDeniedWidget(permission: BrandPermissions.read));
    }

    final brands = ref.watch(brandListProvider);

    return AppScaffold(
      appBar: const AppAppBar(title: Text('Brands')),
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              onPressed: () => context.push(ProductRoutePaths.brandCreate),
              icon: const Icon(Icons.add),
              label: const Text('New Brand'),
            )
          : null,
      body: brands.when(
        loading: () => const AppStateView(isLoading: true, error: null, isEmpty: false, child: SizedBox()),
        error: (e, _) => AppStateView(isLoading: false, error: e.toString(), isEmpty: false, onRetry: () => ref.invalidate(brandListProvider), child: const SizedBox()),
        data: (items) => AppStateView(
          isLoading: false,
          error: null,
          isEmpty: items.isEmpty,
          emptyMessage: 'No brands',
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Gap(AppSpacing.sm),
            itemBuilder: (context, index) {
              final brand = items[index];
              return ListTile(
                leading: CircleAvatar(child: Text(brand.name.isNotEmpty ? brand.name[0].toUpperCase() : '?')),
                title: Text(brand.name),
                subtitle: Text(brand.country ?? brand.description ?? ''),
                trailing: canManage
                    ? PopupMenuButton<String>(
                        onSelected: (action) async {
                          final user = ref.read(authControllerProvider).user;
                          if (user == null) return;
                          final service = ref.read(brandCatalogServiceProvider);
                          switch (action) {
                            case 'edit':
                              context.push(ProductRoutePaths.brandEdit(brand.id));
                            case 'archive':
                              await service.archive(user: user, brand: brand);
                              ref.invalidate(brandListProvider);
                            case 'delete':
                              final ok = await showDeleteDialog(context, itemName: brand.name);
                              if (ok == true) {
                                await service.delete(user: user, brandId: brand.id);
                                ref.invalidate(brandListProvider);
                              }
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'edit', child: Text('Edit')),
                          PopupMenuItem(value: 'archive', child: Text('Archive')),
                          PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                      )
                    : Icon(brand.isActive ? Icons.check_circle_outline : Icons.pause_circle_outline),
                onTap: canManage ? () => context.push(ProductRoutePaths.brandEdit(brand.id)) : null,
              );
            },
          ),
        ),
      ),
    );
  }
}
