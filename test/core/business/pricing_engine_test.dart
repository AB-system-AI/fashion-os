import 'package:fashion_pos_enterprise/core/business/domain/entities/pricing_models.dart';
import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/business/domain/value_objects/money.dart';
import 'package:fashion_pos_enterprise/core/business/engines/pricing_engine.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PricingEngine', () {
    late PricingEngine engine;

    setUp(() {
      engine = PricingEngine();
    });

    test('resolves retail base price', () {
      final result = engine.resolvePrice(
        PricingContext(
          productId: 'p1',
          baseRetailPrice: Money.fromMajor(100),
        ),
      );
      expect(result, isA<Success<PricingResult>>());
      expect((result as Success<PricingResult>).data.unitPrice.majorUnits, 100);
    });

    test('applies VIP price list multiplier', () {
      final result = engine.resolvePrice(
        PricingContext(
          productId: 'p1',
          baseRetailPrice: Money.fromMajor(100),
          priceListType: PriceListType.vip,
        ),
      );
      expect((result as Success<PricingResult>).data.unitPrice.majorUnits, 90);
    });

    test('manual override takes precedence', () {
      final result = engine.resolvePrice(
        PricingContext(
          productId: 'p1',
          baseRetailPrice: Money.fromMajor(100),
          manualOverridePrice: Money.fromMajor(75),
          costPrice: Money.fromMajor(50),
        ),
      );
      final data = (result as Success<PricingResult>).data;
      expect(data.unitPrice.majorUnits, 75);
      expect(data.wasOverridden, isTrue);
      expect(data.marginPercent, 50);
    });

    test('applies highest priority price rule', () {
      engine.registerRule(
        const PriceRule(
          id: 'r1',
          name: 'Low',
          priceListType: PriceListType.retail,
          adjustmentPercent: 5,
          priority: 1,
        ),
      );
      engine.registerRule(
        const PriceRule(
          id: 'r2',
          name: 'High',
          priceListType: PriceListType.retail,
          adjustmentPercent: 10,
          priority: 10,
        ),
      );

      final result = engine.resolvePrice(
        PricingContext(
          productId: 'p1',
          baseRetailPrice: Money.fromMajor(100),
        ),
      );
      final data = (result as Success<PricingResult>).data;
      expect(data.unitPrice.majorUnits, 110);
      expect(data.appliedRuleId, 'r2');
    });
  });
}
