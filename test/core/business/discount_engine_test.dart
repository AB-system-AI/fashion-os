import 'package:fashion_pos_enterprise/core/business/domain/entities/promotion_models.dart';
import 'package:fashion_pos_enterprise/core/business/domain/value_objects/money.dart';
import 'package:fashion_pos_enterprise/core/business/engines/discount_engine.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DiscountEngine', () {
    late DiscountEngine engine;
    late DiscountLineItem line;

    setUp(() {
      engine = DiscountEngine();
      line = DiscountLineItem(
        lineId: 'l1',
        productId: 'p1',
        unitPrice: Money.fromMajor(100),
        quantity: 2,
      );
    });

    test('applies percentage discount', () {
      final result = engine.applyPercentage(
        discountId: 'd1',
        line: line,
        percentOff: 10,
      );
      expect((result as Success).data.amount.majorUnits, 20);
    });

    test('rejects invalid percentage', () {
      final result = engine.applyPercentage(
        discountId: 'd1',
        line: line,
        percentOff: 150,
      );
      expect(result.isFailure, isTrue);
    });

    test('applies fixed discount', () {
      final result = engine.applyFixed(
        discountId: 'd2',
        line: line,
        fixedOff: Money.fromMajor(50),
      );
      expect((result as Success).data.amount.majorUnits, 50);
    });

    test('rejects fixed discount exceeding line total', () {
      final result = engine.applyFixed(
        discountId: 'd2',
        line: line,
        fixedOff: Money.fromMajor(500),
      );
      expect(result.isFailure, isTrue);
    });

    test('sums multiple discounts', () {
      final discounts = [
        engine.applyPercentage(discountId: 'd1', line: line, percentOff: 10).dataOrNull!,
        engine.applyFixed(discountId: 'd2', line: line, fixedOff: Money.fromMajor(10)).dataOrNull!,
      ];
      expect(engine.sumDiscounts(discounts).majorUnits, 30);
    });
  });
}
