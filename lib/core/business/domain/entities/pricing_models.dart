import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/business/domain/value_objects/money.dart';

/// Input context for price resolution.
class PricingContext extends Equatable {
  const PricingContext({
    required this.productId,
    required this.baseRetailPrice,
    this.variantId,
    this.costPrice,
    this.customerId,
    this.customerGroupId,
    this.tierLevel,
    this.priceListType = PriceListType.retail,
    this.currencyCode = 'USD',
    this.evaluatedAt,
    this.manualOverridePrice,
    this.categoryId,
    this.brandId,
  });

  final String productId;
  final String? variantId;
  final Money baseRetailPrice;
  final Money? costPrice;
  final String? customerId;
  final String? customerGroupId;
  final int? tierLevel;
  final PriceListType priceListType;
  final String currencyCode;
  final DateTime? evaluatedAt;
  final Money? manualOverridePrice;
  final String? categoryId;
  final String? brandId;

  @override
  List<Object?> get props => [productId, variantId, priceListType, customerGroupId];
}

/// A configurable price rule.
class PriceRule extends Equatable {
  const PriceRule({
    required this.id,
    required this.name,
    required this.priceListType,
    required this.adjustmentPercent,
    this.categoryIds = const [],
    this.brandIds = const [],
    this.customerGroupIds = const [],
    this.tierLevel,
    this.startAt,
    this.endAt,
    this.priority = 0,
    this.isActive = true,
  });

  final String id;
  final String name;
  final PriceListType priceListType;
  final double adjustmentPercent;
  final List<String> categoryIds;
  final List<String> brandIds;
  final List<String> customerGroupIds;
  final int? tierLevel;
  final DateTime? startAt;
  final DateTime? endAt;
  final int priority;
  final bool isActive;

  bool appliesTo(PricingContext context, DateTime at) {
    if (!isActive) return false;
    if (startAt != null && at.isBefore(startAt!)) return false;
    if (endAt != null && at.isAfter(endAt!)) return false;
    if (categoryIds.isNotEmpty && !categoryIds.contains(context.categoryId)) return false;
    if (brandIds.isNotEmpty && !brandIds.contains(context.brandId)) return false;
    if (customerGroupIds.isNotEmpty && !customerGroupIds.contains(context.customerGroupId)) {
      return false;
    }
    if (tierLevel != null && tierLevel != context.tierLevel) return false;
    return priceListType == context.priceListType || priceListType == PriceListType.retail;
  }

  @override
  List<Object?> get props => [id, priceListType, priority];
}

/// Resolved price result with margin metadata.
class PricingResult extends Equatable {
  const PricingResult({
    required this.unitPrice,
    required this.priceListType,
    this.appliedRuleId,
    this.marginPercent,
    this.wasOverridden = false,
  });

  final Money unitPrice;
  final PriceListType priceListType;
  final String? appliedRuleId;
  final double? marginPercent;
  final bool wasOverridden;

  @override
  List<Object?> get props => [unitPrice, priceListType, appliedRuleId];
}
