import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';

/// Tenant-configurable approval template.
class ApprovalTemplate extends Equatable implements SyncableEntity {
  const ApprovalTemplate({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.description,
    this.entityType,
    this.isActive = true,
    this.minApprovers = 1,
    this.createdBy,
    this.deletedAt,
  });

  static const entityTypeName = 'wf_approval_template';

  @override
  final String id;
  @override
  final String tenantId;
  final String name;
  final String? description;
  final String? entityType;
  final bool isActive;
  final int minApprovers;
  final String? createdBy;
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
        'description': description,
        'entity_type': entityType,
        'is_active': isActive,
        'min_approvers': minApprovers,
        'created_by': createdBy,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static ApprovalTemplate fromPayload(Map<String, dynamic> json, LocalRecord record) => ApprovalTemplate(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        name: json['name'] as String? ?? record.searchName ?? '',
        description: json['description'] as String?,
        entityType: json['entity_type'] as String?,
        isActive: json['is_active'] as bool? ?? true,
        minApprovers: json['min_approvers'] as int? ?? 1,
        createdBy: json['created_by'] as String?,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, name, isActive, version];
}

/// A row in an approval matrix linked to a template.
class ApprovalMatrix extends Equatable implements SyncableEntity {
  const ApprovalMatrix({
    required this.id,
    required this.tenantId,
    required this.templateId,
    required this.stepOrder,
    required this.requiredRole,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.minAmount,
    this.maxAmount,
    this.isOptional = false,
    this.deletedAt,
  });

  static const entityTypeName = 'wf_approval_matrix';

  @override
  final String id;
  @override
  final String tenantId;
  final String templateId;
  final int stepOrder;
  final String requiredRole;
  final double? minAmount;
  final double? maxAmount;
  final bool isOptional;
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
        'template_id': templateId,
        'step_order': stepOrder,
        'required_role': requiredRole,
        'min_amount': minAmount,
        'max_amount': maxAmount,
        'is_optional': isOptional,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static ApprovalMatrix fromPayload(Map<String, dynamic> json, LocalRecord record) => ApprovalMatrix(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        templateId: json['template_id'] as String? ?? '',
        stepOrder: json['step_order'] as int? ?? 0,
        requiredRole: json['required_role'] as String? ?? '',
        minAmount: (json['min_amount'] as num?)?.toDouble(),
        maxAmount: (json['max_amount'] as num?)?.toDouble(),
        isOptional: json['is_optional'] as bool? ?? false,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, templateId, stepOrder, requiredRole, version];
}
