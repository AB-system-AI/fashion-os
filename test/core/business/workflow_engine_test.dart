import 'package:fashion_pos_enterprise/core/business/domain/entities/workflow_models.dart';
import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/business/engines/workflow_engine.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WorkflowEngine', () {
    late WorkflowEngine engine;
    late WorkflowDefinition saleWorkflow;

    setUp(() {
      engine = WorkflowEngine();
      saleWorkflow = const WorkflowDefinition(
        id: 'wf_sale',
        name: 'Sale Approval',
        type: WorkflowType.sales,
        steps: [
          WorkflowStepDefinition(id: 's1', name: 'Draft', order: 0),
          WorkflowStepDefinition(id: 's2', name: 'Manager Approval', order: 1, requiredRole: 'manager'),
          WorkflowStepDefinition(id: 's3', name: 'Complete', order: 2),
        ],
      );
      engine.registerDefinition(saleWorkflow);
    });

    test('starts workflow at first step', () {
      final result = engine.start(
        instanceId: 'inst1',
        definitionId: 'wf_sale',
        entityId: 'sale1',
      );
      final instance = (result as Success<WorkflowInstance>).data;
      expect(instance.currentStepIndex, 0);
      expect(instance.isActive, isTrue);
    });

    test('advances through steps with correct role', () {
      final start = engine.start(
        instanceId: 'inst1',
        definitionId: 'wf_sale',
        entityId: 'sale1',
      );
      var instance = (start as Success<WorkflowInstance>).data;

      instance = (engine.advance(instance) as Success<WorkflowInstance>).data;
      expect(instance.currentStepIndex, 1);

      final forbidden = engine.advance(instance, actorRole: 'cashier');
      expect(forbidden.isFailure, isTrue);

      instance = (engine.advance(instance, actorRole: 'manager') as Success<WorkflowInstance>).data;
      expect(instance.currentStepIndex, 2);
    });

    test('cancels active workflow', () {
      final start = engine.start(
        instanceId: 'inst1',
        definitionId: 'wf_sale',
        entityId: 'sale1',
      );
      final cancelled = engine.cancel((start as Success<WorkflowInstance>).data);
      final instance = (cancelled as Success<WorkflowInstance>).data;
      expect(instance.isCancelled, isTrue);
      expect(instance.currentStatus, WorkflowStepStatus.cancelled);
    });
  });
}
