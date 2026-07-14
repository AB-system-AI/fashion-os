import 'package:fashion_pos_enterprise/core/infrastructure/database/app_database.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/base_local_repository.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/sync_queue_writer.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/entities/warehouse.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/repositories/inventory_repositories.dart';

typedef InventoryEntityMapper<T> = T Function(Map<String, dynamic> json, LocalRecord record);

class InventoryRepositoryImpl<T extends SyncableEntity> extends BaseLocalRepository<T> {
  InventoryRepositoryImpl({
    required AppDatabase database,
    required SyncQueueWriter syncQueue,
    required String entityType,
    required this.fromPayload,
    required this.toSearchFields,
  }) : super(database: database, entityType: entityType, syncQueue: syncQueue);

  final InventoryEntityMapper<T> fromPayload;
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

class WarehouseLocationRepositoryImpl extends InventoryRepositoryImpl<WarehouseLocation>
    implements WarehouseLocationRepository {
  WarehouseLocationRepositoryImpl({
    required AppDatabase database,
    required SyncQueueWriter syncQueue,
  })  : _db = database,
        super(
          database: database,
          syncQueue: syncQueue,
          entityType: WarehouseLocation.entityTypeName,
          fromPayload: WarehouseLocation.fromPayload,
          toSearchFields: (e) => (name: e.name, sku: e.code, barcode: null, storeId: e.warehouseId),
        );

  final AppDatabase _db;

  @override
  Future<List<WarehouseLocation>> listByWarehouse(String tenantId, String warehouseId) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(
        tenantId: tenantId,
        entityType: WarehouseLocation.entityTypeName,
        storeId: warehouseId,
        pageSize: 500,
      ),
    );
    return records.map(mapFromLocalRecord).toList();
  }
}

class WarehouseRepositoryImpl extends InventoryRepositoryImpl<Warehouse> implements WarehouseRepository {
  WarehouseRepositoryImpl({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: Warehouse.entityTypeName,
          fromPayload: Warehouse.fromPayload,
          toSearchFields: (e) => (name: e.name, sku: e.code, barcode: null, storeId: e.storeId),
        );
}
