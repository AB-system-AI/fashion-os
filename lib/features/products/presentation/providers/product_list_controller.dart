import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/di/enterprise_providers.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/products/domain/entities/product.dart';
import 'package:fashion_pos_enterprise/features/products/domain/enums/product_enums.dart';
import 'package:fashion_pos_enterprise/features/products/domain/models/product_list_filters.dart';
import 'package:fashion_pos_enterprise/features/products/domain/services/product_catalog_service.dart';
import 'package:fashion_pos_enterprise/features/products/presentation/providers/product_list_state.dart';
import 'package:fashion_pos_enterprise/features/products/presentation/providers/product_providers.dart';

class ProductListController extends Notifier<ProductListState> {
  @override
  ProductListState build() {
    Future.microtask(load);
    return const ProductListState(isLoading: true);
  }

  ProductCatalogService get _catalog => ref.read(productCatalogServiceProvider);

  Future<void> load() async {
    final user = ref.read(authControllerProvider).user;
    if (user?.tenantId == null) {
      state = state.copyWith(isLoading: false, error: 'No tenant context');
      return;
    }

    final network = await ref.read(networkMonitorProvider).currentState;
    state = state.copyWith(isLoading: true, clearError: true, isOffline: !network.isOnline);

    final page = await _catalog.list(
      user: user!,
      tenantId: user.tenantId!,
      page: state.page,
      sort: state.sortField,
      advancedFilters: state.filters,
    );
    state = state.copyWith(
      isLoading: false,
      products: page.items,
      totalCount: page.totalCount,
    );
  }

  Future<void> search(String query) async {
    final user = ref.read(authControllerProvider).user;
    if (user?.tenantId == null) return;

    state = state.copyWith(isLoading: true, searchQuery: query, clearError: true);
    if (query.trim().isEmpty) {
      await load();
      return;
    }

    final result = await _catalog.search(tenantId: user.tenantId!, query: query, user: user);
    if (result.isFailure) {
      state = state.copyWith(isLoading: false, error: result.failureOrNull?.message);
      return;
    }

    final ids = result.dataOrNull!.map((r) => r.productId).toSet();
    final products = <Product>[];
    for (final id in ids) {
      final p = await _catalog.getById(id, user: user);
      if (p.isSuccess) products.add(p.dataOrNull!);
    }
    state = state.copyWith(isLoading: false, products: products, totalCount: products.length);
  }

  void toggleSelectionMode() {
    state = state.copyWith(selectionMode: !state.selectionMode, clearSelection: !state.selectionMode);
  }

  void toggleSelection(String id) {
    final next = Set<String>.from(state.selectedIds);
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    state = state.copyWith(selectedIds: next, selectionMode: true);
  }

  void clearSelection() => state = state.copyWith(clearSelection: true, selectionMode: false);

  Future<void> applyFilters(ProductListFilters filters) async {
    state = state.copyWith(filters: filters, page: 1);
    await load();
  }

  Future<void> setSort(ProductSortField field) async {
    state = state.copyWith(sortField: field, page: 1);
    await load();
  }

  Future<void> bulkDelete() async {
    final user = ref.read(authControllerProvider).user;
    if (user == null || state.selectedIds.isEmpty) return;
    await _catalog.bulkDelete(user: user, productIds: state.selectedIds.toList());
    state = state.copyWith(clearSelection: true, selectionMode: false);
    await load();
  }

  Future<void> bulkArchive() async {
    final user = ref.read(authControllerProvider).user;
    if (user == null || state.selectedIds.isEmpty) return;
    await _catalog.bulkArchive(user: user, productIds: state.selectedIds.toList());
    state = state.copyWith(clearSelection: true, selectionMode: false);
    await load();
  }

  Future<void> bulkRestore() async {
    final user = ref.read(authControllerProvider).user;
    if (user == null || state.selectedIds.isEmpty) return;
    await _catalog.bulkRestore(user: user, productIds: state.selectedIds.toList());
    state = state.copyWith(clearSelection: true, selectionMode: false);
    await load();
  }

  Future<void> bulkActivate() async {
    final user = ref.read(authControllerProvider).user;
    if (user == null || state.selectedIds.isEmpty) return;
    await _catalog.bulkActivate(user: user, productIds: state.selectedIds.toList());
    state = state.copyWith(clearSelection: true, selectionMode: false);
    await load();
  }

  Future<void> bulkDeactivate() async {
    final user = ref.read(authControllerProvider).user;
    if (user == null || state.selectedIds.isEmpty) return;
    await _catalog.bulkDeactivate(user: user, productIds: state.selectedIds.toList());
    state = state.copyWith(clearSelection: true, selectionMode: false);
    await load();
  }

  Future<void> deleteSelected() => bulkDelete();

  Future<void> toggleFavorite(Product product) async {
    final user = ref.read(authControllerProvider).user;
    if (user == null) return;
    await _catalog.toggleFavorite(user: user, product: product);
    await load();
  }
}

final productListControllerProvider = NotifierProvider.autoDispose<ProductListController, ProductListState>(
  ProductListController.new,
);
