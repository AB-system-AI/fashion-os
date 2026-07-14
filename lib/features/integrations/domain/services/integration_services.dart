import 'dart:convert';

import 'package:uuid/uuid.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_action.dart';
import 'package:fashion_pos_enterprise/core/audit/audit_service.dart';
import 'package:fashion_pos_enterprise/core/business/engines/integration/integration_connector_engine.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/import_export/import_export_service.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/pagination/paginated_result.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_engine.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_engine.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/integrations/domain/entities/communication.dart';
import 'package:fashion_pos_enterprise/features/integrations/domain/entities/connector.dart';
import 'package:fashion_pos_enterprise/features/integrations/domain/entities/import_export_job.dart';
import 'package:fashion_pos_enterprise/features/integrations/domain/entities/integration_log.dart';
import 'package:fashion_pos_enterprise/features/integrations/domain/enums/integration_enums.dart';
import 'package:fashion_pos_enterprise/features/integrations/domain/repositories/integration_repositories.dart';
import 'package:fashion_pos_enterprise/features/integrations/domain/services/integration_abstractions.dart';

class RateLimiterService {
  RateLimiterService({IntegrationConnectorEngine? engine}) : _engine = engine ?? IntegrationConnectorEngine();

  final IntegrationConnectorEngine _engine;
  final Map<String, ({int count, DateTime windowStart})> _windows = {};

  bool isLimited(String key, {int? limitPerMinute}) {
    final window = _windows[key];
    final now = DateTime.now().toUtc();
    if (window == null) {
      _windows[key] = (count: 1, windowStart: now);
      return false;
    }
    if (now.difference(window.windowStart).inMinutes >= 1) {
      _windows[key] = (count: 1, windowStart: now);
      return false;
    }
    final limited = _engine.isRateLimited(
      requestCount: window.count,
      limitPerMinute: limitPerMinute ?? _engine.defaultRateLimitPerMinute,
      windowStart: window.windowStart,
      now: now,
    );
    if (!limited) {
      _windows[key] = (count: window.count + 1, windowStart: window.windowStart);
    }
    return limited;
  }

  void reset(String key) => _windows.remove(key);
}

class HealthCheckService {
  HealthCheckService({
    required IntegrationConnectorRepository connectors,
    IntegrationConnectorEngine? engine,
  })  : _connectors = connectors,
        _engine = engine ?? IntegrationConnectorEngine();

  final IntegrationConnectorRepository _connectors;
  final IntegrationConnectorEngine _engine;

  Future<HealthCheckResult> checkConnector(IntegrationConnector connector) async {
    return _engine.evaluateHealth(
      isEnabled: connector.isEnabled,
      lastSuccessAt: connector.lastSuccessAt,
      lastFailureAt: connector.lastFailureAt,
      consecutiveFailures: connector.consecutiveFailures,
    );
  }

  Future<Map<String, HealthCheckResult>> checkAll(String tenantId) async {
    final page = await _connectors.getPage(RepositoryQuery(tenantId: tenantId, pageSize: 200));
    final results = <String, HealthCheckResult>{};
    for (final c in page.items) {
      results[c.id] = await checkConnector(c);
    }
    return results;
  }
}

class ConnectorService {
  ConnectorService({
    required IntegrationConnectorRepository repository,
    required IntegrationConnectorEngine engine,
    required AuditService audit,
    required PermissionEngine permissions,
    required IntegrationLogService logs,
    Uuid? uuid,
  })  : _repo = repository,
        _engine = engine,
        _audit = audit,
        _permissions = permissions,
        _logs = logs,
        _uuid = uuid ?? const Uuid();

  final IntegrationConnectorRepository _repo;
  final IntegrationConnectorEngine _engine;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final IntegrationLogService _logs;
  final Uuid _uuid;

  Future<Result<IntegrationConnector>> create({
    required AuthUser user,
    required String name,
    required ConnectorType type,
    String? providerKey,
    Map<String, dynamic> config = const {},
    int rateLimitPerMinute = 60,
  }) async {
    try {
      _permissions.require(user, ConnectorPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final now = DateTime.now().toUtc();
    final connector = await _repo.create(IntegrationConnector(
      id: _uuid.v4(),
      tenantId: user.tenantId!,
      name: name,
      connectorType: type,
      providerKey: providerKey,
      config: config,
      rateLimitPerMinute: rateLimitPerMinute,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    await _audit.log(action: AuditAction.create, entityType: IntegrationConnector.entityTypeName, tenantId: connector.tenantId, employeeId: user.employeeId, entityId: connector.id);
    return Success(connector);
  }

  Future<Result<IntegrationConnector>> recordSuccess(IntegrationConnector connector) async {
    final now = DateTime.now().toUtc();
    final saved = await _repo.update(connector.copyWith(
      status: ConnectorStatus.active,
      lastSuccessAt: now,
      consecutiveFailures: 0,
      version: connector.version + 1,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    return Success(saved);
  }

  Future<Result<IntegrationConnector>> recordFailure(IntegrationConnector connector, {int? statusCode, int attempt = 0}) async {
    final decision = _engine.shouldRetry(attempt: attempt, maxRetries: 3, statusCode: statusCode);
    final now = DateTime.now().toUtc();
    final saved = await _repo.update(connector.copyWith(
      status: decision.shouldRetry ? ConnectorStatus.error : ConnectorStatus.inactive,
      lastFailureAt: now,
      consecutiveFailures: connector.consecutiveFailures + 1,
      version: connector.version + 1,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    await _logs.warn(tenantId: connector.tenantId, message: decision.reason ?? 'Connector failure', connectorId: connector.id);
    return Success(saved);
  }

  Future<PaginatedResult<IntegrationConnector>> list(String tenantId) =>
      _repo.getPage(RepositoryQuery(tenantId: tenantId, pageSize: 200));
}

class WebhookService {
  WebhookService({
    required WebhookRepository repository,
    required AuditService audit,
    required PermissionEngine permissions,
    required IntegrationLogService logs,
    Uuid? uuid,
  })  : _repo = repository,
        _audit = audit,
        _permissions = permissions,
        _logs = logs,
        _uuid = uuid ?? const Uuid();

  final WebhookRepository _repo;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final IntegrationLogService _logs;
  final Uuid _uuid;

  Future<Result<WebhookEndpoint>> create({
    required AuthUser user,
    required String name,
    required String url,
    List<String> events = const [],
  }) async {
    try {
      _permissions.require(user, WebhookPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final now = DateTime.now().toUtc();
    final webhook = await _repo.create(WebhookEndpoint(
      id: _uuid.v4(),
      tenantId: user.tenantId!,
      name: name,
      url: url,
      events: events,
      status: WebhookStatus.active,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    await _audit.log(action: AuditAction.create, entityType: WebhookEndpoint.entityTypeName, tenantId: webhook.tenantId, employeeId: user.employeeId, entityId: webhook.id);
    return Success(webhook);
  }

  Future<Result<void>> dispatch({
    required String tenantId,
    required String event,
    required Map<String, dynamic> payload,
  }) async {
    final endpoints = await _repo.listByEvent(tenantId, event);
    for (final endpoint in endpoints) {
      await _logs.info(
        tenantId: tenantId,
        message: 'Webhook queued: ${endpoint.name}',
        webhookId: endpoint.id,
        eventType: event,
        metadata: payload,
      );
    }
    return const Success(null);
  }

  Future<PaginatedResult<WebhookEndpoint>> list(String tenantId) =>
      _repo.getPage(RepositoryQuery(tenantId: tenantId, pageSize: 200));
}

class EmailIntegrationService {
  EmailIntegrationService({required EmailProvider provider, required IntegrationLogService logs})
      : _provider = provider,
        _logs = logs;

  final EmailProvider _provider;
  final IntegrationLogService _logs;

  Future<Result<EmailMessage>> send({
    required String tenantId,
    required String to,
    required String subject,
    String? body,
    String? from,
  }) async {
    final result = await _provider.send(tenantId: tenantId, to: to, subject: subject, body: body, from: from);
    if (result.isSuccess) {
      await _logs.info(tenantId: tenantId, message: 'Email sent to $to', eventType: 'email.sent');
    } else {
      await _logs.error(tenantId: tenantId, message: 'Email failed: ${result.failureOrNull?.message}', eventType: 'email.failed');
    }
    return result;
  }
}

class SmsIntegrationService {
  SmsIntegrationService({required SmsProvider provider, required IntegrationLogService logs})
      : _provider = provider,
        _logs = logs;

  final SmsProvider _provider;
  final IntegrationLogService _logs;

  Future<Result<SmsMessage>> send({
    required String tenantId,
    required String to,
    required String body,
  }) async {
    final result = await _provider.send(tenantId: tenantId, to: to, body: body);
    if (result.isSuccess) {
      await _logs.info(tenantId: tenantId, message: 'SMS sent to $to', eventType: 'sms.sent');
    } else {
      await _logs.error(tenantId: tenantId, message: 'SMS failed', eventType: 'sms.failed');
    }
    return result;
  }
}

class PushIntegrationService {
  PushIntegrationService({required PushProvider provider, required IntegrationLogService logs})
      : _provider = provider,
        _logs = logs;

  final PushProvider _provider;
  final IntegrationLogService _logs;

  Future<Result<PushMessage>> send({
    required String tenantId,
    required String title,
    String? body,
    String? deviceToken,
    Map<String, dynamic> data = const {},
  }) async {
    final result = await _provider.send(tenantId: tenantId, title: title, body: body, deviceToken: deviceToken, data: data);
    if (result.isSuccess) {
      await _logs.info(tenantId: tenantId, message: 'Push sent: $title', eventType: 'push.sent');
    }
    return result;
  }
}

class ImportExportIntegrationService {
  ImportExportIntegrationService({
    required ImportExportService importExport,
    required ImportJobRepository importJobs,
    required ExportJobRepository exportJobs,
    required PermissionEngine permissions,
    required AuditService audit,
    Uuid? uuid,
  })  : _importExport = importExport,
        _importJobs = importJobs,
        _exportJobs = exportJobs,
        _permissions = permissions,
        _audit = audit,
        _uuid = uuid ?? const Uuid();

  final ImportExportService _importExport;
  final ImportJobRepository _importJobs;
  final ExportJobRepository _exportJobs;
  final PermissionEngine _permissions;
  final AuditService _audit;
  final Uuid _uuid;

  Future<Result<ImportJob>> startImport({
    required AuthUser user,
    required String entityType,
    required String csvContent,
    required DataPortAdapter adapter,
    String? fileName,
  }) async {
    try {
      _permissions.require(user, IntegrationPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final now = DateTime.now().toUtc();
    final job = await _importJobs.create(ImportJob(
      id: _uuid.v4(),
      tenantId: user.tenantId!,
      entityType: entityType,
      status: ImportJobStatus.running,
      fileName: fileName,
      createdBy: user.employeeId,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    try {
      final rows = await _importExport.parseCsv(csvContent);
      final result = await adapter.importRows(rows);
      final completed = await _importJobs.update(job.copyWith(
        status: result.success ? ImportJobStatus.completed : ImportJobStatus.failed,
        totalRows: result.totalRows,
        importedRows: result.importedRows,
        failedRows: result.failedRows,
        errors: result.errors,
        completedAt: DateTime.now().toUtc(),
        version: job.version + 1,
        updatedAt: DateTime.now().toUtc(),
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ));
      await _audit.log(action: AuditAction.create, entityType: ImportJob.entityTypeName, tenantId: job.tenantId, employeeId: user.employeeId, entityId: job.id);
      return Success(completed);
    } catch (e) {
      final failed = await _importJobs.update(job.copyWith(
        status: ImportJobStatus.failed,
        errors: [e.toString()],
        completedAt: DateTime.now().toUtc(),
        version: job.version + 1,
        updatedAt: DateTime.now().toUtc(),
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ));
      return Success(failed);
    }
  }

  Future<Result<ExportJob>> startExport({
    required AuthUser user,
    required String entityType,
    required DataPortAdapter adapter,
    String format = 'csv',
  }) async {
    try {
      _permissions.require(user, IntegrationPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final now = DateTime.now().toUtc();
    final job = await _exportJobs.create(ExportJob(
      id: _uuid.v4(),
      tenantId: user.tenantId!,
      entityType: entityType,
      status: ExportJobStatus.running,
      format: format,
      createdBy: user.employeeId,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    try {
      final rows = await adapter.exportRows();
      final payload = await _importExport.exportCsv(entityType: entityType, rows: rows);
      final completed = await _exportJobs.update(job.copyWith(
        status: ExportJobStatus.completed,
        fileName: payload.fileName,
        rowCount: rows.length,
        completedAt: DateTime.now().toUtc(),
        version: job.version + 1,
        updatedAt: DateTime.now().toUtc(),
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ));
      await _audit.log(action: AuditAction.create, entityType: ExportJob.entityTypeName, tenantId: job.tenantId, employeeId: user.employeeId, entityId: job.id, metadata: {'bytes': payload.bytes.length});
      return Success(completed);
    } catch (e) {
      final failed = await _exportJobs.update(job.copyWith(
        status: ExportJobStatus.failed,
        completedAt: DateTime.now().toUtc(),
        version: job.version + 1,
        updatedAt: DateTime.now().toUtc(),
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ));
      return Success(failed);
    }
  }

  Future<PaginatedResult<ImportJob>> listImports(String tenantId) =>
      _importJobs.getPage(RepositoryQuery(tenantId: tenantId, pageSize: 100));

  Future<PaginatedResult<ExportJob>> listExports(String tenantId) =>
      _exportJobs.getPage(RepositoryQuery(tenantId: tenantId, pageSize: 100));
}

class PrinterService {
  PrinterService({
    required PrinterProfileRepository repository,
    required PermissionEngine permissions,
    required AuditService audit,
    Uuid? uuid,
  })  : _repo = repository,
        _permissions = permissions,
        _audit = audit,
        _uuid = uuid ?? const Uuid();

  final PrinterProfileRepository _repo;
  final PermissionEngine _permissions;
  final AuditService _audit;
  final Uuid _uuid;

  Future<Result<PrinterProfile>> create({
    required AuthUser user,
    required String name,
    required PrinterConnectionType connectionType,
    String? address,
    bool isDefault = false,
    int paperWidthMm = 80,
  }) async {
    try {
      _permissions.require(user, IntegrationPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final now = DateTime.now().toUtc();
    final profile = await _repo.create(PrinterProfile(
      id: _uuid.v4(),
      tenantId: user.tenantId!,
      name: name,
      connectionType: connectionType,
      address: address,
      isDefault: isDefault,
      paperWidthMm: paperWidthMm,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    await _audit.log(action: AuditAction.create, entityType: PrinterProfile.entityTypeName, tenantId: profile.tenantId, employeeId: user.employeeId, entityId: profile.id);
    return Success(profile);
  }

  Future<Result<void>> printReceipt({
    required String tenantId,
    required List<int> bytes,
    String? printerId,
  }) async {
    final printer = printerId != null
        ? await _repo.getById(printerId, tenantId: tenantId)
        : await _repo.getDefault(tenantId);
    if (printer == null) {
      return const Error(ValidationFailure(message: 'No printer configured', code: 'printer_not_found'));
    }
    await _audit.log(action: AuditAction.update, entityType: PrinterProfile.entityTypeName, tenantId: tenantId, entityId: printer.id, metadata: {'bytes': bytes.length});
    return const Success(null);
  }

  Future<PaginatedResult<PrinterProfile>> list(String tenantId) =>
      _repo.getPage(RepositoryQuery(tenantId: tenantId, pageSize: 100));
}

class OAuthConnectorService {
  OAuthConnectorService({
    required OAuthProvider provider,
    required OAuthConnectionRepository connections,
    required ConnectorService connectors,
    Uuid? uuid,
  })  : _provider = provider,
        _connections = connections,
        _connectors = connectors,
        _uuid = uuid ?? const Uuid();

  final OAuthProvider _provider;
  final OAuthConnectionRepository _connections;
  final ConnectorService _connectors;
  final Uuid _uuid;

  Future<Result<String>> startAuthorization({
    required AuthUser user,
    required String redirectUri,
    List<String> scopes = const [],
  }) =>
      _provider.buildAuthorizationUrl(tenantId: user.tenantId!, redirectUri: redirectUri, scopes: scopes);

  Future<Result<OAuthConnection>> completeAuthorization({
    required AuthUser user,
    required String provider,
    required String code,
    required String redirectUri,
    String? connectorId,
  }) async {
    final tokenResult = await _provider.exchangeCode(tenantId: user.tenantId!, code: code, redirectUri: redirectUri);
    if (tokenResult.isFailure) return Error(tokenResult.failureOrNull!);
    final token = tokenResult.dataOrNull!;
    final now = DateTime.now().toUtc();
    final connection = await _connections.create(OAuthConnection(
      id: _uuid.v4(),
      tenantId: user.tenantId!,
      provider: provider,
      status: OAuthConnectionStatus.connected,
      scopes: const [],
      expiresAt: token.expiresAt,
      connectorId: connectorId,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    return Success(connection);
  }
}

class IntegrationLogService {
  IntegrationLogService({required IntegrationLogRepository repository, Uuid? uuid})
      : _repo = repository,
        _uuid = uuid ?? const Uuid();

  final IntegrationLogRepository _repo;
  final Uuid _uuid;

  Future<IntegrationLog> info({
    required String tenantId,
    required String message,
    String? connectorId,
    String? webhookId,
    String? eventType,
    Map<String, dynamic> metadata = const {},
  }) =>
      _write(tenantId: tenantId, level: IntegrationLogLevel.info, message: message, connectorId: connectorId, webhookId: webhookId, eventType: eventType, metadata: metadata);

  Future<IntegrationLog> warn({
    required String tenantId,
    required String message,
    String? connectorId,
    Map<String, dynamic> metadata = const {},
  }) =>
      _write(tenantId: tenantId, level: IntegrationLogLevel.warn, message: message, connectorId: connectorId, metadata: metadata);

  Future<IntegrationLog> error({
    required String tenantId,
    required String message,
    String? connectorId,
    String? eventType,
    Map<String, dynamic> metadata = const {},
  }) =>
      _write(tenantId: tenantId, level: IntegrationLogLevel.error, message: message, connectorId: connectorId, eventType: eventType, metadata: metadata);

  Future<IntegrationLog> _write({
    required String tenantId,
    required IntegrationLogLevel level,
    required String message,
    String? connectorId,
    String? webhookId,
    String? eventType,
    Map<String, dynamic> metadata = const {},
  }) async {
    final now = DateTime.now().toUtc();
    return _repo.create(IntegrationLog(
      id: _uuid.v4(),
      tenantId: tenantId,
      level: level,
      message: message,
      connectorId: connectorId,
      webhookId: webhookId,
      eventType: eventType,
      metadata: metadata,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
  }

  Future<PaginatedResult<IntegrationLog>> listRecent(String tenantId) => _repo.listRecent(tenantId);
}

class ApiKeyService {
  ApiKeyService({
    required ApiKeyRepository repository,
    required AuditService audit,
    required PermissionEngine permissions,
    Uuid? uuid,
  })  : _repo = repository,
        _audit = audit,
        _permissions = permissions,
        _uuid = uuid ?? const Uuid();

  final ApiKeyRepository _repo;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final Uuid _uuid;

  Future<Result<({ApiKey key, String secret})>> create({
    required AuthUser user,
    required String name,
    List<String> scopes = const [],
    DateTime? expiresAt,
  }) async {
    try {
      _permissions.require(user, ApiKeyPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final secret = base64Url.encode(utf8.encode('${_uuid.v4()}${_uuid.v4()}'));
    final prefix = secret.substring(0, 8);
    final now = DateTime.now().toUtc();
    final key = await _repo.create(ApiKey(
      id: _uuid.v4(),
      tenantId: user.tenantId!,
      name: name,
      keyPrefix: prefix,
      scopes: scopes,
      expiresAt: expiresAt,
      createdBy: user.employeeId,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    await _audit.log(action: AuditAction.create, entityType: ApiKey.entityTypeName, tenantId: key.tenantId, employeeId: user.employeeId, entityId: key.id);
    return Success((key: key, secret: secret));
  }

  Future<Result<ApiKey>> revoke({required AuthUser user, required ApiKey key}) async {
    try {
      _permissions.require(user, ApiKeyPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final now = DateTime.now().toUtc();
    final saved = await _repo.update(key.copyWith(
      status: ApiKeyStatus.revoked,
      version: key.version + 1,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    return Success(saved);
  }

  Future<PaginatedResult<ApiKey>> list(String tenantId) =>
      _repo.getPage(RepositoryQuery(tenantId: tenantId, pageSize: 100));
}
