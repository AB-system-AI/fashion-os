import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/business/domain/entities/pricing_models.dart';
import 'package:fashion_pos_enterprise/core/business/domain/entities/promotion_models.dart';
import 'package:fashion_pos_enterprise/core/business/domain/entities/tax_models.dart';
import 'package:fashion_pos_enterprise/core/business/domain/value_objects/money.dart';
import 'package:fashion_pos_enterprise/core/business/engines/discount_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/pricing_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/promotion_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/tax_engine.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';

/// Composite sale calculation using pricing, promotions, discounts, and tax engines.
class SaleCalculationResult {
  const SaleCalculationResult({
    required this.linePrices,
    required this.discounts,
    required this.subtotal,
    required this.discountTotal,
    required this.taxResult,
  });

  final List<PricingResult> linePrices;
  final List<AppliedDiscount> discounts;
  final Money subtotal;
  final Money discountTotal;
  final TaxCalculationResult taxResult;
}

/// Orchestrates business engines for order-level calculations.
class BusinessEngineFacade {
  BusinessEngineFacade({
    required PricingEngine pricing,
    required PromotionEngine promotion,
    required DiscountEngine discount,
    required TaxEngine tax,
  })  : _pricing = pricing,
        _promotion = promotion,
        _discount = discount,
        _tax = tax;

  final PricingEngine _pricing;
  final PromotionEngine _promotion;
  final DiscountEngine _discount;
  final TaxEngine _tax;

  Result<SaleCalculationResult> calculateSale({
    required List<PricingContext> pricingContexts,
    required List<DiscountLineItem> discountLines,
    required TaxGroup taxGroup,
    TaxMode taxMode = TaxMode.exclusive,
    String? couponCode,
    String? customerId,
  }) {
    final linePrices = <PricingResult>[];
    for (final ctx in pricingContexts) {
      final result = _pricing.resolvePrice(ctx);
      if (result.isFailure) return Error(result.failureOrNull!);
      linePrices.add((result as Success<PricingResult>).data);
    }

    final promoResult = _promotion.applyPromotions(
      lines: discountLines,
      couponCode: couponCode,
      customerId: customerId,
    );
    if (promoResult.isFailure) return Error(promoResult.failureOrNull!);

    final discounts = (promoResult as Success<List<AppliedDiscount>>).data;
    final subtotal = discountLines.fold(
      Money.fromMajor(0),
      (sum, line) => sum + line.lineTotal,
    );
    final discountTotal = _discount.sumDiscounts(discounts);

    final netLines = discountLines.map((line) {
      final lineDiscounts = discounts.where((d) => d.lineId == line.lineId);
      final lineDiscountAmount = lineDiscounts.fold(
        Money.fromMajor(0),
        (sum, d) => sum + d.amount,
      );
      return TaxableLineItem(
        lineId: line.lineId,
        netAmount: line.lineTotal - lineDiscountAmount,
      );
    }).toList();

    final taxResult = _tax.calculate(
      TaxCalculationRequest(
        lineItems: netLines,
        taxGroup: taxGroup,
        defaultMode: taxMode,
      ),
    );
    if (taxResult.isFailure) return Error(taxResult.failureOrNull!);

    return Success(
      SaleCalculationResult(
        linePrices: linePrices,
        discounts: discounts,
        subtotal: subtotal,
        discountTotal: discountTotal,
        taxResult: (taxResult as Success<TaxCalculationResult>).data,
      ),
    );
  }
}
