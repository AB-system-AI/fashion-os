import 'package:fashion_pos_enterprise/core/business/domain/entities/promotion_models.dart';
import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/business/domain/value_objects/money.dart';
import 'package:fashion_pos_enterprise/core/business/engines/promotion_engine.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PromotionEngine', () {
    late PromotionEngine engine;
    late DiscountLineItem line;

    setUp(() {
      engine = PromotionEngine();
      line = DiscountLineItem(
        lineId: 'l1',
        productId: 'p1',
        unitPrice: Money.fromMajor(50),
        quantity: 2,
        categoryId: 'cat1',
      );
    });

    test('applies percentage promotion', () {
      engine.registerPromotion(
        const Promotion(
          id: 'promo1',
          name: '10% Off',
          discountType: DiscountType.percentage,
          priority: 1,
          percentOff: 10,
        ),
      );

      final result = engine.applyPromotions(lines: [line]);
      final discounts = (result as Success<List<AppliedDiscount>>).data;
      expect(discounts, hasLength(1));
      expect(discounts.first.amount.majorUnits, 10);
    });

    test('resolves conflict by highest priority', () {
      engine.registerPromotion(
        const Promotion(
          id: 'low',
          name: '5%',
          discountType: DiscountType.percentage,
          priority: 1,
          percentOff: 5,
        ),
      );
      engine.registerPromotion(
        const Promotion(
          id: 'high',
          name: '20%',
          discountType: DiscountType.percentage,
          priority: 10,
          percentOff: 20,
        ),
      );

      final result = engine.applyPromotions(lines: [line]);
      final discounts = (result as Success<List<AppliedDiscount>>).data;
      expect(discounts, hasLength(1));
      expect(discounts.first.promotionId, 'high');
      expect(discounts.first.amount.majorUnits, 20);
    });

    test('validates coupon code', () {
      engine.registerPromotion(
        const Promotion(
          id: 'coupon1',
          name: 'Coupon',
          discountType: DiscountType.percentage,
          priority: 1,
          percentOff: 15,
          couponCode: 'SAVE15',
        ),
      );

      final valid = engine.validateCoupon('SAVE15', DateTime.now().toUtc());
      expect((valid as Success<CouponValidation>).data.isValid, isTrue);

      final invalid = engine.validateCoupon('WRONG', DateTime.now().toUtc());
      expect((invalid as Success<CouponValidation>).data.isValid, isFalse);
    });

    test('applies buy X get Y', () {
      engine.registerPromotion(
        const Promotion(
          id: 'bogo',
          name: 'Buy 2 Get 1',
          discountType: DiscountType.buyXGetY,
          priority: 1,
          buyQuantity: 2,
          getQuantity: 1,
        ),
      );

      final bogoLine = DiscountLineItem(
        lineId: 'l2',
        productId: 'p2',
        unitPrice: Money.fromMajor(30),
        quantity: 3,
      );

      final result = engine.applyPromotions(lines: [bogoLine]);
      final discounts = (result as Success<List<AppliedDiscount>>).data;
      expect(discounts.first.amount.majorUnits, 30);
    });
  });
}
