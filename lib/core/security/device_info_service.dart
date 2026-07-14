import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';

import 'package:fashion_pos_enterprise/core/constants/storage_keys.dart';
import 'package:fashion_pos_enterprise/core/services/local_storage_service.dart';

/// Device identity for session registration and sync.
class DeviceInfoService {
  DeviceInfoService(this._localStorage);

  final LocalStorageService _localStorage;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  static const _uuid = Uuid();

  Future<String> getDeviceId() async {
    final existing = _localStorage.getString(StorageKeys.deviceId);
    if (existing != null && existing.isNotEmpty) return existing;
    final id = _uuid.v4();
    await _localStorage.setString(StorageKeys.deviceId, id);
    return id;
  }

  Future<String> getDeviceName() async {
    if (kIsWeb) return 'Web Browser';
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final info = await _deviceInfo.androidInfo;
        return '${info.brand} ${info.model}';
      }
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final info = await _deviceInfo.iosInfo;
        return info.name;
      }
      if (defaultTargetPlatform == TargetPlatform.windows) {
        final info = await _deviceInfo.windowsInfo;
        return info.computerName;
      }
      if (defaultTargetPlatform == TargetPlatform.macOS) {
        final info = await _deviceInfo.macOsInfo;
        return info.computerName;
      }
    } catch (_) {
      return 'Unknown Device';
    }
    return 'Unknown Device';
  }

  Future<String> getPlatform() async {
    if (kIsWeb) return 'web';
    return defaultTargetPlatform.name;
  }

  Future<String> getAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  }
}
