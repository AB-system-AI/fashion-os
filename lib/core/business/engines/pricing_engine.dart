import 'package:fashion_pos_enterprise/core/business/domain/entities/pricing_models.dart';
import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/business/domain/value_objects/money.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';

/// Resolves unit prices from price lists, rules, tiers, and overrides.
class PricingEngine {
  PricingEngine({List<PriceRule> rules = const []}) : _rules = List.of(rules);

  final List<PriceRule> _rules;

  void registerRule(PriceRule rule) => _rules.add(rule);

  Result<PricingResult> resolvePrice(PricingContext context) {
    final at = context.evaluatedAt ?? DateTime.now().toUtc();

    if (context.manualOverridePrice != null) {
      return Success(
        PricingResult(
          unitPrice: context.manualOverridePrice!,
          priceListType: PriceListType.manualOverride,
          wasOverridden: true,
          marginPercent: _marginPercent(context.manualOverridePrice!, context.costPrice),
        ),
      );
    }

    final applicable = _rules
        .where((r) => r.appliesTo(context, at))
        .toList()
      ..sort((a, b) => b.priority.compareTo(a.priority));

    var price = _basePriceForListType(context);

    String? appliedRuleId;
    if (applicable.isNotEmpty) {
      final rule = applicable.first;
      price = price * (1 + rule.adjustmentPercent / 100);
      appliedRuleId = rule.id;
    }

    if (price.isNegative) {
      return const Error(ValidationFailure(message: 'Resolved price cannot be negative', code: 'invalid_price'));
    }

    return Success(
      PricingResult(
        unitPrice: price,
        priceListType: context.priceListType,
        appliedRuleId: appliedRuleId,
        marginPercent: _marginPercent(price, context.costPrice),
      ),
    );
  }

  Money _basePriceForListType(PricingContext context) {
    return switch (context.priceListType) {
      PriceListType.wholesale => context.baseRetailPrice * 0.85,
      PriceListType.vip => context.baseRetailPrice * 0.9,
      PriceListType.distributor => context.baseRetailPrice * 0.75,
      PriceListType.happyHour => context.baseRetailPrice * 0.8,
      PriceListType.seasonal => context.baseRetailPrice * 0.95,
      _ => context.baseRetailPrice,
    };
  }

  double? _marginPercent(Money sellPrice, Money? costPrice) {
    if (costPrice == null || costPrice.isZero) return null;
    final margin = sellPrice.minorUnits - costPrice.minorUnits;
    return (margin / costPrice.minorUnits) * 100;
  }
}
