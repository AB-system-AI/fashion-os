import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/components/semantic_button.dart';
import 'package:fashion_pos_enterprise/design_system/dialogs/app_dialogs.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/products/domain/services/category_catalog_service.dart';
import 'package:fashion_pos_enterprise/features/products/presentation/providers/product_providers.dart';
import 'package:fashion_pos_enterprise/features/products/routing/product_route_paths.dart';

final categoryTreeProvider = FutureProvider<List<CategoryNode>>((ref) async {
  final user = ref.watch(authControllerProvider).user;
  if (user?.tenantId == null) return [];
  return ref.watch(categoryCatalogServiceProvider).tree(user!.tenantId!);
});

class CategoryListPage extends ConsumerWidget {
  const CategoryListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canRead = ref.watch(permissionCheckProvider(CategoryPermissions.read));
    final canManage = ref.watch(permissionCheckProvider(CategoryPermissions.manage));
    if (!canRead) {
      return const AppScaffold(body: PermissionDeniedWidget(permission: CategoryPermissions.read));
    }

    final tree = ref.watch(categoryTreeProvider);

    return AppScaffold(
      appBar: const AppAppBar(title: Text('Categories')),
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              onPressed: () => context.push(ProductRoutePaths.categoryCreate),
              icon: const Icon(Icons.add),
              label: const Text('New Category'),
            )
          : null,
      body: tree.when(
        loading: () => const AppStateView(isLoading: true, error: null, isEmpty: false, child: SizedBox()),
        error: (e, _) => AppStateView(isLoading: false, error: e.toString(), isEmpty: false, onRetry: () => ref.invalidate(categoryTreeProvider), child: const SizedBox()),
        data: (nodes) => AppStateView(
          isLoading: false,
          error: null,
          isEmpty: nodes.isEmpty,
          emptyMessage: 'No categories',
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              for (final node in nodes) _CategoryNodeTile(node: node, depth: 0, canManage: canManage),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryNodeTile extends ConsumerWidget {
  const _CategoryNodeTile({required this.node, required this.depth, required this.canManage});

  final CategoryNode node;
  final int depth;
  final bool canManage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = node.category;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.only(left: AppSpacing.md * (depth + 1)),
          leading: Icon(category.isActive ? Icons.folder_outlined : Icons.folder_off_outlined),
          title: Text(category.name),
          subtitle: Text(category.path ?? ''),
          trailing: canManage
              ? PopupMenuButton<String>(
                  onSelected: (action) async {
                    final user = ref.read(authControllerProvider).user;
                    if (user == null) return;
                    final service = ref.read(categoryCatalogServiceProvider);
                    switch (action) {
                      case 'edit':
                        context.push(ProductRoutePaths.categoryEdit(category.id));
                      case 'child':
                        context.push('${ProductRoutePaths.categoryCreate}?parentId=${category.id}');
                      case 'archive':
                        await service.archive(user: user, category: category);
                        ref.invalidate(categoryTreeProvider);
                      case 'delete':
                        final ok = await showDeleteDialog(context, itemName: category.name);
                        if (ok == true) {
                          await service.delete(user: user, categoryId: category.id);
                          ref.invalidate(categoryTreeProvider);
                        }
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'child', child: Text('Add child')),
                    PopupMenuItem(value: 'archive', child: Text('Archive')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                )
              : null,
        ),
        for (final child in node.children) _CategoryNodeTile(node: child, depth: depth + 1, canManage: canManage),
      ],
    );
  }
}
