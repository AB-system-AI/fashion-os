import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/features/products/domain/enums/product_enums.dart';

/// Product variant (size/color/style) with optional price and stock overrides.
class ProductVariant extends Equatable {
  const ProductVariant({
    required this.id,
    required this.sku,
    this.barcode,
    this.color,
    this.size,
    this.style,
    this.material,
    this.pattern,
    this.customAttributes = const {},
    this.retailPriceOverride,
    this.costOverride,
    this.wholesalePriceOverride,
    this.stockQuantity = 0,
    this.weightGrams,
    this.imageAssetIds = const [],
    this.isActive = true,
    this.status = ProductStatus.active,
  });

  final String id;
  final String sku;
  final String? barcode;
  final String? color;
  final String? size;
  final String? style;
  final String? material;
  final String? pattern;
  final Map<String, String> customAttributes;
  final double? retailPriceOverride;
  final double? costOverride;
  final double? wholesalePriceOverride;
  final double stockQuantity;
  final double? weightGrams;
  final List<String> imageAssetIds;
  final bool isActive;
  final ProductStatus status;

  ProductVariant copyWith({
    String? sku,
    String? barcode,
    String? color,
    String? size,
    String? style,
    String? material,
    String? pattern,
    Map<String, String>? customAttributes,
    double? retailPriceOverride,
    double? costOverride,
    double? wholesalePriceOverride,
    double? stockQuantity,
    double? weightGrams,
    List<String>? imageAssetIds,
    bool? isActive,
    ProductStatus? status,
  }) {
    return ProductVariant(
      id: id,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      color: color ?? this.color,
      size: size ?? this.size,
      style: style ?? this.style,
      material: material ?? this.material,
      pattern: pattern ?? this.pattern,
      customAttributes: customAttributes ?? this.customAttributes,
      retailPriceOverride: retailPriceOverride ?? this.retailPriceOverride,
      costOverride: costOverride ?? this.costOverride,
      wholesalePriceOverride: wholesalePriceOverride ?? this.wholesalePriceOverride,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      weightGrams: weightGrams ?? this.weightGrams,
      imageAssetIds: imageAssetIds ?? this.imageAssetIds,
      isActive: isActive ?? this.isActive,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sku': sku,
        'barcode': barcode,
        'color': color,
        'size': size,
        'style': style,
        'material': material,
        'pattern': pattern,
        'custom_attributes': customAttributes,
        'retail_price_override': retailPriceOverride,
        'cost_override': costOverride,
        'wholesale_price_override': wholesalePriceOverride,
        'stock_quantity': stockQuantity,
        'weight_grams': weightGrams,
        'image_asset_ids': imageAssetIds,
        'is_active': isActive,
        'status': status.value,
      };

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'] as String,
      sku: json['sku'] as String,
      barcode: json['barcode'] as String?,
      color: json['color'] as String?,
      size: json['size'] as String?,
      style: json['style'] as String?,
      material: json['material'] as String?,
      pattern: json['pattern'] as String?,
      customAttributes: Map<String, String>.from(json['custom_attributes'] as Map? ?? {}),
      retailPriceOverride: (json['retail_price_override'] as num?)?.toDouble(),
      costOverride: (json['cost_override'] as num?)?.toDouble(),
      wholesalePriceOverride: (json['wholesale_price_override'] as num?)?.toDouble(),
      stockQuantity: (json['stock_quantity'] as num?)?.toDouble() ?? 0,
      weightGrams: (json['weight_grams'] as num?)?.toDouble(),
      imageAssetIds: List<String>.from(json['image_asset_ids'] as List? ?? []),
      isActive: json['is_active'] as bool? ?? true,
      status: ProductStatus.fromValue(json['status'] as String?),
    );
  }

  @override
  List<Object?> get props => [id, sku, barcode];
}

/// Product dimensions in centimeters.
class ProductDimensions extends Equatable {
  const ProductDimensions({this.lengthCm, this.widthCm, this.heightCm});

  final double? lengthCm;
  final double? widthCm;
  final double? heightCm;

  Map<String, dynamic> toJson() => {
        'length_cm': lengthCm,
        'width_cm': widthCm,
        'height_cm': heightCm,
      };

  factory ProductDimensions.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ProductDimensions();
    return ProductDimensions(
      lengthCm: (json['length_cm'] as num?)?.toDouble(),
      widthCm: (json['width_cm'] as num?)?.toDouble(),
      heightCm: (json['height_cm'] as num?)?.toDouble(),
    );
  }

  @override
  List<Object?> get props => [lengthCm, widthCm, heightCm];
}
