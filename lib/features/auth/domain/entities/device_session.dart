import 'package:equatable/equatable.dart';

class DeviceSession extends Equatable {
  const DeviceSession({
    required this.id,
    required this.deviceId,
    required this.deviceName,
    required this.platform,
    required this.isTrusted,
    required this.isCurrent,
    required this.lastActiveAt,
    required this.createdAt,
    this.appVersion,
    this.ipAddress,
  });

  final String id;
  final String deviceId;
  final String deviceName;
  final String platform;
  final String? appVersion;
  final String? ipAddress;
  final bool isTrusted;
  final bool isCurrent;
  final DateTime lastActiveAt;
  final DateTime createdAt;

  factory DeviceSession.fromJson(Map<String, dynamic> json, {String? currentDeviceId}) {
    return DeviceSession(
      id: json['id'] as String,
      deviceId: json['device_id'] as String,
      deviceName: json['device_name'] as String,
      platform: json['platform'] as String,
      appVersion: json['app_version'] as String?,
      ipAddress: json['ip_address'] as String?,
      isTrusted: json['is_trusted'] as bool? ?? false,
      isCurrent: currentDeviceId != null && json['device_id'] == currentDeviceId,
      lastActiveAt: DateTime.parse(json['last_active_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  @override
  List<Object?> get props => [id, deviceId, deviceName, platform, isTrusted, isCurrent];
}
