import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/business/domain/entities/workflow_models.dart';
import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/business/engines/workflow/approval_engine.dart';

void main() {
  late ApprovalEngine engine;

  setUp(() => engine = ApprovalEngine());

  test('resolveMatrix filters by amount thresholds', () {
    final matrix = [
      const ApprovalMatrixRow(stepOrder: 0, requiredRole: 'manager', maxAmount: 1000),
      const ApprovalMatrixRow(stepOrder: 1, requiredRole: 'director', minAmount: 1000),
    ];
    final low = engine.resolveMatrix(matrix: matrix, amount: 500);
    expect(low.rows.single.requiredRole, 'manager');
    final high = engine.resolveMatrix(matrix: matrix, amount: 5000);
    expect(high.rows.single.requiredRole, 'director');
  });

  test('resolveApprover follows active delegation', () {
    final now = DateTime.utc(2025, 6, 1, 12);
    final delegations = [
      DelegationRecord(
        fromUserId: 'user-a',
        toUserId: 'user-b',
        effectiveFrom: DateTime.utc(2025, 6, 1),
        effectiveUntil: DateTime.utc(2025, 6, 30),
      ),
    ];
    expect(engine.resolveApprover(originalUserId: 'user-a', delegations: delegations, at: now), 'user-b');
    expect(engine.resolveApprover(originalUserId: 'user-a', delegations: delegations, at: DateTime.utc(2025, 7, 1)), 'user-a');
  });

  test('evaluateEscalation triggers after timeout', () {
    final requestedAt = DateTime.utc(2025, 1, 1);
    final before = engine.evaluateEscalation(
      requestedAt: requestedAt,
      timeout: const Duration(hours: 48),
      currentRole: 'manager',
      escalateToRole: 'director',
      now: DateTime.utc(2025, 1, 2),
    );
    expect(before.shouldEscalate, isFalse);
    final after = engine.evaluateEscalation(
      requestedAt: requestedAt,
      timeout: const Duration(hours: 48),
      currentRole: 'manager',
      escalateToRole: 'director',
      now: DateTime.utc(2025, 1, 5),
    );
    expect(after.shouldEscalate, isTrue);
    expect(after.targetRole, 'director');
  });

  test('canActorApprove validates matrix step role', () {
    final resolved = engine.resolveMatrix(matrix: [
      const ApprovalMatrixRow(stepOrder: 0, requiredRole: 'manager'),
      const ApprovalMatrixRow(stepOrder: 1, requiredRole: 'director'),
    ]);
    expect(engine.canActorApprove(resolved: resolved, currentStepIndex: 0, actorRole: 'manager'), isTrue);
    expect(engine.canActorApprove(resolved: resolved, currentStepIndex: 0, actorRole: 'clerk'), isFalse);
  });

  test('advanceWorkflowOnApproval integrates with WorkflowEngine', () {
    engine.registerWorkflowDefinition(const WorkflowDefinition(
      id: 'wf-1',
      name: 'Purchase approval',
      type: WorkflowType.approval,
      steps: [
        WorkflowStepDefinition(id: 's1', name: 'Manager', order: 0, requiredRole: 'manager'),
        WorkflowStepDefinition(id: 's2', name: 'Director', order: 1, requiredRole: 'director'),
      ],
    ));
    final start = engine.workflowEngine.start(instanceId: 'inst-1', definitionId: 'wf-1', entityId: 'po-1');
    expect(start.isSuccess, isTrue);
    final advanced = engine.advanceWorkflowOnApproval(instance: start.dataOrNull!, actorRole: 'manager');
    expect(advanced.isSuccess, isTrue);
    expect(advanced.dataOrNull!.currentStepIndex, 1);
  });
}
