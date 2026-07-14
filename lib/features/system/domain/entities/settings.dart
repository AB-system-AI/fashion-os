import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/system/domain/enums/system_enums.dart';

class EnvironmentSetting extends Equatable implements SyncableEntity {
  const EnvironmentSetting({
    required this.id,
    required this.tenantId,
    required this.key,
    required this.value,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.environment = EnvironmentType.production,
    this.description,
    this.isSecret = false,
    this.deletedAt,
  });

  static const entityTypeName = 'environment_setting';

  @override
  final String id;
  @override
  final String tenantId;
  final String key;
  final String value;
  final EnvironmentType environment;
  final String? description;
  final bool isSecret;
  @override
  final int version;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final LocalSyncStatus syncStatus;
  @override
  final bool isDirty;

  @override
  String get entityType => entityTypeName;

  @override
  Map<String, dynamic> toPayload() => {
        'id': id,
        'tenant_id': tenantId,
        'key': key,
        'value': value,
        'environment': environment.value,
        'description': description,
        'is_secret': isSecret,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static EnvironmentSetting fromPayload(Map<String, dynamic> json, LocalRecord record) => EnvironmentSetting(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        key: json['key'] as String? ?? record.searchName ?? '',
        value: json['value'] as String? ?? '',
        environment: EnvironmentType.fromValue(json['environment'] as String?),
        description: json['description'] as String?,
        isSecret: json['is_secret'] as bool? ?? false,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, key, environment, version];
}

class SystemConfiguration extends Equatable implements SyncableEntity {
  const SystemConfiguration({
    required this.id,
    required this.tenantId,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.settings = const {},
    this.updatedBy,
    this.deletedAt,
  });

  static const entityTypeName = 'system_configuration';

  @override
  final String id;
  @override
  final String tenantId;
  final Map<String, dynamic> settings;
  final String? updatedBy;
  @override
  final int version;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final LocalSyncStatus syncStatus;
  @override
  final bool isDirty;

  @override
  String get entityType => entityTypeName;

  @override
  Map<String, dynamic> toPayload() => {
        'id': id,
        'tenant_id': tenantId,
        'settings': settings,
        'updated_by': updatedBy,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static SystemConfiguration fromPayload(Map<String, dynamic> json, LocalRecord record) => SystemConfiguration(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        settings: Map<String, dynamic>.from(json['settings'] as Map? ?? {}),
        updatedBy: json['updated_by'] as String?,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, tenantId, version];
}

class MaintenanceMode extends Equatable implements SyncableEntity {
  const MaintenanceMode({
    required this.id,
    required this.tenantId,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.active = false,
    this.scope = MaintenanceScope.tenant,
    this.message,
    this.scheduledStart,
    this.scheduledEnd,
    this.affectedModules = const [],
    this.deletedAt,
  });

  static const entityTypeName = 'maintenance_mode';

  @override
  final String id;
  @override
  final String tenantId;
  final bool active;
  final MaintenanceScope scope;
  final String? message;
  final DateTime? scheduledStart;
  final DateTime? scheduledEnd;
  final List<String> affectedModules;
  @override
  final int version;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final LocalSyncStatus syncStatus;
  @override
  final bool isDirty;

  @override
  String get entityType => entityTypeName;

  MaintenanceMode copyWith({
    bool? active,
    String? message,
    DateTime? scheduledStart,
    DateTime? scheduledEnd,
    List<String>? affectedModules,
    int? version,
    DateTime? updatedAt,
    LocalSyncStatus? syncStatus,
    bool? isDirty,
  }) =>
      MaintenanceMode(
        id: id,
        tenantId: tenantId,
        active: active ?? this.active,
        scope: scope,
        message: message ?? this.message,
        scheduledStart: scheduledStart ?? this.scheduledStart,
        scheduledEnd: scheduledEnd ?? this.scheduledEnd,
        affectedModules: affectedModules ?? this.affectedModules,
        version: version ?? this.version,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt,
        syncStatus: syncStatus ?? this.syncStatus,
        isDirty: isDirty ?? this.isDirty,
      );

  @override
  Map<String, dynamic> toPayload() => {
        'id': id,
        'tenant_id': tenantId,
        'active': active,
        'scope': scope.value,
        'message': message,
        'scheduled_start': scheduledStart?.toIso8601String(),
        'scheduled_end': scheduledEnd?.toIso8601String(),
        'affected_modules': affectedModules,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static MaintenanceMode fromPayload(Map<String, dynamic> json, LocalRecord record) => MaintenanceMode(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        active: json['active'] as bool? ?? false,
        scope: MaintenanceScope.fromValue(json['scope'] as String?),
        message: json['message'] as String?,
        scheduledStart: json['scheduled_start'] != null ? DateTime.tryParse(json['scheduled_start'] as String) : null,
        scheduledEnd: json['scheduled_end'] != null ? DateTime.tryParse(json['scheduled_end'] as String) : null,
        affectedModules: List<String>.from(json['affected_modules'] as List? ?? []),
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, active, scope, version];
}
