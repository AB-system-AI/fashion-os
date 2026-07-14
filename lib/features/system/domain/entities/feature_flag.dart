import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/system/domain/enums/system_enums.dart';

class FeatureFlag extends Equatable implements SyncableEntity {
  const FeatureFlag({
    required this.id,
    required this.tenantId,
    required this.key,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.scope = FeatureFlagScope.tenant,
    this.enabled = false,
    this.variant,
    this.description,
    this.payload = const {},
    this.deletedAt,
  });

  static const entityTypeName = 'feature_flag';

  @override
  final String id;
  @override
  final String tenantId;
  final String key;
  final FeatureFlagScope scope;
  final bool enabled;
  final String? variant;
  final String? description;
  final Map<String, dynamic> payload;
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

  FeatureFlag copyWith({
    bool? enabled,
    String? variant,
    String? description,
    Map<String, dynamic>? payload,
    int? version,
    DateTime? updatedAt,
    LocalSyncStatus? syncStatus,
    bool? isDirty,
  }) =>
      FeatureFlag(
        id: id,
        tenantId: tenantId,
        key: key,
        scope: scope,
        enabled: enabled ?? this.enabled,
        variant: variant ?? this.variant,
        description: description ?? this.description,
        payload: payload ?? this.payload,
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
        'key': key,
        'scope': scope.value,
        'enabled': enabled,
        'variant': variant,
        'description': description,
        'payload': payload,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static FeatureFlag fromPayload(Map<String, dynamic> json, LocalRecord record) => FeatureFlag(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        key: json['key'] as String? ?? record.searchName ?? '',
        scope: FeatureFlagScope.fromValue(json['scope'] as String?),
        enabled: json['enabled'] as bool? ?? false,
        variant: json['variant'] as String?,
        description: json['description'] as String?,
        payload: Map<String, dynamic>.from(json['payload'] as Map? ?? {}),
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, key, enabled, version];
}
