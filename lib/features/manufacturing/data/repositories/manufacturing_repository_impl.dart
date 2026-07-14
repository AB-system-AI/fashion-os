import 'package:fashion_pos_enterprise/core/infrastructure/database/app_database.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/pagination/paginated_result.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/base_local_repository.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/sync_queue_writer.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/entities/bom.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/entities/material.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/entities/planning.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/entities/production.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/entities/quality.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/entities/work_center.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/entities/work_order.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/enums/manufacturing_enums.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/repositories/manufacturing_repositories.dart';

typedef ManufacturingEntityMapper<T> = T Function(Map<String, dynamic> json, LocalRecord record);

class ManufacturingRepositoryImpl<T extends SyncableEntity> extends BaseLocalRepository<T> {
  ManufacturingRepositoryImpl({
    required AppDatabase database,
    required SyncQueueWriter syncQueue,
    required String entityType,
    required this.fromPayload,
    required this.toSearchFields,
  }) : super(database: database, entityType: entityType, syncQueue: syncQueue);

  final ManufacturingEntityMapper<T> fromPayload;
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

class ManufacturingLocalRepository extends ManufacturingRepositoryImpl<ManufacturingSettings>
    implements ManufacturingRepository {
  ManufacturingLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : _db = database,
        super(
          database: database,
          syncQueue: syncQueue,
          entityType: ManufacturingSettings.entityTypeName,
          fromPayload: ManufacturingSettings.fromPayload,
          toSearchFields: (e) => (name: e.tenantId, sku: null, barcode: null, storeId: null),
        );

  final AppDatabase _db;

  @override
  Future<ManufacturingSettings?> getSettings(String tenantId) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: ManufacturingSettings.entityTypeName, pageSize: 1),
    );
    return records.isEmpty ? null : mapFromLocalRecord(records.first);
  }

  @override
  Future<ManufacturingSettings> saveSettings(ManufacturingSettings settings) => create(settings);
}

class BomLocalRepository extends ManufacturingRepositoryImpl<BillOfMaterial> implements BomRepository {
  BomLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : _db = database,
        _syncQueue = syncQueue,
        super(
          database: database,
          syncQueue: syncQueue,
          entityType: BillOfMaterial.entityTypeName,
          fromPayload: BillOfMaterial.fromPayload,
          toSearchFields: (e) => (name: e.name, sku: e.code, barcode: null, storeId: null),
        );

  final AppDatabase _db;
  final SyncQueueWriter _syncQueue;

  @override
  Future<BillOfMaterial?> findByCode(String tenantId, String code) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: BillOfMaterial.entityTypeName, search: code, pageSize: 20),
    );
    for (final r in records) {
      final b = mapFromLocalRecord(r);
      if (b.code == code) return b;
    }
    return null;
  }

  @override
  Future<PaginatedResult<BillOfMaterial>> getPage(RepositoryQuery query) => super.getPage(query);

  @override
  Future<BomLine> createLine(BomLine line) => ManufacturingRepositoryImpl<BomLine>(
        database: _db,
        syncQueue: _syncQueue,
        entityType: BomLine.entityTypeName,
        fromPayload: BomLine.fromPayload,
        toSearchFields: (e) => (name: e.bomId, sku: e.componentProductId, barcode: null, storeId: null),
      ).create(line);

  @override
  Future<List<BomLine>> listLines(String tenantId, String bomId) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: BomLine.entityTypeName, pageSize: 500),
    );
    return records.map((r) => BomLine.fromPayload(r.payload, r)).where((l) => l.bomId == bomId).toList();
  }

  @override
  Future<BomVersion> createVersion(BomVersion version) => ManufacturingRepositoryImpl<BomVersion>(
        database: _db,
        syncQueue: _syncQueue,
        entityType: BomVersion.entityTypeName,
        fromPayload: BomVersion.fromPayload,
        toSearchFields: (e) => (name: e.bomId, sku: '${e.versionNumber}', barcode: null, storeId: null),
      ).create(version);
}

class ProductionLocalRepository extends ManufacturingRepositoryImpl<ProductionOrder> implements ProductionRepository {
  ProductionLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : _db = database,
        _syncQueue = syncQueue,
        super(
          database: database,
          syncQueue: syncQueue,
          entityType: ProductionOrder.entityTypeName,
          fromPayload: ProductionOrder.fromPayload,
          toSearchFields: (e) => (name: e.orderNumber, sku: e.productId, barcode: null, storeId: null),
        );

  final AppDatabase _db;
  final SyncQueueWriter _syncQueue;

  ManufacturingRepositoryImpl<T> _repo<T extends SyncableEntity>({
    required String entityType,
    required ManufacturingEntityMapper<T> fromPayload,
    required ({String? name, String? sku, String? barcode, String? storeId}) Function(T) toSearch,
  }) =>
      ManufacturingRepositoryImpl<T>(
        database: _db,
        syncQueue: _syncQueue,
        entityType: entityType,
        fromPayload: fromPayload,
        toSearchFields: toSearch,
      );

  @override
  Future<ProductionOrder?> findByOrderNumber(String tenantId, String orderNumber) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: ProductionOrder.entityTypeName, search: orderNumber, pageSize: 20),
    );
    for (final r in records) {
      final o = mapFromLocalRecord(r);
      if (o.orderNumber == orderNumber) return o;
    }
    return null;
  }

  @override
  Future<List<ProductionOrder>> listByStatus(String tenantId, ProductionStatus status) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: ProductionOrder.entityTypeName, pageSize: 500),
    );
    return records.map(mapFromLocalRecord).where((o) => o.status == status).toList();
  }

  @override
  Future<ProductionOrderLine> createLine(ProductionOrderLine line) => _repo(
        entityType: ProductionOrderLine.entityTypeName,
        fromPayload: ProductionOrderLine.fromPayload,
        toSearch: (e) => (name: e.productionOrderId, sku: e.componentProductId, barcode: null, storeId: null),
      ).create(line);

  @override
  Future<List<ProductionOrderLine>> listLines(String tenantId, String productionOrderId) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: ProductionOrderLine.entityTypeName, pageSize: 500),
    );
    return records
        .map((r) => ProductionOrderLine.fromPayload(r.payload, r))
        .where((l) => l.productionOrderId == productionOrderId)
        .toList();
  }

  @override
  Future<MaterialIssue> createMaterialIssue(MaterialIssue issue) => _repo(
        entityType: MaterialIssue.entityTypeName,
        fromPayload: MaterialIssue.fromPayload,
        toSearch: (e) => (name: e.productionOrderId, sku: e.productId, barcode: null, storeId: e.warehouseId),
      ).create(issue);

  @override
  Future<MaterialReturn> createMaterialReturn(MaterialReturn materialReturn) => _repo(
        entityType: MaterialReturn.entityTypeName,
        fromPayload: MaterialReturn.fromPayload,
        toSearch: (e) => (name: e.productionOrderId, sku: e.productId, barcode: null, storeId: e.warehouseId),
      ).create(materialReturn);

  @override
  Future<ProductionOutput> createOutput(ProductionOutput output) => _repo(
        entityType: ProductionOutput.entityTypeName,
        fromPayload: ProductionOutput.fromPayload,
        toSearch: (e) => (name: e.productionOrderId, sku: e.productId, barcode: null, storeId: e.warehouseId),
      ).create(output);

  @override
  Future<ProductionScrap> createScrap(ProductionScrap scrap) => _repo(
        entityType: ProductionScrap.entityTypeName,
        fromPayload: ProductionScrap.fromPayload,
        toSearch: (e) => (name: e.productionOrderId, sku: e.productId, barcode: null, storeId: null),
      ).create(scrap);

  @override
  Future<FinishedGoodsReceipt> createFinishedGoodsReceipt(FinishedGoodsReceipt receipt) => _repo(
        entityType: FinishedGoodsReceipt.entityTypeName,
        fromPayload: FinishedGoodsReceipt.fromPayload,
        toSearch: (e) => (name: e.productionOrderId, sku: e.productId, barcode: null, storeId: e.warehouseId),
      ).create(receipt);

  @override
  Future<ProductionSchedule> createSchedule(ProductionSchedule schedule) => _repo(
        entityType: ProductionSchedule.entityTypeName,
        fromPayload: ProductionSchedule.fromPayload,
        toSearch: (e) => (name: e.productionOrderId, sku: e.workCenterId, barcode: null, storeId: null),
      ).create(schedule);
}

class WorkOrderLocalRepository extends ManufacturingRepositoryImpl<WorkOrder> implements WorkOrderRepository {
  WorkOrderLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : _db = database,
        _syncQueue = syncQueue,
        super(
          database: database,
          syncQueue: syncQueue,
          entityType: WorkOrder.entityTypeName,
          fromPayload: WorkOrder.fromPayload,
          toSearchFields: (e) => (name: e.workOrderNumber, sku: e.productionOrderId, barcode: null, storeId: null),
        );

  final AppDatabase _db;
  final SyncQueueWriter _syncQueue;

  @override
  Future<List<WorkOrder>> listByProductionOrder(String tenantId, String productionOrderId) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: WorkOrder.entityTypeName, pageSize: 200),
    );
    return records.map(mapFromLocalRecord).where((w) => w.productionOrderId == productionOrderId).toList();
  }

  @override
  Future<WorkCenter> createWorkCenter(WorkCenter center) => ManufacturingRepositoryImpl<WorkCenter>(
        database: _db,
        syncQueue: _syncQueue,
        entityType: WorkCenter.entityTypeName,
        fromPayload: WorkCenter.fromPayload,
        toSearchFields: (e) => (name: e.name, sku: e.code, barcode: null, storeId: null),
      ).create(center);

  @override
  Future<Machine> createMachine(Machine machine) => ManufacturingRepositoryImpl<Machine>(
        database: _db,
        syncQueue: _syncQueue,
        entityType: Machine.entityTypeName,
        fromPayload: Machine.fromPayload,
        toSearchFields: (e) => (name: e.name, sku: e.code, barcode: null, storeId: null),
      ).create(machine);

  @override
  Future<List<WorkCenter>> listWorkCenters(String tenantId) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: WorkCenter.entityTypeName, pageSize: 200),
    );
    return records.map((r) => WorkCenter.fromPayload(r.payload, r)).toList();
  }

  @override
  Future<Operation> createOperation(Operation operation) => ManufacturingRepositoryImpl<Operation>(
        database: _db,
        syncQueue: _syncQueue,
        entityType: Operation.entityTypeName,
        fromPayload: Operation.fromPayload,
        toSearchFields: (e) => (name: e.workOrderId, sku: '${e.sequence}', barcode: null, storeId: null),
      ).create(operation);
}

class QualityLocalRepository extends ManufacturingRepositoryImpl<QualityInspection> implements QualityRepository {
  QualityLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : _db = database,
        _syncQueue = syncQueue,
        super(
          database: database,
          syncQueue: syncQueue,
          entityType: QualityInspection.entityTypeName,
          fromPayload: QualityInspection.fromPayload,
          toSearchFields: (e) => (name: e.productionOrderId, sku: null, barcode: null, storeId: null),
        );

  final AppDatabase _db;
  final SyncQueueWriter _syncQueue;

  @override
  Future<List<QualityInspection>> listByProductionOrder(String tenantId, String productionOrderId) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: QualityInspection.entityTypeName, pageSize: 200),
    );
    return records.map(mapFromLocalRecord).where((q) => q.productionOrderId == productionOrderId).toList();
  }

  @override
  Future<List<QualityInspection>> listAll(String tenantId) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: QualityInspection.entityTypeName, pageSize: 500),
    );
    return records.map(mapFromLocalRecord).toList();
  }

  @override
  Future<MaintenanceRequest> createMaintenance(MaintenanceRequest request) =>
      ManufacturingRepositoryImpl<MaintenanceRequest>(
        database: _db,
        syncQueue: _syncQueue,
        entityType: MaintenanceRequest.entityTypeName,
        fromPayload: MaintenanceRequest.fromPayload,
        toSearchFields: (e) => (name: e.title, sku: e.machineId, barcode: null, storeId: null),
      ).create(request);
}

class CapacityLocalRepository extends ManufacturingRepositoryImpl<CapacityPlan> implements CapacityRepository {
  CapacityLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : _db = database,
        super(
          database: database,
          syncQueue: syncQueue,
          entityType: CapacityPlan.entityTypeName,
          fromPayload: CapacityPlan.fromPayload,
          toSearchFields: (e) => (name: e.workCenterId, sku: null, barcode: null, storeId: null),
        );

  final AppDatabase _db;

  @override
  Future<List<CapacityPlan>> listByWorkCenter(String tenantId, String workCenterId) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: CapacityPlan.entityTypeName, pageSize: 200),
    );
    return records.map(mapFromLocalRecord).where((c) => c.workCenterId == workCenterId).toList();
  }

  @override
  Future<List<CapacityPlan>> listByDateRange(String tenantId, DateTime from, DateTime to) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: CapacityPlan.entityTypeName, pageSize: 500),
    );
    return records
        .map(mapFromLocalRecord)
        .where((c) => !c.planDate.isBefore(from) && !c.planDate.isAfter(to))
        .toList();
  }
}
