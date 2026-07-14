import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/features/products/domain/entities/product_variant.dart';
import 'package:fashion_pos_enterprise/features/products/domain/enums/product_enums.dart';

/// Input axes for variant matrix generation.
class VariantMatrixInput extends Equatable {
  const VariantMatrixInput({
    this.colors = const [],
    this.sizes = const [],
    this.materials = const [],
    this.patterns = const [],
    this.styles = const [],
    this.customAttributes = const {},
    this.skuPrefix = 'VAR',
    this.baseRetailPrice = 0,
    this.baseCost = 0,
  });

  final List<String> colors;
  final List<String> sizes;
  final List<String> materials;
  final List<String> patterns;
  final List<String> styles;
  final Map<String, List<String>> customAttributes;
  final String skuPrefix;
  final double baseRetailPrice;
  final double baseCost;

  @override
  List<Object?> get props => [colors, sizes, materials, patterns, styles];
}

/// Generates cartesian combinations of variant attributes.
class VariantMatrixGenerator {
  const VariantMatrixGenerator();

  List<ProductVariant> generate(VariantMatrixInput input) {
    final axes = <String, List<String>>{
      if (input.colors.isNotEmpty) 'color': input.colors,
      if (input.sizes.isNotEmpty) 'size': input.sizes,
      if (input.materials.isNotEmpty) 'material': input.materials,
      if (input.patterns.isNotEmpty) 'pattern': input.patterns,
      if (input.styles.isNotEmpty) 'style': input.styles,
      ...input.customAttributes,
    };

    if (axes.isEmpty) return [];

    final combinations = _cartesian(axes);
    final variants = <ProductVariant>[];
    var index = 1;

    for (final combo in combinations) {
      final suffix = combo.values.map((v) => v.replaceAll(' ', '').toUpperCase()).join('-');
      variants.add(
        ProductVariant(
          id: 'draft-$index',
          sku: '${input.skuPrefix}-$suffix',
          color: combo['color'],
          size: combo['size'],
          material: combo['material'],
          pattern: combo['pattern'],
          style: combo['style'],
          retailPriceOverride: input.baseRetailPrice,
          costOverride: input.baseCost,
          status: ProductStatus.draft,
        ),
      );
      index++;
    }
    return variants;
  }

  List<Map<String, String>> _cartesian(Map<String, List<String>> axes) {
    var result = <Map<String, String>>[{}];
    for (final entry in axes.entries) {
      final next = <Map<String, String>>[];
      for (final partial in result) {
        for (final value in entry.value) {
          next.add({...partial, entry.key: value});
        }
      }
      result = next;
    }
    return result;
  }
}
