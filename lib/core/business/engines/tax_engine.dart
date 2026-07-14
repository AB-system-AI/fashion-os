import 'package:fashion_pos_enterprise/core/business/domain/entities/tax_models.dart';
import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/business/domain/value_objects/money.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';

/// Calculates VAT and multi-rate taxes (inclusive/exclusive, compound).
class TaxEngine {
  Result<TaxCalculationResult> calculate(TaxCalculationRequest request) {
    if (request.taxGroup.rates.isEmpty) {
      return const Error(ValidationFailure(message: 'Tax group has no rates', code: 'invalid_tax'));
    }

    final taxLines = <TaxLine>[];
    var totalNet = Money.fromMajor(0, currencyCode: _currency(request));
    var totalTax = Money.fromMajor(0, currencyCode: _currency(request));

    for (final line in request.lineItems) {
      if (line.isTaxExempt) {
        totalNet = totalNet + line.netAmount;
        continue;
      }

      var lineNet = line.netAmount;
      var lineTax = Money.fromMajor(0, currencyCode: _currency(request));

      for (final rate in request.taxGroup.rates.where((r) => r.isActive)) {
        final mode = rate.mode;
        final taxableBase = mode == TaxMode.inclusive
            ? _extractNetFromInclusive(lineNet, rate.rate)
            : lineNet;

        final taxAmount = rate.rate.applyToMoney(taxableBase);
        lineTax = lineTax + taxAmount;

        taxLines.add(
          TaxLine(
            lineId: line.lineId,
            taxRateId: rate.id,
            taxName: rate.name,
            rate: rate.rate,
            taxableAmount: taxableBase,
            taxAmount: taxAmount,
            mode: mode,
          ),
        );

        if (rate.isCompound) {
          lineNet = lineNet + taxAmount;
        }
      }

      totalNet = totalNet + line.netAmount;
      totalTax = totalTax + lineTax;
    }

    final grandTotal = request.defaultMode == TaxMode.inclusive ? totalNet : totalNet + totalTax;

    return Success(
      TaxCalculationResult(
        taxLines: taxLines,
        totalTax: totalTax,
        grandTotal: grandTotal,
      ),
    );
  }

  Money _extractNetFromInclusive(Money inclusive, Percentage rate) {
    final divisor = 1 + rate.value / 100;
    return Money(minorUnits: (inclusive.minorUnits / divisor).round(), currencyCode: inclusive.currencyCode);
  }

  String _currency(TaxCalculationRequest request) {
    return request.lineItems.isNotEmpty
        ? request.lineItems.first.netAmount.currencyCode
        : 'USD';
  }
}
