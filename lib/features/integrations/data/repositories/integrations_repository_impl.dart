import 'package:fashion_pos_enterprise/core/infrastructure/database/app_database.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/pagination/paginated_result.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/base_local_repository.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/sync_queue_writer.dart';
import 'package:fashion_pos_enterprise/features/integrations/domain/entities/connector.dart';
import 'package:fashion_pos_enterprise/features/integrations/domain/entities/import_export_job.dart';
import 'package:fashion_pos_enterprise/features/integrations/domain/entities/integration_log.dart';
import 'package:fashion_pos_enterprise/features/integrations/domain/enums/integration_enums.dart';
import 'package:fashion_pos_enterprise/features/integrations/domain/repositories/integration_repositories.dart';

typedef IntegrationEntityMapper<T> = T Function(Map<String, dynamic> json, LocalRecord record);

class IntegrationsRepositoryImpl<T extends SyncableEntity> extends BaseLocalRepository<T> {
  IntegrationsRepositoryImpl({
    required AppDatabase database,
    required SyncQueueWriter syncQueue,
    required String entityType,
    required this.fromPayload,
    required this.toSearchFields,
  })  : _database = database,
        _syncQueue = syncQueue,
        super(database: database, entityType: entityType, syncQueue: syncQueue);

  final AppDatabase _database;
  final SyncQueueWriter _syncQueue;
  final IntegrationEntityMapper<T> fromPayload;
  final ({String? name, String? sku, String? barcode, String? storeId}) Function(T entity) toSearchFields;

  @override
  T mapFromLocalRecord(LocalRecord record) => fromPayload(record.payload, record);

  @override
  LocalRecord mapToLocalRecord(T entity) {
    final search = toSearchFields(entity);
    return LocalRecord(
      id: entity.id,
      tenantId: entity.tenantId,
      entityType: entity.entityType,
      storeId: search.storeId,
      payload: entity.toPayload(),
      version: entity.version,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      deletedAt: entity.deletedAt,
      syncStatus: entity.syncStatus,
      isDirty: entity.isDirty,
      searchName: search.name,
      searchSku: search.sku,
      searchBarcode: search.barcode,
    );
  }
}

class IntegrationConnectorLocalRepository extends IntegrationsRepositoryImpl<IntegrationConnector> implements IntegrationConnectorRepository {
  IntegrationConnectorLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: IntegrationConnector.entityTypeName,
          fromPayload: IntegrationConnector.fromPayload,
          toSearchFields: (e) => (name: e.name, sku: e.connectorType.value, barcode: e.providerKey, storeId: null),
        );

  @override
  Future<List<IntegrationConnector>> listByType(String tenantId, ConnectorType type) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 200));
    return page.items.where((c) => c.connectorType == type).toList();
  }
}

class WebhookLocalRepository extends IntegrationsRepositoryImpl<WebhookEndpoint> implements WebhookRepository {
  WebhookLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: WebhookEndpoint.entityTypeName,
          fromPayload: WebhookEndpoint.fromPayload,
          toSearchFields: (e) => (name: e.name, sku: e.url, barcode: null, storeId: null),
        );

  @override
  Future<List<WebhookEndpoint>> listByEvent(String tenantId, String event) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 200));
    return page.items.where((w) => w.status == WebhookStatus.active && w.events.contains(event)).toList();
  }

  @override
  Future<List<WebhookEndpoint>> listActive(String tenantId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 200));
    return page.items.where((w) => w.status == WebhookStatus.active).toList();
  }
}

class ApiKeyLocalRepository extends IntegrationsRepositoryImpl<ApiKey> implements ApiKeyRepository {
  ApiKeyLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: ApiKey.entityTypeName,
          fromPayload: ApiKey.fromPayload,
          toSearchFields: (e) => (name: e.name, sku: e.keyPrefix, barcode: null, storeId: null),
        );

  @override
  Future<List<ApiKey>> listActive(String tenantId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 200));
    return page.items.where((k) => k.status == ApiKeyStatus.active).toList();
  }
}

class IntegrationLogLocalRepository extends IntegrationsRepositoryImpl<IntegrationLog> implements IntegrationLogRepository {
  IntegrationLogLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: IntegrationLog.entityTypeName,
          fromPayload: IntegrationLog.fromPayload,
          toSearchFields: (e) => (name: e.message, sku: e.eventType, barcode: e.level.value, storeId: null),
        );

  @override
  Future<PaginatedResult<IntegrationLog>> listRecent(String tenantId, {int limit = 100}) =>
      getPage(RepositoryQuery(tenantId: tenantId, pageSize: limit));
}

class ImportJobLocalRepository extends IntegrationsRepositoryImpl<ImportJob> implements ImportJobRepository {
  ImportJobLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: ImportJob.entityTypeName,
          fromPayload: ImportJob.fromPayload,
          toSearchFields: (e) => (name: e.entityType, sku: e.fileName, barcode: e.status.value, storeId: null),
        );

  @override
  Future<List<ImportJob>> listByStatus(String tenantId, ImportJobStatus status) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 200));
    return page.items.where((j) => j.status == status).toList();
  }
}

class ExportJobLocalRepository extends IntegrationsRepositoryImpl<ExportJob> implements ExportJobRepository {
  ExportJobLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: ExportJob.entityTypeName,
          fromPayload: ExportJob.fromPayload,
          toSearchFields: (e) => (name: e.entityType, sku: e.fileName, barcode: e.status.value, storeId: null),
        );

  @override
  Future<List<ExportJob>> listByStatus(String tenantId, ExportJobStatus status) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 200));
    return page.items.where((j) => j.status == status).toList();
  }
}

class OAuthConnectionLocalRepository extends IntegrationsRepositoryImpl<OAuthConnection> implements OAuthConnectionRepository {
  OAuthConnectionLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: OAuthConnection.entityTypeName,
          fromPayload: OAuthConnection.fromPayload,
          toSearchFields: (e) => (name: e.provider, sku: e.accountLabel, barcode: e.status.value, storeId: null),
        );

  @override
  Future<OAuthConnection?> getByProvider(String tenantId, String provider) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 200));
    for (final c in page.items) {
      if (c.provider == provider) return c;
    }
    return null;
  }
}

class PrinterProfileLocalRepository extends IntegrationsRepositoryImpl<PrinterProfile> implements PrinterProfileRepository {
  PrinterProfileLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: PrinterProfile.entityTypeName,
          fromPayload: PrinterProfile.fromPayload,
          toSearchFields: (e) => (name: e.name, sku: e.address, barcode: e.connectionType.value, storeId: null),
        );

  @override
  Future<PrinterProfile?> getDefault(String tenantId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 200));
    for (final p in page.items) {
      if (p.isDefault) return p;
    }
    return page.items.isNotEmpty ? page.items.first : null;
  }
}
