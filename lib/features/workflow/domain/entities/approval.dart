import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/enums/workflow_enums.dart';

/// Pending or resolved approval request.
class ApprovalRequest extends Equatable implements SyncableEntity {
  const ApprovalRequest({
    required this.id,
    required this.tenantId,
    required this.templateId,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.workflowInstanceId,
    this.targetEntityType,
    this.targetEntityId,
    this.status = ApprovalRequestStatus.pending,
    this.currentStepIndex = 0,
    this.requestedBy,
    this.assignedTo,
    this.comment,
    this.amount,
    this.expiresAt,
    this.resolvedAt,
    this.deletedAt,
  });

  static const entityTypeName = 'wf_approval_request';

  @override
  final String id;
  @override
  final String tenantId;
  final String templateId;
  final String? workflowInstanceId;
  final String? targetEntityType;
  final String? targetEntityId;
  final ApprovalRequestStatus status;
  final int currentStepIndex;
  final String? requestedBy;
  final String? assignedTo;
  final String? comment;
  final double? amount;
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

  bool get isPending => status == ApprovalRequestStatus.pending || status == ApprovalRequestStatus.escalated;

  ApprovalRequest copyWith({
    ApprovalRequestStatus? status,
    int? currentStepIndex,
    String? assignedTo,
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
        templateId: templateId,
        workflowInstanceId: workflowInstanceId,
        targetEntityType: targetEntityType,
        targetEntityId: targetEntityId,
        status: status ?? this.status,
        currentStepIndex: currentStepIndex ?? this.currentStepIndex,
        requestedBy: requestedBy,
        assignedTo: assignedTo ?? this.assignedTo,
        comment: comment ?? this.comment,
        amount: amount,
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
        'template_id': templateId,
        'workflow_instance_id': workflowInstanceId,
        'entity_type': targetEntityType,
        'entity_id': targetEntityId,
        'status': status.value,
        'current_step_index': currentStepIndex,
        'requested_by': requestedBy,
        'assigned_to': assignedTo,
        'comment': comment,
        'amount': amount,
        'expires_at': expiresAt?.toIso8601String(),
        'resolved_at': resolvedAt?.toIso8601String(),
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static ApprovalRequest fromPayload(Map<String, dynamic> json, LocalRecord record) => ApprovalRequest(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        templateId: json['template_id'] as String? ?? '',
        workflowInstanceId: json['workflow_instance_id'] as String?,
        targetEntityType: json['entity_type'] as String?,
        targetEntityId: json['entity_id'] as String?,
        status: ApprovalRequestStatus.fromValue(json['status'] as String?),
        currentStepIndex: json['current_step_index'] as int? ?? 0,
        requestedBy: json['requested_by'] as String?,
        assignedTo: json['assigned_to'] as String?,
        comment: json['comment'] as String?,
        amount: (json['amount'] as num?)?.toDouble(),
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
  List<Object?> get props => [id, templateId, status, currentStepIndex, version];
}

/// Immutable audit trail entry for an approval request.
class ApprovalHistory extends Equatable implements SyncableEntity {
  const ApprovalHistory({
    required this.id,
    required this.tenantId,
    required this.requestId,
    required this.actorId,
    required this.decision,
    required this.occurredAt,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.comment,
    this.fromRole,
    this.toUserId,
    this.deletedAt,
  });

  static const entityTypeName = 'wf_approval_history';

  @override
  final String id;
  @override
  final String tenantId;
  final String requestId;
  final String actorId;
  final String decision;
  final DateTime occurredAt;
  final String? comment;
  final String? fromRole;
  final String? toUserId;
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
        'request_id': requestId,
        'actor_id': actorId,
        'decision': decision,
        'occurred_at': occurredAt.toIso8601String(),
        'comment': comment,
        'from_role': fromRole,
        'to_user_id': toUserId,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static ApprovalHistory fromPayload(Map<String, dynamic> json, LocalRecord record) => ApprovalHistory(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        requestId: json['request_id'] as String? ?? '',
        actorId: json['actor_id'] as String? ?? '',
        decision: json['decision'] as String? ?? 'unknown',
        occurredAt: DateTime.tryParse(json['occurred_at'] as String? ?? '') ?? record.createdAt,
        comment: json['comment'] as String?,
        fromRole: json['from_role'] as String?,
        toUserId: json['to_user_id'] as String?,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, requestId, decision, occurredAt, version];
}

/// Delegation of approval authority between users.
class ApprovalDelegation extends Equatable implements SyncableEntity {
  const ApprovalDelegation({
    required this.id,
    required this.tenantId,
    required this.fromUserId,
    required this.toUserId,
    required this.effectiveFrom,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.effectiveUntil,
    this.reason,
    this.isActive = true,
    this.deletedAt,
  });

  static const entityTypeName = 'wf_approval_delegation';

  @override
  final String id;
  @override
  final String tenantId;
  final String fromUserId;
  final String toUserId;
  final DateTime effectiveFrom;
  final DateTime? effectiveUntil;
  final String? reason;
  final bool isActive;
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

  bool isEffectiveAt(DateTime at) {
    if (!isActive) return false;
    if (at.isBefore(effectiveFrom)) return false;
    if (effectiveUntil != null && at.isAfter(effectiveUntil!)) return false;
    return true;
  }

  @override
  Map<String, dynamic> toPayload() => {
        'id': id,
        'tenant_id': tenantId,
        'from_user_id': fromUserId,
        'to_user_id': toUserId,
        'effective_from': effectiveFrom.toIso8601String(),
        'effective_until': effectiveUntil?.toIso8601String(),
        'reason': reason,
        'is_active': isActive,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static ApprovalDelegation fromPayload(Map<String, dynamic> json, LocalRecord record) => ApprovalDelegation(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        fromUserId: json['from_user_id'] as String? ?? '',
        toUserId: json['to_user_id'] as String? ?? '',
        effectiveFrom: DateTime.tryParse(json['effective_from'] as String? ?? '') ?? record.createdAt,
        effectiveUntil: json['effective_until'] != null ? DateTime.tryParse(json['effective_until'] as String) : null,
        reason: json['reason'] as String?,
        isActive: json['is_active'] as bool? ?? true,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, fromUserId, toUserId, isActive, version];
}
