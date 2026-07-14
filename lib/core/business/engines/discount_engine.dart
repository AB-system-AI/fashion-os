import 'package:fashion_pos_enterprise/core/business/domain/entities/promotion_models.dart';
import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/business/domain/value_objects/money.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';

/// Applies standalone discounts (percentage, fixed) to line items.
class DiscountEngine {
  Result<AppliedDiscount> applyPercentage({
    required String discountId,
    required DiscountLineItem line,
    required double percentOff,
    String? description,
  }) {
    if (percentOff <= 0 || percentOff > 100) {
      return const Error(
        ValidationFailure(message: 'Discount percent must be between 0 and 100', code: 'invalid_discount'),
      );
    }
    final amount = line.lineTotal * (percentOff / 100);
    return Success(
      AppliedDiscount(
        discountId: discountId,
        discountType: DiscountType.percentage,
        amount: amount,
        lineId: line.lineId,
        description: description ?? '$percentOff% off',
      ),
    );
  }

  Result<AppliedDiscount> applyFixed({
    required String discountId,
    required DiscountLineItem line,
    required Money fixedOff,
    String? description,
  }) {
    if (fixedOff.isNegative || fixedOff.isZero) {
      return const Error(
        ValidationFailure(message: 'Fixed discount must be positive', code: 'invalid_discount'),
      );
    }
    if (fixedOff > line.lineTotal) {
      return const Error(
        ValidationFailure(message: 'Discount exceeds line total', code: 'invalid_discount'),
      );
    }
    return Success(
      AppliedDiscount(
        discountId: discountId,
        discountType: DiscountType.fixedAmount,
        amount: fixedOff,
        lineId: line.lineId,
        description: description,
      ),
    );
  }

  Money sumDiscounts(List<AppliedDiscount> discounts) {
    if (discounts.isEmpty) return Money.fromMajor(0);
    return discounts.fold(Money.fromMajor(0), (sum, d) => sum + d.amount);
  }
}
