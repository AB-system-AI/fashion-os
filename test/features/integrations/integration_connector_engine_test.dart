import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/business/engines/integration/integration_connector_engine.dart';

void main() {
  late IntegrationConnectorEngine engine;

  setUp(() => engine = IntegrationConnectorEngine());

  test('evaluateHealth returns disabled when connector off', () {
    final result = engine.evaluateHealth(isEnabled: false, lastSuccessAt: null, lastFailureAt: null, consecutiveFailures: 0);
    expect(result.status, ConnectorHealthStatus.disabled);
  });

  test('evaluateHealth returns unhealthy after many failures', () {
    final result = engine.evaluateHealth(
      isEnabled: true,
      lastSuccessAt: DateTime.now().toUtc(),
      lastFailureAt: DateTime.now().toUtc(),
      consecutiveFailures: 5,
    );
    expect(result.status, ConnectorHealthStatus.unhealthy);
  });

  test('isRateLimited blocks when over limit', () {
    final start = DateTime.now().toUtc();
    expect(engine.isRateLimited(requestCount: 60, limitPerMinute: 60, windowStart: start), isTrue);
  });

  test('shouldRetry stops on client errors', () {
    final decision = engine.shouldRetry(attempt: 0, statusCode: 400);
    expect(decision.shouldRetry, isFalse);
  });

  test('nextRetryDelay uses exponential backoff', () {
    expect(engine.nextRetryDelay(2).inMilliseconds, 2000);
  });
}
