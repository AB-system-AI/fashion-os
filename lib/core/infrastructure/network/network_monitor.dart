import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/network/network_state.dart';
import 'package:fashion_pos_enterprise/core/logging/app_logger.dart';

/// Network abstraction with WiFi/mobile/offline/captive portal/poor connection detection.
class NetworkMonitor {
  NetworkMonitor({Connectivity? connectivity}) : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  final _controller = StreamController<NetworkState>.broadcast();

  NetworkState _lastState = NetworkState.offline;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Stream<NetworkState> get stateStream => _controller.stream;
  Future<NetworkState> get currentState => _evaluate();

  Future<void> initialize() async {
    _lastState = await _evaluate();
    _controller.add(_lastState);
    _subscription = _connectivity.onConnectivityChanged.listen((_) async {
      final next = await _evaluate();
      if (next != _lastState) {
        _lastState = next;
        _controller.add(next);
        AppLogger.debug('Network state: ${next.connectionType.name} / ${next.quality.name}');
      }
    });
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _controller.close();
  }

  Future<NetworkState> _evaluate() async {
    final results = await _connectivity.checkConnectivity();
    if (results.isEmpty || results.every((r) => r == ConnectivityResult.none)) {
      return NetworkState.offline;
    }

    final connectionType = _mapConnectionType(results);
    final hasInternet = await _hasInternetAccess();
    if (!hasInternet) {
      return NetworkState(
        isOnline: false,
        connectionType: connectionType,
        quality: NetworkQuality.captivePortal,
        isCaptivePortal: true,
      );
    }

    final quality = await _measureQuality();
    return NetworkState(
      isOnline: true,
      connectionType: connectionType,
      quality: quality,
    );
  }

  NetworkConnectionType _mapConnectionType(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet)) {
      return NetworkConnectionType.wifi;
    }
    if (results.contains(ConnectivityResult.mobile)) {
      return NetworkConnectionType.mobile;
    }
    return NetworkConnectionType.unknown;
  }

  Future<bool> _hasInternetAccess() async {
    try {
      final result = await InternetAddress.lookup('example.com').timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<NetworkQuality> _measureQuality() async {
    final stopwatch = Stopwatch()..start();
    try {
      final client = HttpClient()..connectionTimeout = const Duration(seconds: 3);
      final request = await client.getUrl(Uri.parse('https://example.com'));
      final response = await request.close();
      await response.drain<void>();
      client.close();
      stopwatch.stop();
      final ms = stopwatch.elapsedMilliseconds;
      if (ms < 300) return NetworkQuality.excellent;
      if (ms < 1000) return NetworkQuality.good;
      return NetworkQuality.poor;
    } catch (_) {
      return NetworkQuality.poor;
    }
  }
}
