import 'package:collection/collection.dart';

import 'package:fashion_pos_enterprise/core/business/domain/entities/rule_models.dart';
import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/business/engines/rule_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/workflow_engine.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/entities/approval.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/entities/automation_rule.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/entities/execution.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/entities/scheduled_job.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/entities/workflow.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/enums/automation_enums.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/value_objects/automation_value_objects.dart';

class RuleEvaluationPlan {
  const RuleEvaluationPlan({
    required this.rule,
    required this.matched,
    this.message,
  });

  final AutomationRule rule;
  final bool matched;
  final String? message;
}

class WorkflowRunPlan {
  const WorkflowRunPlan({
    required this.workflow,
    required this.steps,
    required this.canStart,
    this.reason,
  });

  final AutomationWorkflow workflow;
  final List<WorkflowStep> steps;
  final bool canStart;
  final String? reason;
}

class ApprovalCheck {
  const ApprovalCheck({required this.required, this.workflowId, this.reason});

  final bool required;
  final String? workflowId;
  final String? reason;
}

class OrchestrationResult {
  const OrchestrationResult({
    required this.executionId,
    required this.status,
    this.matchedRules = const [],
    this.logs = const [],
    this.errorMessage,
  });

  final String executionId;
  final ExecutionStatus status;
  final List<String> matchedRules;
  final List<String> logs;
  final String? errorMessage;
}

/// Orchestrates rules, workflows, scheduling hooks, approvals, and smart suggestions.
class AutomationEngine {
  AutomationEngine({
    RuleEngine? ruleEngine,
    WorkflowEngine? workflowEngine,
  })  : _ruleEngine = ruleEngine ?? RuleEngine(),
        _workflowEngine = workflowEngine ?? WorkflowEngine();

  final RuleEngine _ruleEngine;
  final WorkflowEngine _workflowEngine;

  void registerCoreRule(BusinessRule rule) => _ruleEngine.registerRule(rule);

  List<RuleEvaluationPlan> evaluateRules({
    required List<AutomationRule> rules,
    required Map<String, dynamic> context,
  }) {
    final active = rules.where((r) => r.isActive).toList()
      ..sort((a, b) => b.priority.compareTo(a.priority));

    return active.map((rule) {
      final businessRule = _toBusinessRule(rule);
      _ruleEngine.registerRule(businessRule);
      final results = _ruleEngine.evaluate(context);
      final match = results.firstWhereOrNull((r) => r.ruleId == rule.id);
      return RuleEvaluationPlan(
        rule: rule,
        matched: match?.matched ?? false,
        message: match?.message,
      );
    }).toList();
  }

  Future<List<RuleEvaluationPlan>> evaluateAndExecuteRules({
    required List<AutomationRule> rules,
    required Map<String, dynamic> context,
  }) async {
    for (final rule in rules.where((r) => r.isActive)) {
      _ruleEngine.registerRule(_toBusinessRule(rule));
    }
    final results = await _ruleEngine.evaluateAndExecute(context);
    return rules.map((rule) {
      final match = results.firstWhereOrNull((r) => r.ruleId == rule.id);
      return RuleEvaluationPlan(rule: rule, matched: match?.matched ?? false, message: match?.message);
    }).toList();
  }

  WorkflowRunPlan planWorkflow({
    required AutomationWorkflow workflow,
    required List<WorkflowStep> steps,
  }) {
    if (!workflow.isActive) {
      return WorkflowRunPlan(workflow: workflow, steps: steps, canStart: false, reason: 'Workflow is not active');
    }
    if (steps.isEmpty) {
      return WorkflowRunPlan(workflow: workflow, steps: steps, canStart: false, reason: 'Workflow has no steps');
    }
    final ordered = List<WorkflowStep>.from(steps)..sort((a, b) => a.stepOrder.compareTo(b.stepOrder));
    return WorkflowRunPlan(workflow: workflow, steps: ordered, canStart: true);
  }

  Result<OrchestrationResult> startExecution({
    required String executionId,
    required TriggerEventType trigger,
    AutomationRule? rule,
    AutomationWorkflow? workflow,
    ScheduledJob? job,
    String? targetEntityType,
    String? targetEntityId,
  }) {
    if (rule == null && workflow == null && job == null) {
      return const Error(ValidationFailure(message: 'No automation target specified', code: 'invalid_target'));
    }
    return Success(
      OrchestrationResult(
        executionId: executionId,
        status: ExecutionStatus.running,
        matchedRules: rule != null ? [rule.id] : const [],
        logs: ['Execution $executionId started for ${trigger.value}'],
      ),
    );
  }

  OrchestrationResult completeExecution({
    required OrchestrationResult current,
    required bool succeeded,
    String? errorMessage,
    List<String> additionalLogs = const [],
  }) =>
      OrchestrationResult(
        executionId: current.executionId,
        status: succeeded ? ExecutionStatus.succeeded : ExecutionStatus.failed,
        matchedRules: current.matchedRules,
        logs: [...current.logs, ...additionalLogs, if (errorMessage != null) errorMessage],
        errorMessage: errorMessage,
      );

  ApprovalCheck requiresApproval({
    required List<ApprovalWorkflow> workflows,
    required String targetEntityType,
    required double amount,
    double threshold = 0,
  }) {
    if (threshold > 0 && amount < threshold) {
      return const ApprovalCheck(required: false, reason: 'Below threshold');
    }
    final match = workflows.firstWhereOrNull(
      (w) => w.isActive && (w.targetEntityType == null || w.targetEntityType == targetEntityType),
    );
    if (match == null) return const ApprovalCheck(required: false);
    return ApprovalCheck(required: true, workflowId: match.id, reason: 'Approval workflow ${match.name}');
  }

  bool canResolveApproval({
    required ApprovalRequest request,
    required String actorRole,
    required ApprovalWorkflow workflow,
  }) {
    if (request.status != ApprovalStatus.pending) return false;
    if (workflow.requiredRoles.isEmpty) return true;
    return workflow.requiredRoles.contains(actorRole);
  }

  List<SmartSuggestion> generateSuggestions({
    required List<AutomationRule> rules,
    required List<AutomationWorkflow> workflows,
    required List<AutomationExecution> recentExecutions,
    required List<ScheduledJob> jobs,
  }) {
    final suggestions = <SmartSuggestion>[];
    final failed = recentExecutions.where((e) => e.status == ExecutionStatus.failed).length;
    if (failed > 3) {
      suggestions.add(SmartSuggestion(
        id: 'suggest-review-failures',
        type: SuggestionType.optimization,
        title: 'Review failing automations',
        description: '$failed recent executions failed. Consider pausing or fixing rules.',
        confidence: 0.85,
      ));
    }
    final inactiveRules = rules.where((r) => r.status == RuleStatus.draft).length;
    if (inactiveRules > 0) {
      suggestions.add(SmartSuggestion(
        id: 'suggest-activate-rules',
        type: SuggestionType.rule,
        title: 'Activate draft rules',
        description: '$inactiveRules rules are still in draft status.',
        confidence: 0.7,
      ));
    }
    final overdueJobs = jobs.where((j) => j.nextRunAt != null && j.nextRunAt!.isBefore(DateTime.now().toUtc())).length;
    if (overdueJobs > 0) {
      suggestions.add(SmartSuggestion(
        id: 'suggest-overdue-jobs',
        type: SuggestionType.schedule,
        title: 'Overdue scheduled jobs',
        description: '$overdueJobs jobs are past their next run time.',
        confidence: 0.9,
      ));
    }
    if (workflows.isEmpty) {
      suggestions.add(SmartSuggestion(
        id: 'suggest-create-workflow',
        type: SuggestionType.workflow,
        title: 'Create your first workflow',
        description: 'Automate multi-step processes with workflows.',
        confidence: 0.6,
      ));
    }
    return suggestions;
  }

  ExecutionSummary summarize({
    required List<AutomationExecution> executions,
    required List<AutomationRule> rules,
    required List<AutomationWorkflow> workflows,
    required List<JobQueueItem> queue,
  }) =>
      ExecutionSummary(
        totalExecutions: executions.length,
        succeeded: executions.where((e) => e.status == ExecutionStatus.succeeded).length,
        failed: executions.where((e) => e.status == ExecutionStatus.failed).length,
        pending: executions.where((e) => e.status == ExecutionStatus.pending || e.status == ExecutionStatus.running).length,
        activeRules: rules.where((r) => r.isActive).length,
        activeWorkflows: workflows.where((w) => w.isActive).length,
        queuedJobs: queue.where((q) => q.status == JobStatus.queued || q.status == JobStatus.pending).length,
      );

  BusinessRule _toBusinessRule(AutomationRule rule) {
    RuleOperator op = RuleOperator.equal;
    if (rule.conditionOperator != null) {
      op = RuleOperator.values.firstWhereOrNull((o) => o.name == rule.conditionOperator) ?? RuleOperator.equal;
    }
    return BusinessRule(
      id: rule.id,
      name: rule.name,
      priority: rule.priority,
      isActive: rule.isActive,
      condition: RuleCondition(
        field: rule.conditionField ?? '',
        operator: op,
        value: rule.conditionValue,
      ),
      action: RuleAction(
        type: rule.actionType ?? 'notify',
        parameters: rule.actionParameters,
      ),
    );
  }
}
