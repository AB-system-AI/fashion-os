import 'package:fashion_pos_enterprise/core/business/domain/entities/promotion_models.dart';
import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/business/domain/value_objects/money.dart';
import 'package:fashion_pos_enterprise/core/business/engines/promotion_engine.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PromotionEngine guards', () {
    late PromotionEngine engine;
    late DiscountLineItem line;

    setUp(() {
      engine = PromotionEngine();
      line = DiscountLineItem(
        lineId: 'l1',
        productId: 'p1',
        unitPrice: Money.fromMajor(40),
        quantity: 1,
      );
    });

    test('ignores zero percent promotion', () {
      engine.registerPromotion(
        const Promotion(
          id: 'zero',
          name: '0%',
          discountType: DiscountType.percentage,
          priority: 1,
          percentOff: 0,
        ),
      );

      final result = engine.applyPromotions(lines: [line]);
      expect((result as Success<List<AppliedDiscount>>).data, isEmpty);
    });

    test('ignores fixed promotion exceeding line total via DiscountEngine', () {
      engine.registerPromotion(
        Promotion(
          id: 'too-big',
          name: 'Too big',
          discountType: DiscountType.fixedAmount,
          priority: 1,
          fixedAmountOff: Money.fromMajor(100),
        ),
      );

      final result = engine.applyPromotions(lines: [line]);
      expect((result as Success<List<AppliedDiscount>>).data, isEmpty);
    });

    test('ignores zero fixed promotion', () {
      engine.registerPromotion(
        Promotion(
          id: 'zero-fixed',
          name: 'Zero',
          discountType: DiscountType.fixedAmount,
          priority: 1,
          fixedAmountOff: Money.fromMajor(0),
        ),
      );

      final result = engine.applyPromotions(lines: [line]);
      expect((result as Success<List<AppliedDiscount>>).data, isEmpty);
    });
  });
}
