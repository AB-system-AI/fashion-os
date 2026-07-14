import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/products/domain/entities/product_variant.dart';
import 'package:fashion_pos_enterprise/features/products/domain/enums/product_enums.dart';

/// Sellable product aggregate — persisted via syncable_records.
class Product extends Equatable implements SyncableEntity {
  const Product({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.sku,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.storeId,
    this.barcode,
    this.categoryId,
    this.categoryName,
    this.brandId,
    this.brandName,
    this.description,
    this.cost = 0,
    this.retailPrice = 0,
    this.wholesalePrice,
    this.vipPrice,
    this.taxGroupId,
    this.supplierId,
    this.tags = const [],
    this.status = ProductStatus.draft,
    this.weightGrams,
    this.dimensions = const ProductDimensions(),
    this.notes,
    this.imageAssetIds = const [],
    this.variants = const [],
    this.isFavorite = false,
    this.deletedAt,
  });

  static const entityTypeName = 'product';

  @override
  final String id;
  @override
  final String tenantId;
  final String? storeId;
  final String name;
  final String sku;
  final String? barcode;
  final String? categoryId;
  final String? categoryName;
  final String? brandId;
  final String? brandName;
  final String? description;
  final double cost;
  final double retailPrice;
  final double? wholesalePrice;
  final double? vipPrice;
  final String? taxGroupId;
  final String? supplierId;
  final List<String> tags;
  final ProductStatus status;
  final double? weightGrams;
  final ProductDimensions dimensions;
  final String? notes;
  final List<String> imageAssetIds;
  final List<ProductVariant> variants;
  final bool isFavorite;
  @override
  final int version;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final LocalSyncStatus syncStatus;
  @override
  final bool isDirty;

  double get totalStock => variants.fold(0.0, (sum, v) => sum + v.stockQuantity);

  bool get isArchived => status == ProductStatus.archived;

  bool get isActive => status == ProductStatus.active;

  @override
  String get entityType => entityTypeName;

  Product copyWith({
    String? name,
    String? sku,
    String? barcode,
    String? categoryId,
    String? categoryName,
    String? brandId,
    String? brandName,
    String? description,
    double? cost,
    double? retailPrice,
    double? wholesalePrice,
    double? vipPrice,
    String? taxGroupId,
    String? supplierId,
    List<String>? tags,
    ProductStatus? status,
    double? weightGrams,
    ProductDimensions? dimensions,
    String? notes,
    List<String>? imageAssetIds,
    List<ProductVariant>? variants,
    bool? isFavorite,
    int? version,
    DateTime? updatedAt,
    DateTime? deletedAt,
    LocalSyncStatus? syncStatus,
    bool? isDirty,
  }) {
    return Product(
      id: id,
      tenantId: tenantId,
      storeId: storeId,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      brandId: brandId ?? this.brandId,
      brandName: brandName ?? this.brandName,
      description: description ?? this.description,
      cost: cost ?? this.cost,
      retailPrice: retailPrice ?? this.retailPrice,
      wholesalePrice: wholesalePrice ?? this.wholesalePrice,
      vipPrice: vipPrice ?? this.vipPrice,
      taxGroupId: taxGroupId ?? this.taxGroupId,
      supplierId: supplierId ?? this.supplierId,
      tags: tags ?? this.tags,
      status: status ?? this.status,
      weightGrams: weightGrams ?? this.weightGrams,
      dimensions: dimensions ?? this.dimensions,
      notes: notes ?? this.notes,
      imageAssetIds: imageAssetIds ?? this.imageAssetIds,
      variants: variants ?? this.variants,
      isFavorite: isFavorite ?? this.isFavorite,
      version: version ?? this.version,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      isDirty: isDirty ?? this.isDirty,
    );
  }

  @override
  Map<String, dynamic> toPayload() => {
        'id': id,
        'tenant_id': tenantId,
        'store_id': storeId,
        'name': name,
        'sku': sku,
        'barcode': barcode,
        'category_id': categoryId,
        'category_name': categoryName,
        'brand_id': brandId,
        'brand_name': brandName,
        'description': description,
        'cost': cost,
        'retail_price': retailPrice,
        'wholesale_price': wholesalePrice,
        'vip_price': vipPrice,
        'tax_group_id': taxGroupId,
        'supplier_id': supplierId,
        'tags': tags,
        'status': status.value,
        'weight_grams': weightGrams,
        'dimensions': dimensions.toJson(),
        'notes': notes,
        'image_asset_ids': imageAssetIds,
        'variants': variants.map((v) => v.toJson()).toList(),
        'is_favorite': isFavorite,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'deleted_at': deletedAt?.toIso8601String(),
      };

  factory Product.fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return Product(
      id: record.id,
      tenantId: record.tenantId,
      storeId: record.storeId,
      name: json['name'] as String? ?? record.searchName ?? '',
      sku: json['sku'] as String? ?? record.searchSku ?? '',
      barcode: json['barcode'] as String? ?? record.searchBarcode,
      categoryId: json['category_id'] as String?,
      categoryName: json['category_name'] as String?,
      brandId: json['brand_id'] as String?,
      brandName: json['brand_name'] as String?,
      description: json['description'] as String?,
      cost: (json['cost'] as num?)?.toDouble() ?? 0,
      retailPrice: (json['retail_price'] as num?)?.toDouble() ?? 0,
      wholesalePrice: (json['wholesale_price'] as num?)?.toDouble(),
      vipPrice: (json['vip_price'] as num?)?.toDouble(),
      taxGroupId: json['tax_group_id'] as String?,
      supplierId: json['supplier_id'] as String?,
      tags: List<String>.from(json['tags'] as List? ?? []),
      status: ProductStatus.fromValue(json['status'] as String?),
      weightGrams: (json['weight_grams'] as num?)?.toDouble(),
      dimensions: ProductDimensions.fromJson(json['dimensions'] as Map<String, dynamic>?),
      notes: json['notes'] as String?,
      imageAssetIds: List<String>.from(json['image_asset_ids'] as List? ?? []),
      variants: (json['variants'] as List? ?? [])
          .map((v) => ProductVariant.fromJson(Map<String, dynamic>.from(v as Map)))
          .toList(),
      isFavorite: json['is_favorite'] as bool? ?? false,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, sku, version, updatedAt, status];
}
