import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';

/// Provides exchange rates for currency conversion.
abstract class ExchangeRateProvider {
  Future<Result<double>> getRate({
    required String fromCurrency,
    required String toCurrency,
    required DateTime at,
  });
}

/// Static exchange rate provider for offline operation.
class StaticExchangeRateProvider implements ExchangeRateProvider {
  StaticExchangeRateProvider({Map<String, double>? rates}) : _rates = rates ?? _defaultRates;

  final Map<String, double> _rates;

  static const Map<String, double> _defaultRates = {
    'USD_EUR': 0.92,
    'EUR_USD': 1.09,
    'USD_EGP': 48.5,
    'EGP_USD': 0.0206,
    'USD_SAR': 3.75,
    'SAR_USD': 0.267,
    'USD_GBP': 0.79,
    'GBP_USD': 1.27,
  };

  @override
  Future<Result<double>> getRate({
    required String fromCurrency,
    required String toCurrency,
    required DateTime at,
  }) async {
    if (fromCurrency == toCurrency) return const Success(1.0);
    final key = '${fromCurrency.toUpperCase()}_${toCurrency.toUpperCase()}';
    final rate = _rates[key];
    if (rate == null) {
      return Error(ValidationFailure(message: 'No exchange rate for $key', code: 'exchange_rate_missing'));
    }
    return Success(rate);
  }
}
