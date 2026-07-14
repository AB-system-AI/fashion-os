import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/features/products/domain/services/variant_matrix_generator.dart';

void main() {
  test('generates cartesian product of colors and sizes', () {
    const generator = VariantMatrixGenerator();
    final variants = generator.generate(
      const VariantMatrixInput(
        colors: ['Black', 'White'],
        sizes: ['S', 'M', 'L'],
        skuPrefix: 'TEE',
        baseRetailPrice: 29.99,
      ),
    );
    expect(variants.length, 6);
    expect(variants.first.color, 'Black');
    expect(variants.first.size, 'S');
    expect(variants.first.sku, contains('TEE'));
  });

  test('returns empty list when no axes provided', () {
    const generator = VariantMatrixGenerator();
    expect(generator.generate(const VariantMatrixInput()).isEmpty, isTrue);
  });
}
