import 'package:fashion_pos_enterprise/core/infrastructure/database/app_database.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/sync_queue_writer.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/entities/inventory_item.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/entities/inventory_transfer.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/entities/stock_adjustment.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/entities/stock_count.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/entities/stock_level.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/entities/stock_movement.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/entities/stock_reservation.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/entities/warehouse.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/repositories/inventory_repositories.dart';
import 'package:fashion_pos_enterprise/features/inventory/data/repositories/inventory_repository_impl.dart';

class InventoryItemRepositoryImpl extends InventoryRepositoryImpl<InventoryItem> implements InventoryItemRepository {
  InventoryItemRepositoryImpl({required AppDatabase database, required SyncQueueWriter syncQueue})
      : _db = database,
        super(
          database: database,
          syncQueue: syncQueue,
          entityType: InventoryItem.entityTypeName,
          fromPayload: InventoryItem.fromPayload,
          toSearchFields: (e) => (name: null, sku: e.sku ?? e.productId, barcode: e.barcode, storeId: null),
        );

  final AppDatabase _db;

  @override
  Future<InventoryItem?> findByBarcode(String tenantId, String barcode) async {
    final record = await _db.syncableRecordDao.getByBarcode(
      tenantId: tenantId,
      barcode: barcode,
      entityType: InventoryItem.entityTypeName,
    );
    return record == null ? null : mapFromLocalRecord(record);
  }
}

class StockLevelRepositoryImpl extends InventoryRepositoryImpl<StockLevel> implements StockLevelRepository {
  StockLevelRepositoryImpl({required AppDatabase database, required SyncQueueWriter syncQueue})
      : _db = database,
        super(
          database: database,
          syncQueue: syncQueue,
          entityType: StockLevel.entityTypeName,
          fromPayload: StockLevel.fromPayload,
          toSearchFields: (e) => (
            name: null,
            sku: e.productId,
            barcode: e.variantId,
            storeId: e.warehouseId,
          ),
        );

  final AppDatabase _db;

  @override
  Future<StockLevel?> findLevel({
    required String tenantId,
    required String warehouseId,
    required String productId,
    String? variantId,
  }) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(
        tenantId: tenantId,
        entityType: StockLevel.entityTypeName,
        storeId: warehouseId,
        pageSize: 500,
      ),
    );
    for (final record in records) {
      final level = mapFromLocalRecord(record);
      if (level.productId == productId && level.variantId == variantId) return level;
    }
    return null;
  }
}

class StockMovementRepositoryImpl extends InventoryRepositoryImpl<StockMovement>
    implements StockMovementRepository {
  StockMovementRepositoryImpl({required AppDatabase database, required SyncQueueWriter syncQueue})
      : _db = database,
        super(
          database: database,
          syncQueue: syncQueue,
          entityType: StockMovement.entityTypeName,
          fromPayload: StockMovement.fromPayload,
          toSearchFields: (e) => (
            name: e.referenceId,
            sku: e.productId,
            barcode: e.variantId,
            storeId: e.warehouseId,
          ),
        );

  final AppDatabase _db;

  @override
  Future<List<StockMovement>> listByWarehouse(String tenantId, String warehouseId, {int limit = 100}) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(
        tenantId: tenantId,
        entityType: StockMovement.entityTypeName,
        storeId: warehouseId,
        pageSize: limit,
        sortBy: 'updated_at',
      ),
    );
    return records.map(mapFromLocalRecord).toList();
  }
}

class StockReservationRepositoryImpl extends InventoryRepositoryImpl<StockReservation>
    implements StockReservationRepository {
  StockReservationRepositoryImpl({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: StockReservation.entityTypeName,
          fromPayload: StockReservation.fromPayload,
          toSearchFields: (e) => (
            name: e.referenceId,
            sku: e.productId,
            barcode: e.variantId,
            storeId: e.warehouseId,
          ),
        );
}

class StockAdjustmentRepositoryImpl extends InventoryRepositoryImpl<StockAdjustment>
    implements StockAdjustmentRepository {
  StockAdjustmentRepositoryImpl({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: StockAdjustment.entityTypeName,
          fromPayload: StockAdjustment.fromPayload,
          toSearchFields: (e) => (name: e.id, sku: null, barcode: null, storeId: e.warehouseId),
        );
}

class InventoryTransferRepositoryImpl extends InventoryRepositoryImpl<InventoryTransfer>
    implements InventoryTransferRepository {
  InventoryTransferRepositoryImpl({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: InventoryTransfer.entityTypeName,
          fromPayload: InventoryTransfer.fromPayload,
          toSearchFields: (e) => (name: e.reference, sku: null, barcode: null, storeId: e.fromWarehouseId),
        );
}

class StockCountRepositoryImpl extends InventoryRepositoryImpl<StockCount> implements StockCountRepository {
  StockCountRepositoryImpl({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: StockCount.entityTypeName,
          fromPayload: StockCount.fromPayload,
          toSearchFields: (e) => (name: e.name, sku: null, barcode: null, storeId: e.warehouseId),
        );
}
