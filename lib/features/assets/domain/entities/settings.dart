import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/enums/assets_enums.dart';

class AssetSettings extends Equatable implements SyncableEntity {
  const AssetSettings({
    required this.id,
    required this.tenantId,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.defaultDepreciationMethod = DepreciationMethod.straightLine,
    this.defaultUsefulLifeMonths = 60,
    this.enableAutoDepreciation = true,
    this.enableMaintenanceAlerts = true,
    this.maintenanceAlertDays = 7,
    this.requireApprovalForDisposal = true,
    this.deletedAt,
  });

  static const entityTypeName = 'asset_settings';

  @override
  final String id;
  @override
  final String tenantId;
  final DepreciationMethod defaultDepreciationMethod;
  final int defaultUsefulLifeMonths;
  final bool enableAutoDepreciation;
  final bool enableMaintenanceAlerts;
  final int maintenanceAlertDays;
  final bool requireApprovalForDisposal;
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
        'default_depreciation_method': defaultDepreciationMethod.value,
        'default_useful_life_months': defaultUsefulLifeMonths,
        'enable_auto_depreciation': enableAutoDepreciation,
        'enable_maintenance_alerts': enableMaintenanceAlerts,
        'maintenance_alert_days': maintenanceAlertDays,
        'require_approval_for_disposal': requireApprovalForDisposal,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static AssetSettings fromPayload(Map<String, dynamic> json, LocalRecord record) => AssetSettings(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        defaultDepreciationMethod: DepreciationMethod.fromValue(json['default_depreciation_method'] as String?),
        defaultUsefulLifeMonths: json['default_useful_life_months'] as int? ?? 60,
        enableAutoDepreciation: json['enable_auto_depreciation'] as bool? ?? true,
        enableMaintenanceAlerts: json['enable_maintenance_alerts'] as bool? ?? true,
        maintenanceAlertDays: json['maintenance_alert_days'] as int? ?? 7,
        requireApprovalForDisposal: json['require_approval_for_disposal'] as bool? ?? true,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, tenantId, defaultDepreciationMethod];
}
