/// Forecasts automation load, failure rates, and resource usage.
abstract class ForecastService {
  Future<Map<String, double>> forecastExecutionVolume({
    required String tenantId,
    required int horizonDays,
  });

  Future<double> forecastFailureRate({required String tenantId});

  Future<int> forecastQueueDepth({required String tenantId});
}

class DefaultForecastService implements ForecastService {
  @override
  Future<Map<String, double>> forecastExecutionVolume({
    required String tenantId,
    required int horizonDays,
  }) async =>
      {for (var i = 0; i < horizonDays; i++) 'day_$i': 0};

  @override
  Future<double> forecastFailureRate({required String tenantId}) async => 0;

  @override
  Future<int> forecastQueueDepth({required String tenantId}) async => 0;
}
