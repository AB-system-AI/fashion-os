import 'package:uuid/uuid.dart';

import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/business/engines/notification_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/workflow/approval_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/workflow/scheduler_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/workflow/workflow_designer_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/workflow_engine.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/pagination/paginated_result.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_engine.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/entities/approval.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/entities/approval_extended.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/entities/approval_template.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/entities/notification.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/entities/workflow_instance.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/entities/notification_providers.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/entities/notification_queue.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/entities/scheduler.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/entities/workflow_execution.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/entities/workflow_template.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/enums/workflow_enums.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/repositories/workflow_repositories.dart';

const _uuid = Uuid();

class WorkflowDashboardMetrics {
  const WorkflowDashboardMetrics({
    required this.activeDefinitions,
    required this.activeInstances,
    required this.pendingApprovals,
  });

  final int activeDefinitions;
  final int activeInstances;
  final int pendingApprovals;
}

class WorkflowAdminService {
  WorkflowAdminService({
    required TenantWorkflowDefinitionRepository definitions,
    required TenantWorkflowInstanceRepository instances,
    required ApprovalRequestRepository approvals,
    required WorkflowEngine workflowEngine,
    required PermissionEngine permissions,
  })  : _definitions = definitions,
        _instances = instances,
        _approvals = approvals,
        _workflowEngine = workflowEngine,
        _permissions = permissions;

  final TenantWorkflowDefinitionRepository _definitions;
  final TenantWorkflowInstanceRepository _instances;
  final ApprovalRequestRepository _approvals;
  final WorkflowEngine _workflowEngine;
  final PermissionEngine _permissions;

  Future<Result<WorkflowDashboardMetrics>> loadDashboard(AuthUser user) async {
    try {
      _permissions.require(user, WorkflowAdminPermissions.admin);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final tenantId = user.tenantId!;
    final defs = await _definitions.listActive(tenantId);
    final inst = await _instances.listActive(tenantId);
    final pending = await _approvals.listPending(tenantId);
    return Success(WorkflowDashboardMetrics(
      activeDefinitions: defs.length,
      activeInstances: inst.length,
      pendingApprovals: pending.length,
    ));
  }

  Future<Result<PaginatedResult<TenantWorkflowDefinition>>> listDefinitions(AuthUser user, {int page = 1}) async {
    try {
      _permissions.require(user, WorkflowAdminPermissions.admin);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final pageResult = await _definitions.getPage(RepositoryQuery(tenantId: user.tenantId!, page: page, pageSize: 50));
    return Success(pageResult);
  }

  WorkflowEngine get workflowEngine => _workflowEngine;
}

class ApprovalService {
  ApprovalService({
    required ApprovalTemplateRepository templates,
    required ApprovalMatrixRepository matrices,
    required ApprovalRequestRepository requests,
    required ApprovalHistoryRepository history,
    required ApprovalDelegationRepository delegations,
    required ApprovalEngine approvalEngine,
    required PermissionEngine permissions,
  })  : _templates = templates,
        _matrices = matrices,
        _requests = requests,
        _history = history,
        _delegations = delegations,
        _engine = approvalEngine,
        _permissions = permissions;

  final ApprovalTemplateRepository _templates;
  final ApprovalMatrixRepository _matrices;
  final ApprovalRequestRepository _requests;
  final ApprovalHistoryRepository _history;
  final ApprovalDelegationRepository _delegations;
  final ApprovalEngine _engine;
  final PermissionEngine _permissions;

  Future<Result<List<ApprovalRequest>>> listPending(AuthUser user) async {
    try {
      _permissions.require(user, ApprovalPermissions.view);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final items = await _requests.listPending(user.tenantId!, assignedTo: user.userId);
    return Success(items);
  }

  Future<Result<ApprovalRequest>> approve({
    required AuthUser user,
    required String requestId,
    required String actorRole,
    String? comment,
  }) async {
    try {
      _permissions.require(user, ApprovalPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final request = await _requests.getById(requestId);
    if (request == null || request.tenantId != user.tenantId) {
      return const Error(ValidationFailure(message: 'Request not found', code: 'not_found'));
    }
    if (!request.isPending) {
      return const Error(ValidationFailure(message: 'Request is not pending', code: 'invalid_state'));
    }

    final matrixRows = await _loadMatrixRows(request);
    final resolved = _engine.resolveMatrix(matrix: matrixRows, amount: request.amount, entityType: request.targetEntityType);
    if (!_engine.canActorApprove(resolved: resolved, currentStepIndex: request.currentStepIndex, actorRole: actorRole)) {
      return const Error(ValidationFailure(message: 'Actor cannot approve this step', code: 'forbidden'));
    }

    final now = DateTime.now().toUtc();
    final isLastStep = request.currentStepIndex + 1 >= resolved.rows.length;
    final updated = request.copyWith(
      status: isLastStep ? ApprovalRequestStatus.approved : ApprovalRequestStatus.pending,
      currentStepIndex: isLastStep ? request.currentStepIndex : request.currentStepIndex + 1,
      resolvedAt: isLastStep ? now : null,
      updatedAt: now,
      isDirty: true,
      syncStatus: LocalSyncStatus.pending,
    );
    await _requests.update(updated);

    final entry = _engine.recordHistory(
      requestId: requestId,
      actorId: user.userId,
      decision: ApprovalDecision.approved,
      comment: comment,
      fromRole: actorRole,
    );
    await _saveHistory(user.tenantId!, entry);

    return Success(updated);
  }

  Future<Result<ApprovalRequest>> reject({
    required AuthUser user,
    required String requestId,
    String? comment,
  }) async {
    try {
      _permissions.require(user, ApprovalPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final request = await _requests.getById(requestId);
    if (request == null || request.tenantId != user.tenantId) {
      return const Error(ValidationFailure(message: 'Request not found', code: 'not_found'));
    }
    final now = DateTime.now().toUtc();
    final updated = request.copyWith(
      status: ApprovalRequestStatus.rejected,
      comment: comment,
      resolvedAt: now,
      updatedAt: now,
      isDirty: true,
      syncStatus: LocalSyncStatus.pending,
    );
    await _requests.update(updated);
    await _saveHistory(
      user.tenantId!,
      _engine.recordHistory(requestId: requestId, actorId: user.userId, decision: ApprovalDecision.rejected, comment: comment),
    );
    return Success(updated);
  }

  Future<List<ApprovalMatrixRow>> _loadMatrixRows(ApprovalRequest request) async {
    final rows = await _matrices.listByTemplate(request.tenantId, request.templateId);
    return rows
        .map((m) => ApprovalMatrixRow(
              stepOrder: m.stepOrder,
              requiredRole: m.requiredRole,
              minAmount: m.minAmount,
              maxAmount: m.maxAmount,
              isOptional: m.isOptional,
            ))
        .toList();
  }

  Future<void> _saveHistory(String tenantId, ApprovalHistoryEntry entry) async {
    final now = DateTime.now().toUtc();
    await _history.create(ApprovalHistory(
      id: _uuid.v4(),
      tenantId: tenantId,
      requestId: entry.requestId,
      actorId: entry.actorId,
      decision: entry.decision.name,
      occurredAt: entry.occurredAt,
      comment: entry.comment,
      fromRole: entry.fromRole,
      toUserId: entry.toUserId,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
  }
}

class NotificationCenterService {
  NotificationCenterService({
    required NotificationCenterRepository repository,
    required NotificationEngine notificationEngine,
    required PermissionEngine permissions,
  })  : _repository = repository,
        _notificationEngine = notificationEngine,
        _permissions = permissions;

  final NotificationCenterRepository _repository;
  final NotificationEngine _notificationEngine;
  final PermissionEngine _permissions;

  Future<Result<List<NotificationCenterItem>>> listUnread(AuthUser user) async {
    try {
      _permissions.require(user, NotificationCenterPermissions.view);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final items = await _repository.listUnread(user.tenantId!, user.userId);
    return Success(items);
  }

  Future<Result<int>> countUnread(AuthUser user) async {
    try {
      _permissions.require(user, NotificationCenterPermissions.view);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final count = await _repository.countUnread(user.tenantId!, user.userId);
    return Success(count);
  }

  Future<Result<NotificationCenterItem>> markRead(AuthUser user, String itemId) async {
    try {
      _permissions.require(user, NotificationCenterPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final item = await _repository.getById(itemId);
    if (item == null || item.tenantId != user.tenantId) {
      return const Error(ValidationFailure(message: 'Notification not found', code: 'not_found'));
    }
    final now = DateTime.now().toUtc();
    final updated = item.copyWith(
      status: NotificationItemStatus.read,
      readAt: now,
      updatedAt: now,
      isDirty: true,
      syncStatus: LocalSyncStatus.pending,
    );
    await _repository.update(updated);
    return Success(updated);
  }

  Future<void> dispatchInApp({
    required String tenantId,
    required String recipientId,
    required String title,
    required String body,
    Map<String, dynamic> data = const {},
  }) async {
    await _notificationEngine.send(
      NotificationMessage(
        channel: NotificationChannel.inApp,
        title: title,
        body: body,
        recipientId: recipientId,
        data: data,
      ),
    );
    final now = DateTime.now().toUtc();
    await _repository.create(NotificationCenterItem(
      id: _uuid.v4(),
      tenantId: tenantId,
      recipientId: recipientId,
      title: title,
      body: body,
      data: data,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
  }
}

class ReminderSchedulerService {
  ReminderSchedulerService({
    required ReminderRuleRepository rules,
    required ApprovalRequestRepository requests,
    required NotificationCenterService notificationCenter,
    required PermissionEngine permissions,
  })  : _rules = rules,
        _requests = requests,
        _notificationCenter = notificationCenter,
        _permissions = permissions;

  final ReminderRuleRepository _rules;
  final ApprovalRequestRepository _requests;
  final NotificationCenterService _notificationCenter;
  final PermissionEngine _permissions;

  Future<Result<int>> processDueReminders(AuthUser user) async {
    try {
      _permissions.require(user, WorkflowAdminPermissions.admin);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final tenantId = user.tenantId!;
    final rules = await _rules.listActive(tenantId);
    final pending = await _requests.listPending(tenantId);
    var sent = 0;
    final now = DateTime.now().toUtc();
    for (final request in pending) {
      for (final rule in rules) {
        if (rule.targetEntityType != null && rule.targetEntityType != request.targetEntityType) continue;
        final hoursSince = now.difference(request.createdAt).inHours;
        if (hoursSince >= rule.intervalHours && request.assignedTo != null) {
          await _notificationCenter.dispatchInApp(
            tenantId: tenantId,
            recipientId: request.assignedTo!,
            title: 'Approval reminder',
            body: 'Pending approval for ${request.targetEntityType ?? 'item'}',
            data: {'request_id': request.id},
          );
          sent++;
        }
      }
    }
    return Success(sent);
  }
}

class EscalationService {
  EscalationService({
    required EscalationRuleRepository rules,
    required ApprovalRequestRepository requests,
    required ApprovalEngine approvalEngine,
    required NotificationCenterService notificationCenter,
    required PermissionEngine permissions,
  })  : _rules = rules,
        _requests = requests,
        _engine = approvalEngine,
        _notificationCenter = notificationCenter,
        _permissions = permissions;

  final EscalationRuleRepository _rules;
  final ApprovalRequestRepository _requests;
  final ApprovalEngine _engine;
  final NotificationCenterService _notificationCenter;
  final PermissionEngine _permissions;

  Future<Result<int>> processEscalations(AuthUser user) async {
    try {
      _permissions.require(user, WorkflowAdminPermissions.admin);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final tenantId = user.tenantId!;
    final rules = await _rules.listActive(tenantId);
    final pending = await _requests.listPending(tenantId);
    var escalated = 0;
    final now = DateTime.now().toUtc();
    for (final request in pending) {
      for (final rule in rules) {
        if (rule.targetEntityType != null && rule.targetEntityType != request.targetEntityType) continue;
        final evaluation = _engine.evaluateEscalation(
          requestedAt: request.createdAt,
          timeout: Duration(hours: rule.timeoutHours),
          currentRole: null,
          escalateToRole: rule.escalateToRole,
          now: now,
        );
        if (!evaluation.shouldEscalate) continue;
        final updated = request.copyWith(
          status: ApprovalRequestStatus.escalated,
          updatedAt: now,
          isDirty: true,
          syncStatus: LocalSyncStatus.pending,
        );
        await _requests.update(updated);
        if (request.assignedTo != null) {
          await _notificationCenter.dispatchInApp(
            tenantId: tenantId,
            recipientId: request.assignedTo!,
            title: 'Approval escalated',
            body: evaluation.reason ?? 'Approval escalated',
            data: {'request_id': request.id},
          );
        }
        escalated++;
      }
    }
    return Success(escalated);
  }
}

class WorkflowDesignerService {
  WorkflowDesignerService({
    required WorkflowTemplateRepository templates,
    required WorkflowVersionRepository versions,
    required WorkflowDesignerEngine designerEngine,
    required PermissionEngine permissions,
  })  : _templates = templates,
        _versions = versions,
        _engine = designerEngine,
        _permissions = permissions;

  final WorkflowTemplateRepository _templates;
  final WorkflowVersionRepository _versions;
  final WorkflowDesignerEngine _engine;
  final PermissionEngine _permissions;

  Future<Result<List<WorkflowTemplate>>> listTemplates(AuthUser user) async {
    try {
      _permissions.require(user, WorkflowAdminPermissions.admin);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final items = await _templates.listByTenant(user.tenantId!);
    return Success(items);
  }

  Future<Result<WorkflowVersion>> publishDraft(AuthUser user, String versionId) async {
    try {
      _permissions.require(user, WorkflowAdminPermissions.admin);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final draft = await _versions.getById(versionId);
    if (draft == null || draft.tenantId != user.tenantId) {
      return const Error(ValidationFailure(message: 'Version not found', code: 'not_found'));
    }
    try {
      final published = _engine.publishVersion(draft);
      await _versions.update(published);
      return Success(published);
    } on StateError catch (e) {
      return Error(ValidationFailure(message: e.message, code: 'invalid_state'));
    }
  }

  Future<Result<WorkflowSimulationResult>> simulate(AuthUser user, String templateId, String versionId,
      {Map<String, dynamic> context = const {}}) async {
    try {
      _permissions.require(user, WorkflowAdminPermissions.admin);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final template = await _templates.getById(templateId);
    final version = await _versions.getById(versionId);
    if (template == null || version == null) {
      return const Error(ValidationFailure(message: 'Template or version not found', code: 'not_found'));
    }
    return Success(_engine.simulate(template: template, version: version, context: context));
  }

  Future<Result<WorkflowExportBundle>> exportTemplate(AuthUser user, String templateId) async {
    try {
      _permissions.require(user, WorkflowAdminPermissions.admin);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final template = await _templates.getById(templateId);
    if (template == null) {
      return const Error(ValidationFailure(message: 'Template not found', code: 'not_found'));
    }
    final versions = await _versions.listByTemplate(user.tenantId!, templateId);
    return Success(_engine.exportBundle(template: template, versions: versions, variables: const []));
  }
}

class ApprovalExtendedService {
  ApprovalExtendedService({
    required ApprovalRequestRepository requests,
    required ApprovalHistoryRepository history,
    required PermissionEngine permissions,
  })  : _requests = requests,
        _history = history,
        _permissions = permissions;

  final ApprovalRequestRepository _requests;
  final ApprovalHistoryRepository _history;
  final PermissionEngine _permissions;

  ExtendedApprovalPlan resolvePlan({
    required List<ExtendedApprovalStep> steps,
    double? amount,
    String? departmentId,
    String? roleId,
    String? userId,
    Map<String, dynamic>? context,
  }) {
    final resolved = <ExtendedApprovalStep>[];
    var skipped = 0;
    for (final step in steps) {
      final applicable = step.patterns.where((p) => p.matchesContext(
            amount: amount,
            departmentId: departmentId,
            roleId: roleId,
            userId: userId,
            context: context,
          ));
      if (applicable.isEmpty) {
        if (step.isOptional) skipped++;
        continue;
      }
      resolved.add(step);
    }
    resolved.sort((a, b) => a.order.compareTo(b.order));
    return ExtendedApprovalPlan(steps: resolved, skippedOptional: skipped);
  }

  bool evaluateParallelCompletion(ApprovalVoteTally tally, ApprovalPattern pattern) {
    if (pattern.type == ApprovalPatternType.percentage && pattern.requiredPercentage != null) {
      return tally.meetsPercentage(pattern.requiredPercentage!);
    }
    return tally.approved >= pattern.requiredApprovers;
  }

  Future<Result<ApprovalAnalyticsSnapshot>> loadAnalytics(AuthUser user) async {
    try {
      _permissions.require(user, ApprovalPermissions.view);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final tenantId = user.tenantId!;
    final approved = await _requests.listByStatus(tenantId, ApprovalRequestStatus.approved.value);
    final rejected = await _requests.listByStatus(tenantId, ApprovalRequestStatus.rejected.value);
    final pending = await _requests.listPending(tenantId);
    final total = approved.totalCount + rejected.totalCount + pending.length;
  return Success(ApprovalAnalyticsSnapshot(
      totalRequests: total,
      approvedCount: approved.totalCount,
      rejectedCount: rejected.totalCount,
      avgResolutionHours: 24,
      byPattern: {ApprovalPatternType.sequential: approved.totalCount},
    ));
  }
}

class NotificationDispatchService {
  NotificationDispatchService({
    required NotificationQueueRepository queue,
    required DeadLetterRepository deadLetter,
    required NotificationPreferenceRepository preferences,
    required NotificationEngine notificationEngine,
    required PermissionEngine permissions,
  })  : _queue = queue,
        _deadLetter = deadLetter,
        _preferences = preferences,
        _notificationEngine = notificationEngine,
        _permissions = permissions {
    registerWorkflowNotificationProviders(_notificationEngine);
  }

  final NotificationQueueRepository _queue;
  final DeadLetterRepository _deadLetter;
  final NotificationPreferenceRepository _preferences;
  final NotificationEngine _notificationEngine;
  final PermissionEngine _permissions;

  Future<Result<int>> processQueue(AuthUser user, {int batchSize = 50}) async {
    try {
      _permissions.require(user, NotificationCenterPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final tenantId = user.tenantId!;
    final pending = await _queue.listPending(tenantId, limit: batchSize);
    var sent = 0;
    final now = DateTime.now().toUtc();
    for (final item in pending) {
      final pref = await _preferences.getByUser(tenantId, item.recipientId);
      if (pref != null && !pref.isChannelEnabled(item.channel)) continue;
      if (pref != null && pref.isInQuietHours(now)) continue;

      final results = await _notificationEngine.send(NotificationMessage(
        channel: item.channel,
        title: item.title,
        body: item.body,
        recipientId: item.recipientId,
        data: item.data,
      ));
      final success = results.isNotEmpty && results.first.success;
      if (success) {
        await _queue.update(item.copyWith(
          status: NotificationQueueStatus.sent,
          updatedAt: now,
          isDirty: true,
          syncStatus: LocalSyncStatus.pending,
        ));
        sent++;
      } else {
        final attempts = item.attemptCount + 1;
        if (attempts >= item.maxAttempts) {
          await _deadLetter.create(DeadLetterItem(
            id: _uuid.v4(),
            tenantId: tenantId,
            originalQueueId: item.id,
            reason: results.isNotEmpty ? (results.first.errorMessage ?? 'Max attempts exceeded') : 'Max attempts exceeded',
            payload: item.toPayload(),
            version: 1,
            createdAt: now,
            updatedAt: now,
            syncStatus: LocalSyncStatus.pending,
            isDirty: true,
          ));
          await _queue.update(item.copyWith(
            status: NotificationQueueStatus.deadLetter,
            attemptCount: attempts,
            lastError: results.isNotEmpty ? results.first.errorMessage : null,
            updatedAt: now,
            isDirty: true,
            syncStatus: LocalSyncStatus.pending,
          ));
        } else {
          await _queue.update(item.copyWith(
            status: NotificationQueueStatus.failed,
            attemptCount: attempts,
            lastError: results.isNotEmpty ? results.first.errorMessage : null,
            updatedAt: now,
            isDirty: true,
            syncStatus: LocalSyncStatus.pending,
          ));
        }
      }
    }
    return Success(sent);
  }

  Future<Result<NotificationPreference>> savePreferences(AuthUser user, NotificationPreference preference) async {
    try {
      _permissions.require(user, NotificationCenterPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    if (preference.userId != user.userId) {
      return const Error(ValidationFailure(message: 'Cannot modify other user preferences', code: 'forbidden'));
    }
    final now = DateTime.now().toUtc();
    final updated = NotificationPreference(
      id: preference.id,
      tenantId: user.tenantId!,
      userId: user.userId,
      enabledChannels: preference.enabledChannels,
      quietHours: preference.quietHours,
      version: preference.version + 1,
      createdAt: preference.createdAt,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );
    await _preferences.update(updated);
    return Success(updated);
  }
}

class SchedulerService {
  SchedulerService({
    required SchedulerJobRepository jobs,
    required SchedulerExecutionLogRepository logs,
    required WorkflowSchedulerEngine schedulerEngine,
    required PermissionEngine permissions,
  })  : _jobs = jobs,
        _logs = logs,
        _engine = schedulerEngine,
        _permissions = permissions;

  final SchedulerJobRepository _jobs;
  final SchedulerExecutionLogRepository _logs;
  final WorkflowSchedulerEngine _engine;
  final PermissionEngine _permissions;

  Future<Result<SchedulerHealth>> loadHealth(AuthUser user) async {
    try {
      _permissions.require(user, WorkflowAdminPermissions.admin);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final tenantId = user.tenantId!;
    final jobs = await _jobs.listActive(tenantId);
    final recentLogs = await _logs.listRecent(tenantId, limit: 100);
    return Success(_engine.evaluateHealth(jobs: jobs, recentLogs: recentLogs));
  }

  Future<Result<int>> processDueJobs(AuthUser user) async {
    try {
      _permissions.require(user, WorkflowAdminPermissions.admin);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final tenantId = user.tenantId!;
    final jobs = await _jobs.listActive(tenantId);
    final sorted = _engine.sortByPriority(jobs);
    var processed = 0;
    final now = DateTime.now().toUtc();
    for (final job in sorted) {
      if (!_engine.isDue(job: job)) continue;
      final running = _engine.markRunning(job, now);
      await _jobs.update(running);
      await _logs.create(JobExecutionLog(
        id: _uuid.v4(),
        tenantId: tenantId,
        jobId: job.id,
        startedAt: now,
        version: 1,
        createdAt: now,
        updatedAt: now,
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ));
      final completed = _engine.markCompleted(running, now);
      await _jobs.update(completed.copyWith(isDirty: true, syncStatus: LocalSyncStatus.pending, updatedAt: now));
      processed++;
    }
    return Success(processed);
  }
}

class WorkflowReportService {
  WorkflowReportService({
    required WorkflowExecutionRepository executions,
    required WorkflowStatisticsRepository statistics,
    required PermissionEngine permissions,
  })  : _executions = executions,
        _statistics = statistics,
        _permissions = permissions;

  final WorkflowExecutionRepository _executions;
  final WorkflowStatisticsRepository _statistics;
  final PermissionEngine _permissions;

  Future<Result<List<WorkflowStatistics>>> loadStatistics(AuthUser user, {String? templateId}) async {
    try {
      _permissions.require(user, WorkflowAdminPermissions.admin);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final items = await _statistics.listByTenant(user.tenantId!, templateId: templateId);
    return Success(items);
  }

  Future<Result<WorkflowStatistics>> aggregatePeriod(AuthUser user, String templateId, DateTime start, DateTime end) async {
    try {
      _permissions.require(user, WorkflowAdminPermissions.admin);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final execs = await _executions.listByTemplate(user.tenantId!, templateId);
    final inPeriod = execs.where((e) => !e.createdAt.isBefore(start) && !e.createdAt.isAfter(end)).toList();
    final completed = inPeriod.where((e) => e.status == WorkflowExecutionStatus.completed).length;
    final failed = inPeriod.where((e) => e.status == WorkflowExecutionStatus.failed).length;
    var totalDuration = 0.0;
    var durationCount = 0;
    for (final e in inPeriod) {
      if (e.startedAt != null && e.completedAt != null) {
        totalDuration += e.completedAt!.difference(e.startedAt!).inSeconds;
        durationCount++;
      }
    }
    final now = DateTime.now().toUtc();
    final stats = WorkflowStatistics(
      id: _uuid.v4(),
      tenantId: user.tenantId!,
      templateId: templateId,
      periodStart: start,
      periodEnd: end,
      totalExecutions: inPeriod.length,
      completedCount: completed,
      failedCount: failed,
      avgDurationSeconds: durationCount == 0 ? 0 : totalDuration / durationCount,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );
    await _statistics.create(stats);
    return Success(stats);
  }
}
