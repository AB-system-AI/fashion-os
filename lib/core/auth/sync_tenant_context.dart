/// Holds the active tenant/device context for sync operations.
///
/// Updated by auth layer when the authenticated user changes.
class SyncTenantContext {
  SyncTenantContext._();

  static String? _tenantId;
  static String _deviceId = 'local-device';

  static String? get tenantId => _tenantId;
  static String get deviceId => _deviceId;

  static void update({String? tenantId, String? deviceId}) {
    if (tenantId != null) _tenantId = tenantId;
    if (deviceId != null && deviceId.isNotEmpty) _deviceId = deviceId;
  }

  static void clear() {
    _tenantId = null;
  }
}
