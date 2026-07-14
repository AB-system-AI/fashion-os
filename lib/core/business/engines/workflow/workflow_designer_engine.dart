import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/entities/workflow_template.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/enums/workflow_enums.dart';

/// Validation issue for workflow designer operations.
class WorkflowValidationIssue extends Equatable {
  const WorkflowValidationIssue({required this.code, required this.message, this.field});

  final String code;
  final String message;
  final String? field;

  @override
  List<Object?> get props => [code, message, field];
}

/// Result of template validation.
class WorkflowValidationResult extends Equatable {
  const WorkflowValidationResult({required this.isValid, this.issues = const []});

  final bool isValid;
  final List<WorkflowValidationIssue> issues;

  @override
  List<Object?> get props => [isValid, issues];
}

/// Simulated step outcome for dry-run.
class WorkflowSimulationStep extends Equatable {
  const WorkflowSimulationStep({
    required this.stepIndex,
    required this.stepName,
    required this.action,
    this.conditionMet = true,
    this.skipped = false,
  });

  final int stepIndex;
  final String stepName;
  final String action;
  final bool conditionMet;
  final bool skipped;

  @override
  List<Object?> get props => [stepIndex, stepName, action, conditionMet, skipped];
}

/// Full simulation trace.
class WorkflowSimulationResult extends Equatable {
  const WorkflowSimulationResult({
    required this.templateId,
    required this.versionNumber,
    required this.steps,
    required this.wouldComplete,
  });

  final String templateId;
  final int versionNumber;
  final List<WorkflowSimulationStep> steps;
  final bool wouldComplete;

  @override
  List<Object?> get props => [templateId, versionNumber, steps, wouldComplete];
}

/// Export bundle for workflow templates.
class WorkflowExportBundle extends Equatable {
  const WorkflowExportBundle({
    required this.template,
    required this.versions,
    required this.variables,
    required this.exportedAt,
  });

  final WorkflowTemplate template;
  final List<WorkflowVersion> versions;
  final List<WorkflowVariable> variables;
  final DateTime exportedAt;

  Map<String, dynamic> toJson() => {
        'template': template.toPayload(),
        'versions': versions.map((v) => v.toPayload()).toList(),
        'variables': variables.map((v) => v.toPayload()).toList(),
        'exported_at': exportedAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [template.id, exportedAt];
}

/// Pure workflow designer logic — versions, publish/archive, validation, clone, simulate, import/export.
class WorkflowDesignerEngine {
  WorkflowValidationResult validateTemplate(WorkflowTemplate template, WorkflowVersion version) {
    final issues = <WorkflowValidationIssue>[];
    if (template.name.trim().isEmpty) {
      issues.add(const WorkflowValidationIssue(code: 'name_required', message: 'Template name is required', field: 'name'));
    }
    if (version.steps.isEmpty) {
      issues.add(const WorkflowValidationIssue(code: 'steps_required', message: 'At least one step is required', field: 'steps'));
    }
    for (var i = 0; i < version.steps.length; i++) {
      final step = version.steps[i];
      if (step.name.trim().isEmpty) {
        issues.add(WorkflowValidationIssue(code: 'step_name', message: 'Step $i name is required', field: 'steps[$i].name'));
      }
      if (step.actions.isEmpty) {
        issues.add(WorkflowValidationIssue(code: 'step_actions', message: 'Step $i must have at least one action', field: 'steps[$i].actions'));
      }
    }
    for (final variable in version.variables) {
      if (variable.key.trim().isEmpty) {
        issues.add(const WorkflowValidationIssue(code: 'variable_key', message: 'Variable key is required', field: 'variables'));
      }
    }
    return WorkflowValidationResult(isValid: issues.isEmpty, issues: issues);
  }

  WorkflowVersion createDraftVersion({
    required WorkflowTemplate template,
    required WorkflowVersion? latestVersion,
    required List<WorkflowAction> steps,
    List<WorkflowVariable> variables = const [],
    List<WorkflowCondition> conditions = const [],
  }) {
    final nextNumber = (latestVersion?.versionNumber ?? 0) + 1;
    return WorkflowVersion(
      id: '${template.id}-v$nextNumber',
      tenantId: template.tenantId,
      templateId: template.id,
      versionNumber: nextNumber,
      status: WorkflowVersionStatus.draft,
      steps: steps,
      variables: variables,
      conditions: conditions,
      version: 1,
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
      syncStatus: template.syncStatus,
      isDirty: true,
    );
  }

  WorkflowVersion publishVersion(WorkflowVersion draft) {
    if (draft.status != WorkflowVersionStatus.draft) {
      throw StateError('Only draft versions can be published');
    }
    final validation = validateTemplate(
      WorkflowTemplate(
        id: draft.templateId,
        tenantId: draft.tenantId,
        name: 'publish-check',
        version: draft.version,
        createdAt: draft.createdAt,
        updatedAt: draft.updatedAt,
        syncStatus: draft.syncStatus,
        isDirty: draft.isDirty,
      ),
      draft,
    );
    if (!validation.isValid) {
      throw StateError('Cannot publish invalid version: ${validation.issues.first.message}');
    }
    final now = DateTime.now().toUtc();
    return draft.copyWith(status: WorkflowVersionStatus.published, publishedAt: now, updatedAt: now);
  }

  WorkflowVersion archiveVersion(WorkflowVersion version) {
    final now = DateTime.now().toUtc();
    return version.copyWith(status: WorkflowVersionStatus.archived, archivedAt: now, updatedAt: now);
  }

  WorkflowTemplate cloneTemplate({
    required WorkflowTemplate source,
    required WorkflowVersion sourceVersion,
    required String newId,
    required String newName,
  }) {
    final now = DateTime.now().toUtc();
    return source.copyWith(
      id: newId,
      name: newName,
      status: WorkflowDefinitionStatus.draft,
      version: 1,
      createdAt: now,
      updatedAt: now,
      isDirty: true,
    );
  }

  WorkflowVersion cloneVersion({
    required WorkflowVersion source,
    required String newTemplateId,
    required int versionNumber,
  }) {
    final now = DateTime.now().toUtc();
    return WorkflowVersion(
      id: '$newTemplateId-v$versionNumber',
      tenantId: source.tenantId,
      templateId: newTemplateId,
      versionNumber: versionNumber,
      status: WorkflowVersionStatus.draft,
      steps: source.steps,
      variables: source.variables,
      conditions: source.conditions,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: source.syncStatus,
      isDirty: true,
    );
  }

  WorkflowSimulationResult simulate({
    required WorkflowTemplate template,
    required WorkflowVersion version,
    Map<String, dynamic> context = const {},
  }) {
    final trace = <WorkflowSimulationStep>[];
    var wouldComplete = true;
    for (var i = 0; i < version.steps.length; i++) {
      final step = version.steps[i];
      final conditionMet = _evaluateConditions(version.conditions, context, stepIndex: i);
      if (!conditionMet) {
        trace.add(WorkflowSimulationStep(
          stepIndex: i,
          stepName: step.name,
          action: step.actions.isNotEmpty ? step.actions.first.actionType.value : 'none',
          conditionMet: false,
          skipped: true,
        ));
        continue;
      }
      for (final action in step.actions) {
        trace.add(WorkflowSimulationStep(
          stepIndex: i,
          stepName: step.name,
          action: action.actionType.value,
          conditionMet: true,
        ));
      }
    }
    if (version.steps.isEmpty) wouldComplete = false;
    return WorkflowSimulationResult(
      templateId: template.id,
      versionNumber: version.versionNumber,
      steps: trace,
      wouldComplete: wouldComplete,
    );
  }

  WorkflowExportBundle exportBundle({
    required WorkflowTemplate template,
    required List<WorkflowVersion> versions,
    required List<WorkflowVariable> variables,
  }) =>
      WorkflowExportBundle(
        template: template,
        versions: versions,
        variables: variables,
        exportedAt: DateTime.now().toUtc(),
      );

  ({WorkflowTemplate template, List<WorkflowVersion> versions, List<WorkflowVariable> variables}) importBundle(
    Map<String, dynamic> json,
    String tenantId,
  ) {
    final templateJson = Map<String, dynamic>.from(json['template'] as Map? ?? {});
    final now = DateTime.now().toUtc();
    final template = WorkflowTemplate(
      id: templateJson['id'] as String? ?? 'imported-${now.millisecondsSinceEpoch}',
      tenantId: tenantId,
      name: templateJson['name'] as String? ?? 'Imported workflow',
      description: templateJson['description'] as String?,
      categoryId: templateJson['category_id'] as String?,
      status: WorkflowDefinitionStatus.draft,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );
    final versions = (json['versions'] as List? ?? [])
        .map((v) => WorkflowVersion.fromPayloadMap(Map<String, dynamic>.from(v as Map), tenantId: tenantId))
        .toList();
    final variables = (json['variables'] as List? ?? [])
        .map((v) => WorkflowVariable.fromPayload(Map<String, dynamic>.from(v as Map), tenantId: tenantId))
        .toList();
    return (template: template, versions: versions, variables: variables);
  }

  bool _evaluateConditions(List<WorkflowCondition> conditions, Map<String, dynamic> context, {required int stepIndex}) {
    final stepConditions = conditions.where((c) => c.stepIndex == null || c.stepIndex == stepIndex);
    if (stepConditions.isEmpty) return true;
    for (final condition in stepConditions) {
      final actual = context[condition.field];
      final expected = condition.value;
      final met = switch (condition.operator) {
        ConditionOperator.equals => '$actual' == '$expected',
        ConditionOperator.notEquals => '$actual' != '$expected',
        ConditionOperator.greaterThan => (actual as num?) != null && (expected as num?) != null && actual > expected,
        ConditionOperator.lessThan => (actual as num?) != null && (expected as num?) != null && actual < expected,
        ConditionOperator.contains => '$actual'.contains('$expected'),
        ConditionOperator.exists => actual != null,
      };
      if (!met) return false;
    }
    return true;
  }
}
