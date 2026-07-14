import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/enums/automation_enums.dart';

class ApprovalWorkflow extends Equatable implements SyncableEntity {
  const ApprovalWorkflow({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.description,
    this.targetEntityType,
    this.minApprovers = 1,
    this.requiredRoles = const [],
    this.isActive = true,
    this.createdBy,
    this.deletedAt,
  });

  static const entityTypeName = 'approval_workflow';

  @override
  final String id;
  @override
  final String tenantId;
  final String name;
  final String? description;
  final String? targetEntityType;
  final int minApprovers;
  final List<String> requiredRoles;
  final bool isActive;
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
        'entity_type': targetEntityType,
        'min_approvers': minApprovers,
        'required_roles': requiredRoles,
        'is_active': isActive,
        'created_by': createdBy,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static ApprovalWorkflow fromPayload(Map<String, dynamic> json, LocalRecord record) => ApprovalWorkflow(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        name: json['name'] as String? ?? record.searchName ?? '',
        description: json['description'] as String?,
        targetEntityType: json['entity_type'] as String?,
        minApprovers: json['min_approvers'] as int? ?? 1,
        requiredRoles: List<String>.from(json['required_roles'] as List? ?? []),
        isActive: json['is_active'] as bool? ?? true,
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

class ApprovalRequest extends Equatable implements SyncableEntity {
  const ApprovalRequest({
    required this.id,
    required this.tenantId,
    required this.approvalWorkflowId,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.targetEntityType,
    this.targetEntityId,
    this.status = ApprovalStatus.pending,
    this.requestedBy,
    this.approvedBy,
    this.rejectedBy,
    this.comment,
    this.expiresAt,
    this.resolvedAt,
    this.deletedAt,
  });

  static const entityTypeName = 'approval_request';

  @override
  final String id;
  @override
  final String tenantId;
  final String approvalWorkflowId;
  final String? targetEntityType;
  final String? targetEntityId;
  final ApprovalStatus status;
  final String? requestedBy;
  final String? approvedBy;
  final String? rejectedBy;
  final String? comment;
  final DateTime? expiresAt;
  final DateTime? resolvedAt;
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

  ApprovalRequest copyWith({
    ApprovalStatus? status,
    String? approvedBy,
    String? rejectedBy,
    String? comment,
    DateTime? resolvedAt,
    int? version,
    DateTime? updatedAt,
    LocalSyncStatus? syncStatus,
    bool? isDirty,
  }) =>
      ApprovalRequest(
        id: id,
        tenantId: tenantId,
        approvalWorkflowId: approvalWorkflowId,
        targetEntityType: targetEntityType,
        targetEntityId: targetEntityId,
        status: status ?? this.status,
        requestedBy: requestedBy,
        approvedBy: approvedBy ?? this.approvedBy,
        rejectedBy: rejectedBy ?? this.rejectedBy,
        comment: comment ?? this.comment,
        expiresAt: expiresAt,
        resolvedAt: resolvedAt ?? this.resolvedAt,
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
        'approval_workflow_id': approvalWorkflowId,
        'entity_type': targetEntityType,
        'entity_id': entityId,
        'status': status.value,
        'requested_by': requestedBy,
        'approved_by': approvedBy,
        'rejected_by': rejectedBy,
        'comment': comment,
        'expires_at': expiresAt?.toIso8601String(),
        'resolved_at': resolvedAt?.toIso8601String(),
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static ApprovalRequest fromPayload(Map<String, dynamic> json, LocalRecord record) => ApprovalRequest(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        approvalWorkflowId: json['approval_workflow_id'] as String? ?? '',
        targetEntityType: json['entity_type'] as String?,
        entityId: json['entity_id'] as String?,
        status: ApprovalStatus.fromValue(json['status'] as String?),
        requestedBy: json['requested_by'] as String?,
        approvedBy: json['approved_by'] as String?,
        rejectedBy: json['rejected_by'] as String?,
        comment: json['comment'] as String?,
        expiresAt: json['expires_at'] != null ? DateTime.tryParse(json['expires_at'] as String) : null,
        resolvedAt: json['resolved_at'] != null ? DateTime.tryParse(json['resolved_at'] as String) : null,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, approvalWorkflowId, status, version];
}
