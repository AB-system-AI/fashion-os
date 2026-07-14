import 'package:fashion_pos_enterprise/core/infrastructure/database/app_database.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/pagination/paginated_result.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/base_local_repository.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/sync_queue_writer.dart';
import 'package:fashion_pos_enterprise/features/analytics/domain/entities/dashboard.dart';
import 'package:fashion_pos_enterprise/features/analytics/domain/entities/report.dart';
import 'package:fashion_pos_enterprise/features/analytics/domain/enums/analytics_enums.dart';
import 'package:fashion_pos_enterprise/features/analytics/domain/repositories/analytics_repositories.dart';

typedef AnalyticsEntityMapper<T> = T Function(Map<String, dynamic> json, LocalRecord record);

class AnalyticsRepositoryImpl<T extends SyncableEntity> extends BaseLocalRepository<T> {
  AnalyticsRepositoryImpl({
    required AppDatabase database,
    required SyncQueueWriter syncQueue,
    required String entityType,
    required this.fromPayload,
    required this.toSearchFields,
  }) : super(database: database, entityType: entityType, syncQueue: syncQueue);

  final AnalyticsEntityMapper<T> fromPayload;
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

class ReportLocalRepository extends AnalyticsRepositoryImpl<ReportDefinition> implements ReportRepository {
  ReportLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : _db = database,
        _syncQueue = syncQueue,
        super(
          database: database,
          syncQueue: syncQueue,
          entityType: ReportDefinition.entityTypeName,
          fromPayload: ReportDefinition.fromPayload,
          toSearchFields: (e) => (name: e.name, sku: e.module, barcode: null, storeId: null),
        );

  final AppDatabase _db;
  final SyncQueueWriter _syncQueue;

  AnalyticsRepositoryImpl<R> _repo<R extends SyncableEntity>({
    required String entityType,
    required AnalyticsEntityMapper<R> fromPayload,
    required ({String? name, String? sku, String? barcode, String? storeId}) Function(R) toSearch,
  }) =>
      AnalyticsRepositoryImpl<R>(
        database: _db,
        syncQueue: _syncQueue,
        entityType: entityType,
        fromPayload: fromPayload,
        toSearchFields: toSearch,
      );

  @override
  Future<PaginatedResult<ReportDefinition>> listByModule(String tenantId, String module) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 200));
    return PaginatedResult(
      items: page.items.where((r) => r.module == module).toList(),
      page: page.page,
      pageSize: page.pageSize,
      totalCount: page.totalCount,
      hasMore: page.hasMore,
    );
  }

  @override
  Future<ReportTemplate> createTemplate(ReportTemplate template) => _repo(
        entityType: ReportTemplate.entityTypeName,
        fromPayload: ReportTemplate.fromPayload,
        toSearch: (e) => (name: e.name, sku: e.module, barcode: null, storeId: null),
      ).create(template);

  @override
  Future<List<ReportTemplate>> listTemplates(String tenantId) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: ReportTemplate.entityTypeName, pageSize: 200),
    );
    return records.map((r) => ReportTemplate.fromPayload(r.payload, r)).toList();
  }

  @override
  Future<ReportExport> createExport(ReportExport export) => _repo(
        entityType: ReportExport.entityTypeName,
        fromPayload: ReportExport.fromPayload,
        toSearch: (e) => (name: e.fileName, sku: e.reportId, barcode: null, storeId: null),
      ).create(export);

  @override
  Future<ReportSnapshot> createSnapshot(ReportSnapshot snapshot) => _repo(
        entityType: ReportSnapshot.entityTypeName,
        fromPayload: ReportSnapshot.fromPayload,
        toSearch: (e) => (name: e.reportId, sku: null, barcode: null, storeId: null),
      ).create(snapshot);
}

class DashboardLocalRepository extends AnalyticsRepositoryImpl<DashboardLayout> implements DashboardRepository {
  DashboardLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : _db = database,
        _syncQueue = syncQueue,
        super(
          database: database,
          syncQueue: syncQueue,
          entityType: DashboardLayout.entityTypeName,
          fromPayload: DashboardLayout.fromPayload,
          toSearchFields: (e) => (name: e.name, sku: e.dashboardType.value, barcode: null, storeId: e.storeId),
        );

  final AppDatabase _db;
  final SyncQueueWriter _syncQueue;

  @override
  Future<List<DashboardLayout>> listByType(String tenantId, DashboardType type) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: DashboardLayout.entityTypeName, pageSize: 100),
    );
    return records
        .map((r) => DashboardLayout.fromPayload(r.payload, r))
        .where((l) => l.dashboardType == type)
        .toList();
  }

  @override
  Future<DashboardWidget> createWidget(DashboardWidget widget) => AnalyticsRepositoryImpl<DashboardWidget>(
        database: _db,
        syncQueue: _syncQueue,
        entityType: DashboardWidget.entityTypeName,
        fromPayload: DashboardWidget.fromPayload,
        toSearchFields: (e) => (name: e.title, sku: e.layoutId, barcode: null, storeId: null),
      ).create(widget);

  @override
  Future<List<DashboardWidget>> listWidgets(String tenantId, String layoutId) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: DashboardWidget.entityTypeName, pageSize: 200),
    );
    return records
        .map((r) => DashboardWidget.fromPayload(r.payload, r))
        .where((w) => w.layoutId == layoutId)
        .toList()
      ..sort((a, b) => a.position.compareTo(b.position));
  }
}

class AnalyticsSnapshotLocalRepository extends AnalyticsRepositoryImpl<AnalyticsSnapshot>
    implements AnalyticsSnapshotRepository {
  AnalyticsSnapshotLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : _db = database,
        super(
          database: database,
          syncQueue: syncQueue,
          entityType: AnalyticsSnapshot.entityTypeName,
          fromPayload: AnalyticsSnapshot.fromPayload,
          toSearchFields: (e) => (name: e.snapshotType, sku: null, barcode: null, storeId: e.storeId),
        );

  final AppDatabase _db;

  @override
  Future<AnalyticsSnapshot?> latest(String tenantId, String snapshotType) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: AnalyticsSnapshot.entityTypeName, pageSize: 50, sortBy: 'updated_at'),
    );
    for (final r in records) {
      final s = mapFromLocalRecord(r);
      if (s.snapshotType == snapshotType) return s;
    }
    return null;
  }
}

class KpiSnapshotLocalRepository extends AnalyticsRepositoryImpl<KpiSnapshot> implements KpiSnapshotRepository {
  KpiSnapshotLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : _db = database,
        super(
          database: database,
          syncQueue: syncQueue,
          entityType: KpiSnapshot.entityTypeName,
          fromPayload: KpiSnapshot.fromPayload,
          toSearchFields: (e) => (name: e.kpiCode, sku: e.category.value, barcode: null, storeId: null),
        );

  final AppDatabase _db;

  @override
  Future<List<KpiSnapshot>> listByCategory(String tenantId, KpiCategory category) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: KpiSnapshot.entityTypeName, pageSize: 500),
    );
    return records.map(mapFromLocalRecord).where((k) => k.category == category).toList();
  }
}

class ScheduledReportLocalRepository extends AnalyticsRepositoryImpl<ScheduledReport>
    implements ScheduledReportRepository {
  ScheduledReportLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : _db = database,
        _syncQueue = syncQueue,
        super(
          database: database,
          syncQueue: syncQueue,
          entityType: ScheduledReport.entityTypeName,
          fromPayload: ScheduledReport.fromPayload,
          toSearchFields: (e) => (name: e.reportId, sku: e.frequency.value, barcode: null, storeId: null),
        );

  final AppDatabase _db;
  final SyncQueueWriter _syncQueue;

  @override
  Future<List<ScheduledReport>> listActive(String tenantId) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: ScheduledReport.entityTypeName, pageSize: 200),
    );
    return records.map(mapFromLocalRecord).where((s) => s.isActive).toList();
  }

  @override
  Future<ReportExecutionHistory> createExecution(ReportExecutionHistory history) =>
      AnalyticsRepositoryImpl<ReportExecutionHistory>(
        database: _db,
        syncQueue: _syncQueue,
        entityType: ReportExecutionHistory.entityTypeName,
        fromPayload: ReportExecutionHistory.fromPayload,
        toSearchFields: (e) => (name: e.scheduledReportId, sku: e.status.value, barcode: null, storeId: null),
      ).create(history);

  @override
  Future<List<ReportExecutionHistory>> listExecutions(String tenantId, String scheduledReportId) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: ReportExecutionHistory.entityTypeName, pageSize: 100),
    );
    return records
        .map((r) => ReportExecutionHistory.fromPayload(r.payload, r))
        .where((h) => h.scheduledReportId == scheduledReportId)
        .toList();
  }
}
