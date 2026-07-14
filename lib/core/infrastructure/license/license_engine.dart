import 'package:fashion_pos_enterprise/core/network/network_info.dart';
import 'package:fashion_pos_enterprise/core/enterprise/license_service.dart';
import 'package:fashion_pos_enterprise/core/enterprise/license_validator.dart';
import 'package:fashion_pos_enterprise/core/enterprise/remote_config_service.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/network/network_monitor.dart';

export 'package:fashion_pos_enterprise/core/enterprise/license_service.dart'
    show LicenseEvaluation, LicenseType, LicenseSource, LicenseCacheRecord;

/// License engine facade — offline grace, trial/monthly/yearly/lifetime support.
class LicenseEngine {
  LicenseEngine({
    required LicenseValidator validator,
    required RemoteConfigService remoteConfig,
    required NetworkMonitor networkMonitor,
    this.defaultGracePeriod = const Duration(days: 7),
  }) : _service = LicenseService(
          validator: validator,
          remoteConfig: remoteConfig,
          networkInfo: _NetworkInfoBridge(networkMonitor),
        );

  final LicenseService _service;

  Future<LicenseEvaluation> evaluate({
    required String? tenantId,
    required String? subscriptionStatus,
    String? subscriptionPlan,
    DateTime? validUntil,
  }) {
    return _service.evaluate(
      tenantId: tenantId,
      subscriptionStatus: subscriptionStatus,
      subscriptionPlan: subscriptionPlan,
      validUntil: validUntil,
    );
  }

  bool canOperatePos(LicenseEvaluation evaluation) => evaluation.canOperatePos;
}

class _NetworkInfoBridge implements NetworkInfo {
  _NetworkInfoBridge(this._monitor);
  final NetworkMonitor _monitor;

  @override
  Future<bool> get isConnected async => (await _monitor.currentState).isOnline;

  @override
  Stream<bool> get onConnectivityChanged =>
      _monitor.stateStream.map((state) => state.isOnline);
}
