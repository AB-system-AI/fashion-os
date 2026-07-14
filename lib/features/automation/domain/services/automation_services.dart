import 'package:collection/collection.dart';
import 'package:uuid/uuid.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_action.dart';
import 'package:fashion_pos_enterprise/core/audit/audit_service.dart';
import 'package:fashion_pos_enterprise/core/business/engines/automation/automation_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/automation/scheduler_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/notification_engine.dart';
import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/pagination/paginated_result.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_engine.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/entities/approval.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/entities/automation_rule.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/entities/execution.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/entities/scheduled_job.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/entities/settings.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/entities/template.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/entities/workflow.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/enums/automation_enums.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/repositories/automation_repositories.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/services/ai/insights_service.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/services/ai/recommendation_service.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/value_objects/automation_value_objects.dart';

class AutomationService {
  AutomationService({
    required AutomationRuleRepository rules,
    required AutomationWorkflowRepository workflows,
    required AutomationExecutionRepository executions,
    required ScheduledJobRepository jobs,
    required JobQueueRepository queue,
    required AutomationSettingsRepository settings,
    required AutomationEngine engine,
    required SchedulerEngine scheduler,
    required AuditService audit,
    required PermissionEngine permissions,
    Uuid? uuid,
  })  : _rules = rules,
        _workflows = workflows,
        _executions = executions,
        _jobs = jobs,
        _queue = queue,
        _settings = settings,
        _engine = engine,
        _scheduler = scheduler,
        _audit = audit,
        _permissions = permissions,
        _uuid = uuid ?? const Uuid();

  final AutomationRuleRepository _rules;
  final AutomationWorkflowRepository _workflows;
  final AutomationExecutionRepository _executions;
  final ScheduledJobRepository _jobs;
  final JobQueueRepository _queue;
  final AutomationSettingsRepository _settings;
  final AutomationEngine _engine;
  final SchedulerEngine _scheduler;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final Uuid _uuid;

  Future<Result<ExecutionSummary>> dashboard({required AuthUser user}) async {
    try {
      _permissions.require(user, AutomationPermissions.view);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final tenantId = user.tenantId!;
    final rules = await _rules.listActive(tenantId);
    final workflows = await _workflows.listActive(tenantId);
    final executions = await _executions.listRecent(tenantId);
    final queue = await _queue.listPending(tenantId);
    return Success(_engine.summarize(
      executions: executions,
      rules: rules,
      workflows: workflows,
      queue: queue,
    ));
  }

  Future<Result<AutomationExecution>> triggerEvent({
    required AuthUser user,
    required TriggerEventType event,
    required Map<String, dynamic> context,
    String? targetEntityType,
    String? targetEntityId,
  }) async {
    try {
      _permissions.require(user, AutomationPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final tenantId = user.tenantId!;
    final settings = await _settings.getSettings(tenantId);
    if (settings != null && !settings.enableRules && !settings.enableWorkflows) {
      return const Error(ValidationFailure(message: 'Automation is disabled', code: 'automation_disabled'));
    }
    final activeRules = await _rules.listByTrigger(tenantId, event, entityType: targetEntityType);
    final plans = await _engine.evaluateAndExecuteRules(rules: activeRules, context: context);
    final matched = plans.where((p) => p.matched).map((p) => p.rule.id).toList();
    final now = DateTime.now().toUtc();
    final executionId = _uuid.v4();
    final start = _engine.startExecution(
      executionId: executionId,
      trigger: event,
      rule: activeRules.isNotEmpty ? activeRules.first : null,
      targetEntityType: targetEntityType,
      targetEntityId: targetEntityId,
    );
    if (start.isFailure) return Error(start.failureOrNull!);
    final completed = _engine.completeExecution(
      current: start.dataOrNull!,
      succeeded: matched.isNotEmpty || activeRules.isEmpty,
      additionalLogs: ['Matched ${matched.length} rules'],
    );
    final execution = await _executions.create(AutomationExecution(
      id: executionId,
      tenantId: tenantId,
      ruleId: matched.isNotEmpty ? matched.first : null,
      status: completed.status,
      triggerEvent: event,
      targetEntityType: targetEntityType,
      targetEntityId: targetEntityId,
      startedAt: now,
      completedAt: now,
      result: {'matched_rules': matched},
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    await _audit.log(action: AuditAction.create, entityType: AutomationExecution.entityTypeName, tenantId: tenantId, employeeId: user.employeeId, entityId: execution.id);
    return Success(execution);
  }
}

class RuleAutomationService {
  RuleAutomationService({
    required AutomationRuleRepository repository,
    required AutomationEngine engine,
    required AuditService audit,
    required PermissionEngine permissions,
    Uuid? uuid,
  })  : _repo = repository,
        _engine = engine,
        _audit = audit,
        _permissions = permissions,
        _uuid = uuid ?? const Uuid();

  final AutomationRuleRepository _repo;
  final AutomationEngine _engine;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final Uuid _uuid;

  Future<Result<AutomationRule>> create({
    required AuthUser user,
    required String name,
    RuleConditionInput? condition,
    RuleActionInput? action,
    TriggerEventType trigger = TriggerEventType.manual,
    String? triggerEntityType,
    int priority = 0,
  }) async {
    try {
      _permissions.require(user, RulePermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final now = DateTime.now().toUtc();
    final rule = await _repo.create(AutomationRule(
      id: _uuid.v4(),
      tenantId: user.tenantId!,
      name: name,
      triggerEvent: trigger,
      triggerEntityType: triggerEntityType,
      conditionField: condition?.field,
      conditionOperator: condition?.operator,
      conditionValue: condition?.value?.toString(),
      actionType: action?.type,
      actionParameters: action?.parameters ?? const {},
      priority: priority,
      createdBy: user.employeeId,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    await _audit.log(action: AuditAction.create, entityType: AutomationRule.entityTypeName, tenantId: rule.tenantId, employeeId: user.employeeId, entityId: rule.id);
    return Success(rule);
  }

  Future<Result<AutomationRule>> activate({required AuthUser user, required AutomationRule rule}) async {
    try {
      _permissions.require(user, RulePermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final now = DateTime.now().toUtc();
    final saved = await _repo.update(rule.copyWith(status: RuleStatus.active, version: rule.version + 1, updatedAt: now, syncStatus: LocalSyncStatus.pending, isDirty: true));
    await _audit.log(action: AuditAction.update, entityType: AutomationRule.entityTypeName, tenantId: saved.tenantId, employeeId: user.employeeId, entityId: saved.id, metadata: {'status': 'active'});
    return Success(saved);
  }

  Future<PaginatedResult<AutomationRule>> list(String tenantId) => _repo.getPage(RepositoryQuery(tenantId: tenantId, pageSize: 200));

  List<RuleEvaluationPlan> evaluate({required List<AutomationRule> rules, required Map<String, dynamic> context}) =>
      _engine.evaluateRules(rules: rules, context: context);
}

class WorkflowAutomationService {
  WorkflowAutomationService({
    required AutomationWorkflowRepository repository,
    required AutomationEngine engine,
    required AuditService audit,
    required PermissionEngine permissions,
    Uuid? uuid,
  })  : _repo = repository,
        _engine = engine,
        _audit = audit,
        _permissions = permissions,
        _uuid = uuid ?? const Uuid();

  final AutomationWorkflowRepository _repo;
  final AutomationEngine _engine;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final Uuid _uuid;

  Future<Result<AutomationWorkflow>> create({
    required AuthUser user,
    required String name,
    required List<WorkflowStepInput> steps,
    TriggerEventType trigger = TriggerEventType.manual,
    String? triggerEntityType,
  }) async {
    try {
      _permissions.require(user, WorkflowPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final now = DateTime.now().toUtc();
    final workflow = await _repo.create(AutomationWorkflow(
      id: _uuid.v4(),
      tenantId: user.tenantId!,
      name: name,
      triggerEvent: trigger,
      triggerEntityType: triggerEntityType,
      createdBy: user.employeeId,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    for (final step in steps) {
      await _repo.createStep(WorkflowStep(
        id: _uuid.v4(),
        tenantId: user.tenantId!,
        workflowId: workflow.id,
        name: step.name,
        stepType: step.stepType,
        stepOrder: step.stepOrder,
        config: step.config,
        requiredRole: step.requiredRole,
        version: 1,
        createdAt: now,
        updatedAt: now,
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ));
    }
    await _audit.log(action: AuditAction.create, entityType: AutomationWorkflow.entityTypeName, tenantId: workflow.tenantId, employeeId: user.employeeId, entityId: workflow.id);
    return Success(workflow);
  }

  Future<Result<AutomationWorkflow>> activate({required AuthUser user, required AutomationWorkflow workflow}) async {
    try {
      _permissions.require(user, WorkflowPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final steps = await _repo.listSteps(workflow.tenantId, workflow.id);
    final plan = _engine.planWorkflow(workflow: workflow, steps: steps);
    if (!plan.canStart) return Error(ValidationFailure(message: plan.reason ?? 'Cannot activate', code: 'invalid_workflow'));
    final now = DateTime.now().toUtc();
    final saved = await _repo.update(workflow.copyWith(status: WorkflowStatus.active, version: workflow.version + 1, updatedAt: now, syncStatus: LocalSyncStatus.pending, isDirty: true));
    return Success(saved);
  }

  Future<PaginatedResult<AutomationWorkflow>> list(String tenantId) => _repo.getPage(RepositoryQuery(tenantId: tenantId, pageSize: 200));
}

class SchedulerService {
  SchedulerService({
    required ScheduledJobRepository jobs,
    required JobQueueRepository queue,
    required SchedulerEngine scheduler,
    required AuditService audit,
    required PermissionEngine permissions,
    Uuid? uuid,
  })  : _jobs = jobs,
        _queue = queue,
        _scheduler = scheduler,
        _audit = audit,
        _permissions = permissions,
        _uuid = uuid ?? const Uuid();

  final ScheduledJobRepository _jobs;
  final JobQueueRepository _queue;
  final SchedulerEngine _scheduler;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final Uuid _uuid;

  Future<Result<ScheduledJob>> schedule({
    required AuthUser user,
    required String name,
    required ScheduleSpec spec,
    String? ruleId,
    String? workflowId,
    Map<String, dynamic> payload = const {},
  }) async {
    try {
      _permissions.require(user, SchedulerPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    if (spec.scheduleType == JobScheduleType.cron) {
      final validation = _scheduler.validateCron(spec.cronExpression);
      if (!validation.isValid) return Error(ValidationFailure(message: validation.reason ?? 'Invalid cron', code: 'invalid_cron'));
    }
    final now = DateTime.now().toUtc();
    final next = _scheduler.computeNextRun(spec: spec, now: now);
    final job = await _jobs.create(ScheduledJob(
      id: _uuid.v4(),
      tenantId: user.tenantId!,
      name: name,
      scheduleType: spec.scheduleType,
      cronExpression: spec.cronExpression,
      intervalSeconds: spec.intervalSeconds,
      runAt: spec.runAt,
      timezone: spec.timezone,
      nextRunAt: next.nextRunAt,
      ruleId: ruleId,
      workflowId: workflowId,
      payload: payload,
      createdBy: user.employeeId,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    await _audit.log(action: AuditAction.create, entityType: ScheduledJob.entityTypeName, tenantId: job.tenantId, employeeId: user.employeeId, entityId: job.id);
    return Success(job);
  }

  Future<Result<JobQueueItem>> enqueueDue({required AuthUser user}) async {
    try {
      _permissions.require(user, SchedulerPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final tenantId = user.tenantId!;
    final now = DateTime.now().toUtc();
    final due = await _jobs.listDue(tenantId, now);
    final sorted = _scheduler.sortByPriority(due, now: now);
    if (sorted.isEmpty) return const Error(ValidationFailure(message: 'No due jobs', code: 'no_jobs'));
    final job = sorted.first;
    final item = await _queue.create(JobQueueItem(
      id: _uuid.v4(),
      tenantId: tenantId,
      scheduledJobId: job.id,
      scheduledFor: now,
      payload: job.payload,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    await _jobs.update(_scheduler.markEnqueued(job, job.nextRunAt ?? now));
    return Success(item);
  }

  Future<List<ScheduledJob>> list(String tenantId) async {
    final page = await _jobs.getPage(RepositoryQuery(tenantId: tenantId, pageSize: 200));
    return page.items;
  }
}

class ApprovalService {
  ApprovalService({
    required ApprovalWorkflowRepository workflows,
    required ApprovalRequestRepository requests,
    required AutomationEngine engine,
    required AutomationSettingsRepository settings,
    required AuditService audit,
    required PermissionEngine permissions,
    Uuid? uuid,
  })  : _workflows = workflows,
        _requests = requests,
        _engine = engine,
        _settings = settings,
        _audit = audit,
        _permissions = permissions,
        _uuid = uuid ?? const Uuid();

  final ApprovalWorkflowRepository _workflows;
  final ApprovalRequestRepository _requests;
  final AutomationEngine _engine;
  final AutomationSettingsRepository _settings;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final Uuid _uuid;

  Future<Result<ApprovalRequest>> requestApproval({
    required AuthUser user,
    required String workflowId,
    required String targetEntityType,
    required String targetEntityId,
  }) async {
    try {
      _permissions.require(user, ApprovalWorkflowPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final now = DateTime.now().toUtc();
    final settings = await _settings.getSettings(user.tenantId!);
    final expiryHours = settings?.defaultApprovalExpiryHours ?? 72;
    final request = await _requests.create(ApprovalRequest(
      id: _uuid.v4(),
      tenantId: user.tenantId!,
      approvalWorkflowId: workflowId,
      targetEntityType: targetEntityType,
      targetEntityId: targetEntityId,
      requestedBy: user.employeeId,
      expiresAt: now.add(Duration(hours: expiryHours)),
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    await _audit.log(action: AuditAction.create, entityType: ApprovalRequest.entityTypeName, tenantId: request.tenantId, employeeId: user.employeeId, entityId: request.id);
    return Success(request);
  }

  Future<Result<ApprovalRequest>> resolve({
    required AuthUser user,
    required ApprovalRequest request,
    required ApprovalDecisionInput decision,
    required String actorRole,
  }) async {
    try {
      _permissions.require(user, ApprovalWorkflowPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final workflow = await _workflows.getById(request.approvalWorkflowId, tenantId: user.tenantId);
    if (workflow == null) return const Error(ValidationFailure(message: 'Workflow not found', code: 'not_found'));
    if (!_engine.canResolveApproval(request: request, actorRole: actorRole, workflow: workflow)) {
      return const Error(ValidationFailure(message: 'Cannot resolve approval', code: 'forbidden'));
    }
    final now = DateTime.now().toUtc();
    final saved = await _requests.update(request.copyWith(
      status: decision.approved ? ApprovalStatus.approved : ApprovalStatus.rejected,
      approvedBy: decision.approved ? user.employeeId : null,
      rejectedBy: decision.approved ? null : user.employeeId,
      comment: decision.comment,
      resolvedAt: now,
      version: request.version + 1,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    return Success(saved);
  }

  Future<List<ApprovalRequest>> listPending(String tenantId) => _requests.listPending(tenantId);
}

class TemplateService {
  TemplateService({
    required DocumentTemplateRepository repository,
    required AuditService audit,
    required PermissionEngine permissions,
    Uuid? uuid,
  })  : _repo = repository,
        _audit = audit,
        _permissions = permissions,
        _uuid = uuid ?? const Uuid();

  final DocumentTemplateRepository _repo;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final Uuid _uuid;

  Future<Result<DocumentTemplate>> create({
    required AuthUser user,
    required String name,
    required TemplateType type,
    String? subject,
    String? body,
    List<String> variables = const [],
  }) async {
    try {
      _permissions.require(user, AutomationPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final now = DateTime.now().toUtc();
    final template = await _repo.create(DocumentTemplate(
      id: _uuid.v4(),
      tenantId: user.tenantId!,
      name: name,
      templateType: type,
      subject: subject,
      body: body,
      variables: variables,
      createdBy: user.employeeId,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    await _audit.log(action: AuditAction.create, entityType: DocumentTemplate.entityTypeName, tenantId: template.tenantId, employeeId: user.employeeId, entityId: template.id);
    return Success(template);
  }

  String render(DocumentTemplate template, Map<String, dynamic> variables) {
    var output = template.body ?? '';
    for (final entry in variables.entries) {
      output = output.replaceAll('{{${entry.key}}}', entry.value.toString());
    }
    return output;
  }

  Future<List<DocumentTemplate>> list(String tenantId) => _repo.listActive(tenantId);
}

class NotificationAutomationService {
  NotificationAutomationService({
    required NotificationEngine notificationEngine,
    required TemplateService templates,
    required PermissionEngine permissions,
  })  : _notifications = notificationEngine,
        _templates = templates,
        _permissions = permissions;

  final NotificationEngine _notifications;
  final TemplateService _templates;
  final PermissionEngine _permissions;

  Future<Result<void>> sendFromTemplate({
    required AuthUser user,
    required TemplateRenderInput input,
    NotificationChannel channel = NotificationChannel.inApp,
    String? recipientId,
  }) async {
    try {
      _permissions.require(user, AutomationPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final list = await _templates.list(user.tenantId!);
    final template = list.where((t) => t.id == input.templateId).firstOrNull;
    if (template == null) return const Error(ValidationFailure(message: 'Template not found', code: 'not_found'));
    final body = _templates.render(template, input.variables);
    await _notifications.send(NotificationMessage(
      channel: channel,
      title: template.subject ?? template.name,
      body: body,
      recipientId: recipientId,
    ));
    return const Success(null);
  }
}

class SmartSuggestionService {
  SmartSuggestionService({
    required AutomationRuleRepository rules,
    required AutomationWorkflowRepository workflows,
    required AutomationExecutionRepository executions,
    required ScheduledJobRepository jobs,
    required AutomationEngine engine,
    required RecommendationService recommendations,
    required InsightsService insights,
    required PermissionEngine permissions,
  })  : _rules = rules,
        _workflows = workflows,
        _executions = executions,
        _jobs = jobs,
        _engine = engine,
        _recommendations = recommendations,
        _insights = insights,
        _permissions = permissions;

  final AutomationRuleRepository _rules;
  final AutomationWorkflowRepository _workflows;
  final AutomationExecutionRepository _executions;
  final ScheduledJobRepository _jobs;
  final AutomationEngine _engine;
  final RecommendationService _recommendations;
  final InsightsService _insights;
  final PermissionEngine _permissions;

  Future<Result<List<SmartSuggestion>>> suggest({required AuthUser user}) async {
    try {
      _permissions.require(user, AiPermissions.view);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final tenantId = user.tenantId!;
    final rules = (await _rules.getPage(RepositoryQuery(tenantId: tenantId, pageSize: 200))).items;
    final workflows = (await _workflows.getPage(RepositoryQuery(tenantId: tenantId, pageSize: 200))).items;
    final executions = await _executions.listRecent(tenantId);
    final jobList = (await _jobs.getPage(RepositoryQuery(tenantId: tenantId, pageSize: 200))).items;
    final engineSuggestions = _engine.generateSuggestions(
      rules: rules,
      workflows: workflows,
      recentExecutions: executions,
      jobs: jobList,
    );
    final recommended = await _recommendations.recommendRules(tenantId: tenantId);
    return Success([...engineSuggestions, ...recommended]);
  }

  Future<Result<List<String>>> insights({required AuthUser user}) async {
    try {
      _permissions.require(user, AiPermissions.view);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final items = await _insights.generateInsights(tenantId: user.tenantId!);
    return Success(items);
  }
}
