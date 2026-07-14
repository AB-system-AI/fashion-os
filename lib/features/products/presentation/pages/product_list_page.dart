import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/breakpoints/app_breakpoints.dart';
import 'package:fashion_pos_enterprise/design_system/breakpoints/responsive_builder.dart';
import 'package:fashion_pos_enterprise/design_system/components/catalog_cards.dart';
import 'package:fashion_pos_enterprise/design_system/components/catalog_inputs.dart';
import 'package:fashion_pos_enterprise/design_system/components/semantic_button.dart';
import 'package:fashion_pos_enterprise/design_system/dialogs/app_dialogs.dart';
import 'package:fashion_pos_enterprise/design_system/sheets/app_bottom_sheets.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/catalog/bulk_action_toolbar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/search/product_filter_panel.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/products/domain/enums/product_enums.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/search/filter_chip_bar.dart';
import 'package:fashion_pos_enterprise/features/products/domain/models/product_list_filters.dart';
import 'package:fashion_pos_enterprise/features/products/presentation/providers/product_list_controller.dart';
import 'package:fashion_pos_enterprise/features/products/presentation/providers/product_list_state.dart';
import 'package:fashion_pos_enterprise/features/products/routing/product_route_paths.dart';

/// Product catalog list — offline-first, no business logic in UI.
class ProductListPage extends ConsumerWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canRead = ref.watch(permissionCheckProvider(ProductPermissions.read));
    if (!canRead) {
      return const AppScaffold(
        body: PermissionDeniedWidget(permission: ProductPermissions.read),
      );
    }

    final state = ref.watch(productListControllerProvider);
    final controller = ref.read(productListControllerProvider.notifier);
    final canCreate = ref.watch(permissionCheckProvider(ProductPermissions.create));

    return AppScaffold(
      appBar: AppAppBar(
        title: const Text('Products'),
        actions: [
          if (state.selectedIds.isNotEmpty)
            SemanticIconButton(
              icon: Icons.delete_outline,
              tooltip: 'Delete selected',
              onPressed: () async {
                final ok = await showDeleteDialog(
                  context,
                  itemName: '${state.selectedIds.length} products',
                );
                if (ok == true) await controller.deleteSelected();
              },
            ),
          SemanticIconButton(
            icon: Icons.filter_list,
            tooltip: 'Filters',
            onPressed: () async {
              await showFilterSheet(
                context: context,
                title: 'Advanced Filters',
                children: [
                  ProductFilterPanel(
                    initial: state.filters,
                    onApply: (filters) {
                      Navigator.pop(context);
                      controller.applyFilters(filters);
                    },
                  ),
                ],
              );
            },
          ),
          SemanticIconButton(icon: Icons.category_outlined, tooltip: 'Categories', onPressed: () => context.push(ProductRoutePaths.categories)),
          SemanticIconButton(icon: Icons.storefront_outlined, tooltip: 'Brands', onPressed: () => context.push(ProductRoutePaths.brands)),
          SemanticIconButton(
            icon: Icons.sort,
            tooltip: 'Sort',
            onPressed: () async {
              final sort = await showSortSheet(
                context: context,
                options: ProductSortField.values.map((e) => e.name).toList(),
                selected: state.sortField.name,
              );
              if (sort != null) {
                await controller.setSort(ProductSortField.values.byName(sort));
              }
            },
          ),
          SemanticIconButton(
            icon: Icons.upload_file_outlined,
            tooltip: 'Import',
            onPressed: () => context.push(ProductRoutePaths.import),
          ),
        ],
      ),
      floatingActionButton: canCreate
          ? FloatingActionButton.extended(
              onPressed: () => context.push(ProductRoutePaths.create),
              icon: const Icon(Icons.add),
              label: const Text('New Product'),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: AppSearchField(
              onSearch: controller.search,
              hint: 'Search name, SKU, or barcode…',
            ),
          ),
          FilterChipBar(
            chips: ['All', ...ProductStatus.values.map((e) => e.name)],
            selected: {state.filters.status?.name ?? 'All'},
            onSelected: (chip) {
              if (chip == 'All') {
                controller.applyFilters(const ProductListFilters());
              } else {
                controller.applyFilters(ProductListFilters(status: ProductStatus.values.byName(chip)));
              }
            },
          ),
          if (state.isOffline)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Banner(
                message: 'Offline mode — changes sync when online',
                location: BannerLocation.topStart,
              ),
            ),
          Expanded(
            child: AppStateView(
              isLoading: state.isLoading,
              error: state.error,
              isEmpty: state.isEmpty,
              isOffline: state.isOffline,
              onRetry: controller.load,
              emptyMessage: 'No products yet',
              child: ResponsiveBuilder(
                phone: (context) => _ProductGrid(
                  crossAxisCount: 2,
                  state: state,
                  controller: controller,
                ),
                tablet: (context) => _ProductGrid(
                  crossAxisCount: 4,
                  state: state,
                  controller: controller,
                ),
                desktop: (context) => _ProductGrid(
                  crossAxisCount: AppBreakpoints.isWide(MediaQuery.sizeOf(context).width) ? 6 : 5,
                  state: state,
                  controller: controller,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: BulkActionToolbar(
              selectedCount: state.selectedIds.length,
              onClear: controller.clearSelection,
              actions: [
                BulkAction(label: 'Archive', icon: Icons.archive_outlined, onPressed: controller.bulkArchive),
                BulkAction(label: 'Activate', icon: Icons.check_circle_outline, onPressed: controller.bulkActivate),
                BulkAction(label: 'Deactivate', icon: Icons.pause_circle_outline, onPressed: controller.bulkDeactivate),
                BulkAction(label: 'Delete', icon: Icons.delete_outline, danger: true, onPressed: controller.bulkDelete),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({
    required this.crossAxisCount,
    required this.state,
    required this.controller,
  });

  final int crossAxisCount;
  final ProductListState state;
  final ProductListController controller;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.load,
      child: GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 0.72,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
        ),
        itemCount: state.products.length,
        itemBuilder: (context, index) {
          final product = state.products[index];
          return GestureDetector(
            onLongPress: () => controller.toggleSelection(product.id),
            child: ProductCard(
              title: product.name,
              subtitle: product.sku,
              priceLabel: '\$${product.retailPrice.toStringAsFixed(2)}',
              badge: product.status.name,
              isFavorite: product.isFavorite,
              isSelected: state.selectedIds.contains(product.id),
              onTap: () {
                if (state.selectionMode) {
                  controller.toggleSelection(product.id);
                } else {
                  context.push(ProductRoutePaths.detail(product.id));
                }
              },
              onFavoriteToggle: () => controller.toggleFavorite(product),
            ),
          );
        },
      ),
    );
  }
}
