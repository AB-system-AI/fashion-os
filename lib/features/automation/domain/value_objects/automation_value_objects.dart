import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/features/automation/domain/enums/automation_enums.dart';

class RuleConditionInput extends Equatable {
  const RuleConditionInput({
    required this.field,
    required this.operator,
    required this.value,
  });

  final String field;
  final String operator;
  final dynamic value;

  @override
  List<Object?> get props => [field, operator, value];
}

class RuleActionInput extends Equatable {
  const RuleActionInput({
    required this.type,
    this.parameters = const {},
  });

  final String type;
  final Map<String, dynamic> parameters;

  @override
  List<Object?> get props => [type, parameters];
}

class WorkflowStepInput extends Equatable {
  const WorkflowStepInput({
    required this.name,
    required this.stepType,
    this.config = const {},
    this.stepOrder = 0,
    this.requiredRole,
  });

  final String name;
  final WorkflowStepType stepType;
  final Map<String, dynamic> config;
  final int stepOrder;
  final String? requiredRole;

  @override
  List<Object?> get props => [name, stepType, stepOrder];
}

class ScheduleSpec extends Equatable {
  const ScheduleSpec({
    required this.scheduleType,
    this.cronExpression,
    this.intervalSeconds,
    this.runAt,
    this.timezone = 'UTC',
  });

  final JobScheduleType scheduleType;
  final String? cronExpression;
  final int? intervalSeconds;
  final DateTime? runAt;
  final String timezone;

  @override
  List<Object?> get props => [scheduleType, cronExpression, intervalSeconds, runAt];
}

class ExecutionSummary extends Equatable {
  const ExecutionSummary({
    required this.totalExecutions,
    required this.succeeded,
    required this.failed,
    required this.pending,
    required this.activeRules,
    required this.activeWorkflows,
    required this.queuedJobs,
  });

  final int totalExecutions;
  final int succeeded;
  final int failed;
  final int pending;
  final int activeRules;
  final int activeWorkflows;
  final int queuedJobs;

  double get successRate => totalExecutions == 0 ? 0 : (succeeded / totalExecutions) * 100;

  @override
  List<Object?> get props => [totalExecutions, succeeded, failed, pending];
}

class SmartSuggestion extends Equatable {
  const SmartSuggestion({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    this.confidence = 0,
    this.metadata = const {},
  });

  final String id;
  final SuggestionType type;
  final String title;
  final String description;
  final double confidence;
  final Map<String, dynamic> metadata;

  @override
  List<Object?> get props => [id, type, title, confidence];
}

class ApprovalDecisionInput extends Equatable {
  const ApprovalDecisionInput({
    required this.approved,
    this.comment,
    this.actorId,
  });

  final bool approved;
  final String? comment;
  final String? actorId;

  @override
  List<Object?> get props => [approved, comment];
}

class TemplateRenderInput extends Equatable {
  const TemplateRenderInput({
    required this.templateId,
    this.variables = const {},
  });

  final String templateId;
  final Map<String, dynamic> variables;

  @override
  List<Object?> get props => [templateId, variables];
}
