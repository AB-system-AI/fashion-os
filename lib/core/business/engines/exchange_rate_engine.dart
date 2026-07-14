import 'package:fashion_pos_enterprise/core/business/contracts/exchange_rate_provider.dart';
import 'package:fashion_pos_enterprise/core/business/domain/value_objects/money.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';

/// Converts amounts between currencies using exchange rate provider.
class ExchangeRateEngine {
  ExchangeRateEngine(this._rateProvider);

  final ExchangeRateProvider _rateProvider;

  Future<Result<Money>> convert({
    required Money amount,
    required String toCurrency,
    DateTime? at,
  }) async {
    if (amount.currencyCode == toCurrency) return Success(amount);

    final rateResult = await _rateProvider.getRate(
      fromCurrency: amount.currencyCode,
      toCurrency: toCurrency,
      at: at ?? DateTime.now().toUtc(),
    );

    return rateResult.map((rate) {
      final convertedMinor = (amount.minorUnits * rate).round();
      return Money(minorUnits: convertedMinor, currencyCode: toCurrency);
    });
  }

  Future<Result<double>> getRate({
    required String fromCurrency,
    required String toCurrency,
    DateTime? at,
  }) {
    return _rateProvider.getRate(
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      at: at ?? DateTime.now().toUtc(),
    );
  }
}
