/// Product catalog status lifecycle.
enum ProductStatus {
  active,
  inactive,
  archived,
  draft;

  String get value => name;

  static ProductStatus fromValue(String? value) {
    return ProductStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ProductStatus.draft,
    );
  }
}

/// Sort options for product list.
enum ProductSortField {
  name,
  price,
  stock,
  createdAt,
  updatedAt,
  popularity;

  String get value => name;
}

/// Filter criteria for product queries.
enum ProductFilterField {
  category,
  brand,
  status,
  minPrice,
  maxPrice,
  inStock,
  tags,
  createdAfter,
  updatedAfter,
}
