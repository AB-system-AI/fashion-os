import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/features/products/domain/enums/product_enums.dart';

/// Advanced product list filters.
class ProductListFilters extends Equatable {
  const ProductListFilters({
    this.categoryId,
    this.brandId,
    this.supplierId,
    this.status,
    this.minPrice,
    this.maxPrice,
    this.minCost,
    this.maxCost,
    this.taxGroupId,
    this.createdAfter,
    this.updatedAfter,
    this.hasImage,
    this.hasVariants,
    this.tags = const [],
  });

  final String? categoryId;
  final String? brandId;
  final String? supplierId;
  final ProductStatus? status;
  final double? minPrice;
  final double? maxPrice;
  final double? minCost;
  final double? maxCost;
  final String? taxGroupId;
  final DateTime? createdAfter;
  final DateTime? updatedAfter;
  final bool? hasImage;
  final bool? hasVariants;
  final List<String> tags;

  Map<String, String> toRepositoryFilters() {
    final map = <String, String>{};
    if (categoryId != null) map['category_id'] = categoryId!;
    if (brandId != null) map['brand_id'] = brandId!;
    if (supplierId != null) map['supplier_id'] = supplierId!;
    if (status != null) map['status'] = status!.value;
    if (taxGroupId != null) map['tax_group_id'] = taxGroupId!;
    return map;
  }

  bool matchesProduct({
    required double retailPrice,
    required double cost,
    required DateTime createdAt,
    required DateTime updatedAt,
    required bool hasImages,
    required bool hasVariantRows,
    required List<String> productTags,
  }) {
    if (minPrice != null && retailPrice < minPrice!) return false;
    if (maxPrice != null && retailPrice > maxPrice!) return false;
    if (minCost != null && cost < minCost!) return false;
    if (maxCost != null && cost > maxCost!) return false;
    if (createdAfter != null && createdAt.isBefore(createdAfter!)) return false;
    if (updatedAfter != null && updatedAt.isBefore(updatedAfter!)) return false;
    if (hasImage == true && !hasImages) return false;
    if (hasImage == false && hasImages) return false;
    if (hasVariants == true && !hasVariantRows) return false;
    if (hasVariants == false && hasVariantRows) return false;
    if (tags.isNotEmpty && !tags.every(productTags.contains)) return false;
    return true;
  }

  ProductListFilters copyWith({
    String? categoryId,
    String? brandId,
    String? supplierId,
    ProductStatus? status,
    double? minPrice,
    double? maxPrice,
    bool clearStatus = false,
  }) {
    return ProductListFilters(
      categoryId: categoryId ?? this.categoryId,
      brandId: brandId ?? this.brandId,
      supplierId: supplierId ?? this.supplierId,
      status: clearStatus ? null : (status ?? this.status),
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minCost: minCost,
      maxCost: maxCost,
      taxGroupId: taxGroupId,
      createdAfter: createdAfter,
      updatedAfter: updatedAfter,
      hasImage: hasImage,
      hasVariants: hasVariants,
      tags: tags,
    );
  }

  @override
  List<Object?> get props => [categoryId, brandId, status, minPrice, maxPrice, hasImage, hasVariants];
}

/// Bulk mutation payload for catalog operations.
class BulkProductUpdate extends Equatable {
  const BulkProductUpdate({
    this.retailPrice,
    this.taxGroupId,
    this.categoryId,
    this.categoryName,
    this.brandId,
    this.brandName,
    this.supplierId,
    this.status,
  });

  final double? retailPrice;
  final String? taxGroupId;
  final String? categoryId;
  final String? categoryName;
  final String? brandId;
  final String? brandName;
  final String? supplierId;
  final ProductStatus? status;

  @override
  List<Object?> get props => [retailPrice, taxGroupId, categoryId, brandId, supplierId, status];
}
