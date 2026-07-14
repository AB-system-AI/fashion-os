import 'dart:async';
import 'dart:math';

import 'package:fashion_pos_enterprise/core/infrastructure/network/network_monitor.dart';

/// Automatic retry with exponential backoff and jitter.
class RetryExecutor {
  RetryExecutor({
    this.maxAttempts = 5,
    this.baseDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(minutes: 2),
    NetworkMonitor? networkMonitor,
  }) : _network = networkMonitor;

  final int maxAttempts;
  final Duration baseDelay;
  final Duration maxDelay;
  final NetworkMonitor? _network;
  final _random = Random();

  Future<T> run<T>(
    Future<T> Function() action, {
    bool Function(Object error)? retryIf,
    void Function(int attempt, Object error)? onRetry,
  }) async {
    Object? lastError;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        if (_network != null) {
          final state = await _network.currentState;
          if (!state.isOnline) {
            throw StateError('Network offline');
          }
        }
        return await action();
      } catch (e) {
        lastError = e;
        if (attempt == maxAttempts || (retryIf != null && !retryIf(e))) rethrow;
        onRetry?.call(attempt, e);
        await Future<void>.delayed(_delayForAttempt(attempt));
      }
    }
    throw lastError ?? StateError('RetryExecutor failed');
  }

  Duration _delayForAttempt(int attempt) {
    final exponential = baseDelay * pow(2, attempt - 1);
    final capped = exponential < maxDelay ? exponential : maxDelay;
    final jitterMs = _random.nextInt(250);
    return capped + Duration(milliseconds: jitterMs);
  }
}
