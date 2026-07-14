import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';

/// Workflow step definition.
class WorkflowStepDefinition extends Equatable {
  const WorkflowStepDefinition({
    required this.id,
    required this.name,
    required this.order,
    this.requiredRole,
    this.isOptional = false,
    this.metadata = const {},
  });

  final String id;
  final String name;
  final int order;
  final String? requiredRole;
  final bool isOptional;
  final Map<String, dynamic> metadata;

  @override
  List<Object?> get props => [id, order];
}

/// Workflow template.
class WorkflowDefinition extends Equatable {
  const WorkflowDefinition({
    required this.id,
    required this.name,
    required this.type,
    required this.steps,
    this.isActive = true,
  });

  final String id;
  final String name;
  final WorkflowType type;
  final List<WorkflowStepDefinition> steps;
  final bool isActive;

  @override
  List<Object?> get props => [id, type, steps];
}

/// Running workflow instance.
class WorkflowInstance extends Equatable {
  const WorkflowInstance({
    required this.id,
    required this.definitionId,
    required this.type,
    required this.entityId,
    required this.currentStepIndex,
    required this.stepStatuses,
    required this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.metadata = const {},
  });

  final String id;
  final String definitionId;
  final WorkflowType type;
  final String entityId;
  final int currentStepIndex;
  final List<WorkflowStepStatus> stepStatuses;
  final DateTime startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final Map<String, dynamic> metadata;

  bool get isComplete => completedAt != null;
  bool get isCancelled => cancelledAt != null;
  bool get isActive => !isComplete && !isCancelled;

  WorkflowStepStatus get currentStatus => stepStatuses[currentStepIndex];

  WorkflowInstance copyWith({
    int? currentStepIndex,
    List<WorkflowStepStatus>? stepStatuses,
    DateTime? completedAt,
    DateTime? cancelledAt,
    Map<String, dynamic>? metadata,
  }) {
    return WorkflowInstance(
      id: id,
      definitionId: definitionId,
      type: type,
      entityId: entityId,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      stepStatuses: stepStatuses ?? this.stepStatuses,
      startedAt: startedAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [id, type, entityId, currentStepIndex];
}
