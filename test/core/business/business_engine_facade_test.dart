import 'package:fashion_pos_enterprise/core/business/business_engine_facade.dart';
import 'package:fashion_pos_enterprise/core/business/domain/entities/pricing_models.dart';
import 'package:fashion_pos_enterprise/core/business/domain/entities/promotion_models.dart';
import 'package:fashion_pos_enterprise/core/business/domain/entities/tax_models.dart';
import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/business/domain/value_objects/money.dart';
import 'package:fashion_pos_enterprise/core/business/engines/discount_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/pricing_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/promotion_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/tax_engine.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BusinessEngineFacade', () {
    late BusinessEngineFacade facade;
    late PromotionEngine promotionEngine;

    setUp(() {
      promotionEngine = PromotionEngine();
      promotionEngine.registerPromotion(
        const Promotion(
          id: 'promo10',
          name: '10% Off',
          discountType: DiscountType.percentage,
          priority: 1,
          percentOff: 10,
        ),
      );

      facade = BusinessEngineFacade(
        pricing: PricingEngine(),
        promotion: promotionEngine,
        discount: DiscountEngine(),
        tax: TaxEngine(),
      );
    });

    test('calculates full sale with promotion and tax', () {
      final line = DiscountLineItem(
        lineId: 'l1',
        productId: 'p1',
        unitPrice: Money.fromMajor(100),
        quantity: 1,
      );

      final result = facade.calculateSale(
        pricingContexts: [
          PricingContext(
            productId: 'p1',
            baseRetailPrice: Money.fromMajor(100),
          ),
        ],
        discountLines: [line],
        taxGroup: TaxGroup(
          id: 'vat',
          name: 'VAT',
          rates: [
            TaxRate(
              id: 'vat20',
              name: 'VAT 20%',
              rate: const Percentage(20),
              category: TaxCategory.vat,
            ),
          ],
        ),
      );

      expect(result, isA<Success<SaleCalculationResult>>());
      final data = (result as Success<SaleCalculationResult>).data;
      expect(data.subtotal.majorUnits, 100);
      expect(data.discountTotal.majorUnits, 10);
      expect(data.taxResult.totalTax.majorUnits, 18);
      expect(data.taxResult.grandTotal.majorUnits, 108);
    });
  });
}
