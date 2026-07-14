import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/business/domain/value_objects/money.dart';

/// Tax rate definition.
class TaxRate extends Equatable {
  const TaxRate({
    required this.id,
    required this.name,
    required this.rate,
    required this.category,
    this.mode = TaxMode.exclusive,
    this.isCompound = false,
    this.countryCode,
    this.regionCode,
    this.isActive = true,
  });

  final String id;
  final String name;
  final Percentage rate;
  final TaxCategory category;
  final TaxMode mode;
  final bool isCompound;
  final String? countryCode;
  final String? regionCode;
  final bool isActive;

  @override
  List<Object?> get props => [id, rate, category, mode];
}

/// Tax group combining multiple rates.
class TaxGroup extends Equatable {
  const TaxGroup({
    required this.id,
    required this.name,
    required this.rates,
    this.isDefault = false,
  });

  final String id;
  final String name;
  final List<TaxRate> rates;
  final bool isDefault;

  @override
  List<Object?> get props => [id, rates];
}

/// Computed tax line on a sale item or order.
class TaxLine extends Equatable {
  const TaxLine({
    required this.taxRateId,
    required this.taxName,
    required this.rate,
    required this.taxableAmount,
    required this.taxAmount,
    required this.mode,
    this.lineId,
  });

  final String? lineId;
  final String taxRateId;
  final String taxName;
  final Percentage rate;
  final Money taxableAmount;
  final Money taxAmount;
  final TaxMode mode;

  @override
  List<Object?> get props => [taxRateId, taxAmount, lineId];
}

/// Tax calculation input.
class TaxCalculationRequest extends Equatable {
  const TaxCalculationRequest({
    required this.lineItems,
    required this.taxGroup,
    this.defaultMode = TaxMode.exclusive,
  });

  final List<TaxableLineItem> lineItems;
  final TaxGroup taxGroup;
  final TaxMode defaultMode;

  @override
  List<Object?> get props => [lineItems, taxGroup];
}

class TaxableLineItem extends Equatable {
  const TaxableLineItem({
    required this.lineId,
    required this.netAmount,
    this.isTaxExempt = false,
  });

  final String lineId;
  final Money netAmount;
  final bool isTaxExempt;

  @override
  List<Object?> get props => [lineId, netAmount];
}

/// Tax calculation result.
class TaxCalculationResult extends Equatable {
  const TaxCalculationResult({
    required this.taxLines,
    required this.totalTax,
    required this.grandTotal,
  });

  final List<TaxLine> taxLines;
  final Money totalTax;
  final Money grandTotal;

  @override
  List<Object?> get props => [taxLines, totalTax, grandTotal];
}
