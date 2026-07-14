import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/business/domain/value_objects/money.dart';

/// Promotion definition.
class Promotion extends Equatable {
  const Promotion({
    required this.id,
    required this.name,
    required this.discountType,
    required this.priority,
    this.percentOff,
    this.fixedAmountOff,
    this.buyQuantity,
    this.getQuantity,
    this.categoryIds = const [],
    this.brandIds = const [],
    this.customerIds = const [],
    this.couponCode,
    this.isStackable = false,
    this.startAt,
    this.endAt,
    this.isActive = true,
    this.conflictStrategy = PromotionConflictStrategy.highestPriority,
  });

  final String id;
  final String name;
  final DiscountType discountType;
  final int priority;
  final double? percentOff;
  final Money? fixedAmountOff;
  final int? buyQuantity;
  final int? getQuantity;
  final List<String> categoryIds;
  final List<String> brandIds;
  final List<String> customerIds;
  final String? couponCode;
  final bool isStackable;
  final DateTime? startAt;
  final DateTime? endAt;
  final bool isActive;
  final PromotionConflictStrategy conflictStrategy;

  bool isValidAt(DateTime at) {
    if (!isActive) return false;
    if (startAt != null && at.isBefore(startAt!)) return false;
    if (endAt != null && at.isAfter(endAt!)) return false;
    return true;
  }

  @override
  List<Object?> get props => [id, discountType, priority];
}

/// Line item for discount/promotion calculation.
class DiscountLineItem extends Equatable {
  const DiscountLineItem({
    required this.lineId,
    required this.productId,
    required this.unitPrice,
    required this.quantity,
    this.categoryId,
    this.brandId,
    this.customerId,
  });

  final String lineId;
  final String productId;
  final Money unitPrice;
  final double quantity;
  final String? categoryId;
  final String? brandId;
  final String? customerId;

  Money get lineTotal => unitPrice * quantity;

  @override
  List<Object?> get props => [lineId, productId, quantity];
}

/// Applied discount on a line or order.
class AppliedDiscount extends Equatable {
  const AppliedDiscount({
    required this.discountId,
    required this.discountType,
    required this.amount,
    this.promotionId,
    this.couponCode,
    this.lineId,
    this.description,
  });

  final String discountId;
  final DiscountType discountType;
  final Money amount;
  final String? promotionId;
  final String? couponCode;
  final String? lineId;
  final String? description;

  @override
  List<Object?> get props => [discountId, amount, lineId];
}

/// Coupon validation result.
class CouponValidation extends Equatable {
  const CouponValidation({
    required this.isValid,
    required this.couponCode,
    this.promotionId,
    this.message,
  });

  final bool isValid;
  final String couponCode;
  final String? promotionId;
  final String? message;

  @override
  List<Object?> get props => [isValid, couponCode];
}
