import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/business/domain/value_objects/money.dart';

/// Currency metadata and formatting.
class CurrencyDefinition {
  const CurrencyDefinition({
    required this.code,
    required this.symbol,
    required this.decimalPlaces,
    this.roundingMode = RoundingMode.halfUp,
  });

  final String code;
  final String symbol;
  final int decimalPlaces;
  final RoundingMode roundingMode;
}

/// Currency conversion and formatting engine.
class CurrencyEngine {
  CurrencyEngine({Map<String, CurrencyDefinition> currencies = const {}})
      : _currencies = currencies.isEmpty ? _defaults : currencies;

  final Map<String, CurrencyDefinition> _currencies;

  static final Map<String, CurrencyDefinition> _defaults = {
    'USD': const CurrencyDefinition(code: 'USD', symbol: '\$', decimalPlaces: 2),
    'EUR': const CurrencyDefinition(code: 'EUR', symbol: '€', decimalPlaces: 2),
    'GBP': const CurrencyDefinition(code: 'GBP', symbol: '£', decimalPlaces: 2),
    'EGP': const CurrencyDefinition(code: 'EGP', symbol: 'E£', decimalPlaces: 2),
    'SAR': const CurrencyDefinition(code: 'SAR', symbol: 'SR', decimalPlaces: 2),
  };

  CurrencyDefinition? getCurrency(String code) => _currencies[code.toUpperCase()];

  String format(Money money) {
    final def = getCurrency(money.currencyCode) ?? _defaults['USD']!;
    final amount = money.majorUnits.toStringAsFixed(def.decimalPlaces);
    return '${def.symbol}$amount';
  }

  Money round(Money money, {RoundingMode? mode}) {
    final def = getCurrency(money.currencyCode);
    final rounding = mode ?? def?.roundingMode ?? RoundingMode.halfUp;
    final factor = Money.scale;
    final scaled = money.minorUnits / factor;

    final rounded = switch (rounding) {
      RoundingMode.halfUp => (scaled * factor).round(),
      RoundingMode.halfDown => (scaled * factor).floor(),
      RoundingMode.up => (scaled * factor).ceil(),
      RoundingMode.down => (scaled * factor).floor(),
      RoundingMode.none => money.minorUnits,
    };

    return Money(minorUnits: rounded, currencyCode: money.currencyCode);
  }

  bool isSameCurrency(Money a, Money b) => a.currencyCode == b.currencyCode;
}
