import 'package:fashion_pos_enterprise/core/business/domain/entities/workflow_models.dart';
import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';

/// Configurable workflow engine for purchases, sales, returns, transfers, and approvals.
class WorkflowEngine {
  WorkflowEngine({List<WorkflowDefinition> definitions = const []})
      : _definitions = {for (final d in definitions) d.id: d};

  final Map<String, WorkflowDefinition> _definitions;

  void registerDefinition(WorkflowDefinition definition) {
    _definitions[definition.id] = definition;
  }

  Result<WorkflowInstance> start({
    required String instanceId,
    required String definitionId,
    required String entityId,
    DateTime? startedAt,
  }) {
    final definition = _definitions[definitionId];
    if (definition == null || !definition.isActive) {
      return const Error(ValidationFailure(message: 'Workflow definition not found', code: 'invalid_workflow'));
    }

    return Success(
      WorkflowInstance(
        id: instanceId,
        definitionId: definitionId,
        type: definition.type,
        entityId: entityId,
        currentStepIndex: 0,
        stepStatuses: List.filled(definition.steps.length, WorkflowStepStatus.pending),
        startedAt: startedAt ?? DateTime.now().toUtc(),
      ),
    );
  }

  Result<WorkflowInstance> advance(WorkflowInstance instance, {String? actorRole}) {
    final definition = _definitions[instance.definitionId];
    if (definition == null) {
      return const Error(ValidationFailure(message: 'Workflow definition not found', code: 'invalid_workflow'));
    }
    if (!instance.isActive) {
      return const Error(ValidationFailure(message: 'Workflow is not active', code: 'workflow_inactive'));
    }

    final currentStep = definition.steps[instance.currentStepIndex];
    if (currentStep.requiredRole != null && currentStep.requiredRole != actorRole) {
      return Error(
        ValidationFailure(message: 'Role $actorRole cannot advance step ${currentStep.name}', code: 'workflow_forbidden'),
      );
    }

    final statuses = List<WorkflowStepStatus>.from(instance.stepStatuses);
    statuses[instance.currentStepIndex] = WorkflowStepStatus.completed;

    final nextIndex = instance.currentStepIndex + 1;
    if (nextIndex >= definition.steps.length) {
      if (nextIndex < statuses.length) statuses[nextIndex] = WorkflowStepStatus.completed;
      return Success(
        instance.copyWith(
          stepStatuses: statuses,
          currentStepIndex: definition.steps.length - 1,
          completedAt: DateTime.now().toUtc(),
        ),
      );
    }

    statuses[nextIndex] = WorkflowStepStatus.inProgress;
    return Success(instance.copyWith(stepStatuses: statuses, currentStepIndex: nextIndex));
  }

  Result<WorkflowInstance> reject(WorkflowInstance instance, {String? reason}) {
    if (!instance.isActive) {
      return const Error(ValidationFailure(message: 'Workflow is not active', code: 'workflow_inactive'));
    }
    final statuses = List<WorkflowStepStatus>.from(instance.stepStatuses);
    statuses[instance.currentStepIndex] = WorkflowStepStatus.rejected;
    return Success(
      instance.copyWith(
        stepStatuses: statuses,
        cancelledAt: DateTime.now().toUtc(),
        metadata: {...instance.metadata, if (reason != null) 'reject_reason': reason},
      ),
    );
  }

  Result<WorkflowInstance> cancel(WorkflowInstance instance) {
    if (!instance.isActive) {
      return const Error(ValidationFailure(message: 'Workflow is not active', code: 'workflow_inactive'));
    }
    final statuses = List<WorkflowStepStatus>.from(instance.stepStatuses);
    statuses[instance.currentStepIndex] = WorkflowStepStatus.cancelled;
    return Success(
      instance.copyWith(stepStatuses: statuses, cancelledAt: DateTime.now().toUtc()),
    );
  }

  WorkflowDefinition? getDefinition(String id) => _definitions[id];
}
