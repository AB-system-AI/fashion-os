import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/business/domain/entities/workflow_models.dart';
import 'package:fashion_pos_enterprise/core/business/engines/workflow_engine.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';

/// Approval decision outcome.
enum ApprovalDecision { approved, rejected, delegated, escalated }

/// A single row in an approval matrix (role + threshold).
class ApprovalMatrixRow extends Equatable {
  const ApprovalMatrixRow({
    required this.stepOrder,
    required this.requiredRole,
    this.minAmount,
    this.maxAmount,
    this.isOptional = false,
  });

  final int stepOrder;
  final String requiredRole;
  final double? minAmount;
  final double? maxAmount;
  final bool isOptional;

  bool matchesAmount(double? amount) {
    if (amount == null) return minAmount == null && maxAmount == null;
    if (minAmount != null && amount < minAmount!) return false;
    if (maxAmount != null && amount > maxAmount!) return false;
    return true;
  }

  @override
  List<Object?> get props => [stepOrder, requiredRole, minAmount, maxAmount];
}

/// Resolved approvers for a given context.
class ResolvedApprovers extends Equatable {
  const ResolvedApprovers({required this.rows, this.skippedOptional = 0});

  final List<ApprovalMatrixRow> rows;
  final int skippedOptional;

  bool get hasApprovers => rows.isNotEmpty;

  @override
  List<Object?> get props => [rows, skippedOptional];
}

/// Delegation record (in-memory / engine-level).
class DelegationRecord extends Equatable {
  const DelegationRecord({
    required this.fromUserId,
    required this.toUserId,
    required this.effectiveFrom,
    this.effectiveUntil,
    this.reason,
  });

  final String fromUserId;
  final String toUserId;
  final DateTime effectiveFrom;
  final DateTime? effectiveUntil;
  final String? reason;

  bool isActiveAt(DateTime at) {
    if (at.isBefore(effectiveFrom)) return false;
    if (effectiveUntil != null && at.isAfter(effectiveUntil!)) return false;
    return true;
  }

  @override
  List<Object?> get props => [fromUserId, toUserId, effectiveFrom];
}

/// History entry produced by the engine.
class ApprovalHistoryEntry extends Equatable {
  const ApprovalHistoryEntry({
    required this.requestId,
    required this.actorId,
    required this.decision,
    required this.occurredAt,
    this.comment,
    this.fromRole,
    this.toUserId,
  });

  final String requestId;
  final String actorId;
  final ApprovalDecision decision;
  final DateTime occurredAt;
  final String? comment;
  final String? fromRole;
  final String? toUserId;

  @override
  List<Object?> get props => [requestId, actorId, decision, occurredAt];
}

/// Escalation trigger evaluation result.
class EscalationEvaluation extends Equatable {
  const EscalationEvaluation({
    required this.shouldEscalate,
    this.targetRole,
    this.reason,
  });

  final bool shouldEscalate;
  final String? targetRole;
  final String? reason;

  @override
  List<Object?> get props => [shouldEscalate, targetRole];
}

/// Pure approval logic — matrix resolution, delegation, escalation, history.
/// Works alongside [WorkflowEngine] for step advancement.
class ApprovalEngine {
  ApprovalEngine({WorkflowEngine? workflowEngine}) : _workflowEngine = workflowEngine ?? WorkflowEngine();

  final WorkflowEngine _workflowEngine;

  WorkflowEngine get workflowEngine => _workflowEngine;

  /// Resolves applicable matrix rows for a context (amount, entity type).
  ResolvedApprovers resolveMatrix({
    required List<ApprovalMatrixRow> matrix,
    double? amount,
    String? entityType,
  }) {
    final applicable = <ApprovalMatrixRow>[];
    var skipped = 0;
    for (final row in matrix) {
      if (!row.matchesAmount(amount)) {
        if (row.isOptional) skipped++;
        continue;
      }
      applicable.add(row);
    }
    applicable.sort((a, b) => a.stepOrder.compareTo(b.stepOrder));
    return ResolvedApprovers(rows: applicable, skippedOptional: skipped);
  }

  /// Resolves the effective approver user id considering active delegations.
  String resolveApprover({
    required String originalUserId,
    required List<DelegationRecord> delegations,
    DateTime? at,
  }) {
    final now = at ?? DateTime.now().toUtc();
    for (final d in delegations) {
      if (d.fromUserId == originalUserId && d.isActiveAt(now)) {
        return d.toUserId;
      }
    }
    return originalUserId;
  }

  /// Evaluates whether a pending request should escalate.
  EscalationEvaluation evaluateEscalation({
    required DateTime requestedAt,
    required Duration timeout,
    required String? currentRole,
    String? escalateToRole,
    DateTime? now,
  }) {
    final at = now ?? DateTime.now().toUtc();
    if (at.difference(requestedAt) < timeout) {
      return const EscalationEvaluation(shouldEscalate: false);
    }
    return EscalationEvaluation(
      shouldEscalate: true,
      targetRole: escalateToRole ?? currentRole,
      reason: 'Exceeded approval timeout of ${timeout.inHours}h',
    );
  }

  /// Records an approval history entry.
  ApprovalHistoryEntry recordHistory({
    required String requestId,
    required String actorId,
    required ApprovalDecision decision,
    String? comment,
    String? fromRole,
    String? toUserId,
    DateTime? occurredAt,
  }) =>
      ApprovalHistoryEntry(
        requestId: requestId,
        actorId: actorId,
        decision: decision,
        occurredAt: occurredAt ?? DateTime.now().toUtc(),
        comment: comment,
        fromRole: fromRole,
        toUserId: toUserId,
      );

  /// Advances the linked workflow instance after approval.
  Result<WorkflowInstance> advanceWorkflowOnApproval({
    required WorkflowInstance instance,
    required String actorRole,
  }) =>
      _workflowEngine.advance(instance, actorRole: actorRole);

  /// Rejects the linked workflow instance.
  Result<WorkflowInstance> rejectWorkflow({
    required WorkflowInstance instance,
    String? reason,
  }) =>
      _workflowEngine.reject(instance, reason: reason);

  /// Registers a workflow definition for use during approval flows.
  void registerWorkflowDefinition(WorkflowDefinition definition) {
    _workflowEngine.registerDefinition(definition);
  }

  /// Checks whether an actor role can act on the current matrix step.
  bool canActorApprove({
    required ResolvedApprovers resolved,
    required int currentStepIndex,
    required String actorRole,
  }) {
    if (currentStepIndex < 0 || currentStepIndex >= resolved.rows.length) return false;
    return resolved.rows[currentStepIndex].requiredRole == actorRole;
  }
}
