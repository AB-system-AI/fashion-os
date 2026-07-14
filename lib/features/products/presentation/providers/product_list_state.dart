import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/features/products/domain/entities/product.dart';
import 'package:fashion_pos_enterprise/features/products/domain/enums/product_enums.dart';
import 'package:fashion_pos_enterprise/features/products/domain/models/product_list_filters.dart';

class ProductListState extends Equatable {
  const ProductListState({
    this.products = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.sortField = ProductSortField.updatedAt,
    this.page = 1,
    this.totalCount = 0,
    this.selectedIds = const {},
    this.isOffline = false,
    this.selectionMode = false,
    this.filters = const ProductListFilters(),
  });

  final List<Product> products;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final ProductSortField sortField;
  final int page;
  final int totalCount;
  final Set<String> selectedIds;
  final bool isOffline;
  final bool selectionMode;
  final ProductListFilters filters;

  bool get isEmpty => products.isEmpty && !isLoading;

  ProductListState copyWith({
    List<Product>? products,
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? searchQuery,
    ProductSortField? sortField,
    int? page,
    int? totalCount,
    Set<String>? selectedIds,
    bool? isOffline,
    bool? selectionMode,
    ProductListFilters? filters,
    bool clearSelection = false,
  }) {
    return ProductListState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      searchQuery: searchQuery ?? this.searchQuery,
      sortField: sortField ?? this.sortField,
      page: page ?? this.page,
      totalCount: totalCount ?? this.totalCount,
      selectedIds: clearSelection ? {} : (selectedIds ?? this.selectedIds),
      isOffline: isOffline ?? this.isOffline,
      selectionMode: selectionMode ?? this.selectionMode,
      filters: filters ?? this.filters,
    );
  }

  @override
  List<Object?> get props => [products, isLoading, error, searchQuery, page, selectedIds, selectionMode, filters];
}
