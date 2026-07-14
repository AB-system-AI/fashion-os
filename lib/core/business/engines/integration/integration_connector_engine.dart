/// Pure integration connector rules: health checks, rate limiting, retry backoff.
class IntegrationConnectorEngine {
  IntegrationConnectorEngine({
    this.defaultMaxRetries = 3,
    this.baseRetryDelayMs = 500,
    this.defaultRateLimitPerMinute = 60,
  });

  final int defaultMaxRetries;
  final int baseRetryDelayMs;
  final int defaultRateLimitPerMinute;

  HealthCheckResult evaluateHealth({
    required bool isEnabled,
    required DateTime? lastSuccessAt,
    required DateTime? lastFailureAt,
    required int consecutiveFailures,
    Duration staleThreshold = const Duration(minutes: 15),
  }) {
    if (!isEnabled) {
      return const HealthCheckResult(status: ConnectorHealthStatus.disabled, message: 'Connector is disabled');
    }
    if (consecutiveFailures >= 5) {
      return HealthCheckResult(
        status: ConnectorHealthStatus.unhealthy,
        message: 'Connector failed $consecutiveFailures consecutive times',
      );
    }
    final last = lastSuccessAt ?? lastFailureAt;
    if (last != null && DateTime.now().toUtc().difference(last) > staleThreshold) {
      return const HealthCheckResult(status: ConnectorHealthStatus.degraded, message: 'No recent activity');
    }
    if (lastFailureAt != null && (lastSuccessAt == null || lastFailureAt!.isAfter(lastSuccessAt!))) {
      return const HealthCheckResult(status: ConnectorHealthStatus.degraded, message: 'Last attempt failed');
    }
    return const HealthCheckResult(status: ConnectorHealthStatus.healthy);
  }

  bool isRateLimited({
    required int requestCount,
    required int limitPerMinute,
    required DateTime windowStart,
    DateTime? now,
  }) {
    final current = now ?? DateTime.now().toUtc();
    if (current.difference(windowStart).inMinutes >= 1) return false;
    return requestCount >= limitPerMinute;
  }

  Duration nextRetryDelay(int attempt, {int? baseMs}) {
    final base = baseMs ?? baseRetryDelayMs;
    final exponent = attempt.clamp(0, 8);
    return Duration(milliseconds: base * (1 << exponent));
  }

  RetryDecision shouldRetry({
    required int attempt,
    required int? maxRetries,
    required int? statusCode,
  }) {
    final limit = maxRetries ?? defaultMaxRetries;
    if (attempt >= limit) {
      return const RetryDecision(shouldRetry: false, reason: 'Max retries exceeded');
    }
    if (statusCode != null && statusCode >= 400 && statusCode < 500 && statusCode != 429) {
      return RetryDecision(shouldRetry: false, reason: 'Client error $statusCode');
    }
    return RetryDecision(shouldRetry: true, delay: nextRetryDelay(attempt));
  }
}

enum ConnectorHealthStatus {
  healthy,
  degraded,
  unhealthy,
  disabled;

  String get value => name;

  static ConnectorHealthStatus fromValue(String? v) =>
      ConnectorHealthStatus.values.firstWhere((e) => e.name == v, orElse: () => ConnectorHealthStatus.healthy);
}

class HealthCheckResult {
  const HealthCheckResult({required this.status, this.message});

  final ConnectorHealthStatus status;
  final String? message;
}

class RetryDecision {
  const RetryDecision({required this.shouldRetry, this.delay, this.reason});

  final bool shouldRetry;
  final Duration? delay;
  final String? reason;
}
