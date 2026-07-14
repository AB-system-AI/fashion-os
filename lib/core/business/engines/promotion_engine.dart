import 'package:collection/collection.dart';

import 'package:fashion_pos_enterprise/core/business/domain/entities/promotion_models.dart';
import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/business/domain/value_objects/money.dart';
import 'package:fashion_pos_enterprise/core/business/engines/discount_engine.dart';
import 'package:fashion_pos_enterprise/core/business/events/business_events.dart';
import 'package:fashion_pos_enterprise/core/business/events/domain_event_bus.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';

/// Evaluates and applies promotions with conflict resolution.
class PromotionEngine {
  PromotionEngine({
    List<Promotion> promotions = const [],
    DomainEventBus? eventBus,
    DiscountEngine? discountEngine,
    this.defaultConflictStrategy = PromotionConflictStrategy.highestPriority,
  })  : _promotions = List.of(promotions),
        _eventBus = eventBus,
        _discountEngine = discountEngine ?? DiscountEngine();

  final List<Promotion> _promotions;
  final DomainEventBus? _eventBus;
  final DiscountEngine _discountEngine;
  final PromotionConflictStrategy defaultConflictStrategy;

  void registerPromotion(Promotion promotion) => _promotions.add(promotion);

  Result<CouponValidation> validateCoupon(String couponCode, DateTime at) {
    final promo = _promotions.firstWhereOrNull(
      (p) => p.couponCode?.toUpperCase() == couponCode.toUpperCase() && p.isValidAt(at),
    );
    if (promo == null) {
      return Success(CouponValidation(isValid: false, couponCode: couponCode, message: 'Invalid or expired coupon'));
    }
    return Success(CouponValidation(isValid: true, couponCode: couponCode, promotionId: promo.id));
  }

  Result<List<AppliedDiscount>> applyPromotions({
    required List<DiscountLineItem> lines,
    String? couponCode,
    String? customerId,
    DateTime? evaluatedAt,
  }) {
    final at = evaluatedAt ?? DateTime.now().toUtc();
    final eligible = _promotions.where((p) {
      if (!p.isValidAt(at)) return false;
      if (p.couponCode != null && p.couponCode!.toUpperCase() != couponCode?.toUpperCase()) {
        return false;
      }
      if (p.customerIds.isNotEmpty && customerId != null && !p.customerIds.contains(customerId)) {
        return false;
      }
      return true;
    }).toList();

    if (eligible.isEmpty) return Success<List<AppliedDiscount>>([]);

    final resolved = _resolveConflicts(eligible);
    final discounts = <AppliedDiscount>[];

    for (final promo in resolved) {
      for (final line in lines) {
        if (!_lineMatchesPromotion(line, promo)) continue;
        final discount = _applyPromotion(promo, line);
        if (discount != null) {
          discounts.add(discount);
          _eventBus?.publish(
            PromotionAppliedEvent(
              eventId: '${promo.id}_${line.lineId}',
              occurredAt: at,
              promotionId: promo.id,
              discountMinor: discount.amount.minorUnits,
            ),
          );
        }
      }
    }

    return Success(discounts);
  }

  List<Promotion> _resolveConflicts(List<Promotion> promotions) {
    if (promotions.length <= 1) return promotions;

    final strategy = promotions.first.conflictStrategy;
    return switch (strategy) {
      PromotionConflictStrategy.highestPriority => [
          promotions.reduce((a, b) => a.priority >= b.priority ? a : b),
        ],
      PromotionConflictStrategy.bestForCustomer => promotions,
      PromotionConflictStrategy.stackable => promotions.where((p) => p.isStackable).toList(),
      PromotionConflictStrategy.exclusive => [promotions.first],
    };
  }

  bool _lineMatchesPromotion(DiscountLineItem line, Promotion promo) {
    if (promo.categoryIds.isNotEmpty && !promo.categoryIds.contains(line.categoryId)) return false;
    if (promo.brandIds.isNotEmpty && !promo.brandIds.contains(line.brandId)) return false;
    return true;
  }

  AppliedDiscount? _applyPromotion(Promotion promo, DiscountLineItem line) {
    return switch (promo.discountType) {
      DiscountType.percentage => _applyPercentagePromotion(promo, line),
      DiscountType.fixedAmount => _applyFixedPromotion(promo, line),
      DiscountType.buyXGetY => _buyXGetY(promo, line),
      _ => null,
    };
  }

  AppliedDiscount? _applyPercentagePromotion(Promotion promo, DiscountLineItem line) {
    final percent = promo.percentOff ?? 0;
    if (percent <= 0) return null;
    final result = _discountEngine.applyPercentage(
      discountId: promo.id,
      line: line,
      percentOff: percent,
      description: promo.name,
    );
    if (result.isFailure) return null;
    final applied = result.dataOrNull!;
    return AppliedDiscount(
      discountId: applied.discountId,
      discountType: applied.discountType,
      amount: applied.amount,
      promotionId: promo.id,
      couponCode: promo.couponCode,
      lineId: applied.lineId,
      description: applied.description,
    );
  }

  AppliedDiscount? _applyFixedPromotion(Promotion promo, DiscountLineItem line) {
    final fixed = promo.fixedAmountOff;
    if (fixed == null || fixed.isZero || fixed.isNegative) return null;
    final result = _discountEngine.applyFixed(
      discountId: promo.id,
      line: line,
      fixedOff: fixed,
      description: promo.name,
    );
    if (result.isFailure) return null;
    final applied = result.dataOrNull!;
    return AppliedDiscount(
      discountId: applied.discountId,
      discountType: applied.discountType,
      amount: applied.amount,
      promotionId: promo.id,
      lineId: applied.lineId,
      description: applied.description,
    );
  }

  AppliedDiscount? _buyXGetY(Promotion promo, DiscountLineItem line) {
    final buy = promo.buyQuantity;
    final get = promo.getQuantity;
    if (buy == null || get == null || line.quantity < buy + get) return null;
    final freeUnits = (line.quantity / (buy + get)).floor() * get;
    final perUnit = line.unitPrice;
    return AppliedDiscount(
      discountId: promo.id,
      discountType: DiscountType.buyXGetY,
      amount: perUnit * freeUnits,
      promotionId: promo.id,
      lineId: line.lineId,
      description: 'Buy $buy Get $get',
    );
  }
}
