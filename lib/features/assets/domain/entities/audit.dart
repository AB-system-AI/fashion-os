import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/enums/assets_enums.dart';

class AssetAudit extends Equatable implements SyncableEntity {
  const AssetAudit({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.status = AssetAuditStatus.planned,
    this.locationId,
    this.scheduledAt,
    this.completedAt,
    this.auditorId,
    this.findings,
    this.deletedAt,
  });

  static const entityTypeName = 'asset_audit';

  @override
  final String id;
  @override
  final String tenantId;
  final String name;
  final AssetAuditStatus status;
  final String? locationId;
  final DateTime? scheduledAt;
  final DateTime? completedAt;
  final String? auditorId;
  final String? findings;
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
        'name': name,
        'status': status.value,
        'location_id': locationId,
        'scheduled_at': scheduledAt?.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
        'auditor_id': auditorId,
        'findings': findings,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static AssetAudit fromPayload(Map<String, dynamic> json, LocalRecord record) => AssetAudit(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        name: json['name'] as String? ?? record.searchName ?? '',
        status: AssetAuditStatus.fromValue(json['status'] as String?),
        locationId: json['location_id'] as String?,
        scheduledAt: json['scheduled_at'] != null ? DateTime.tryParse(json['scheduled_at'] as String) : null,
        completedAt: json['completed_at'] != null ? DateTime.tryParse(json['completed_at'] as String) : null,
        auditorId: json['auditor_id'] as String?,
        findings: json['findings'] as String?,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, name, status];
}
