import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_providers.dart';
import 'package:fashion_pos_enterprise/core/business/di/business_providers.dart';
import 'package:fashion_pos_enterprise/core/di/enterprise_providers.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/features/inventory/data/datasources/inventory_remote_datasource.dart';
import 'package:fashion_pos_enterprise/features/inventory/data/repositories/stock_repository_impl.dart';
import 'package:fashion_pos_enterprise/features/inventory/data/sync/inventory_sync_processor.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/repositories/inventory_repositories.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/entities/inventory_transfer.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/entities/stock_count.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/entities/stock_level.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/entities/stock_movement.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/entities/warehouse.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/repositories/inventory_repositories.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/services/barcode_stock_action_service.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/services/inventory_transfer_service.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/services/stock_count_service.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/services/stock_movement_service.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/services/warehouse_service.dart';
import 'package:fashion_pos_enterprise/features/products/presentation/providers/product_providers.dart';

final inventoryRemoteDataSourceProvider = Provider<InventoryRemoteDataSource>((ref) => InventoryRemoteDataSource());

final warehouseRepositoryProvider = Provider<WarehouseRepository>((ref) {
  return WarehouseRepositoryImpl(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final inventoryItemRepositoryProvider = Provider<InventoryItemRepository>((ref) {
  return InventoryItemRepositoryImpl(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final stockLevelRepositoryProvider = Provider<StockLevelRepository>((ref) {
  return StockLevelRepositoryImpl(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final stockMovementRepositoryProvider = Provider<StockMovementRepository>((ref) {
  return StockMovementRepositoryImpl(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final inventoryTransferRepositoryProvider = Provider<InventoryTransferRepository>((ref) {
  return InventoryTransferRepositoryImpl(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final stockCountRepositoryProvider = Provider<StockCountRepository>((ref) {
  return StockCountRepositoryImpl(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final stockReservationRepositoryProvider = Provider<StockReservationRepository>((ref) {
  return StockReservationRepositoryImpl(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final warehouseServiceProvider = Provider<WarehouseService>((ref) {
  return WarehouseService(
    repository: ref.watch(warehouseRepositoryProvider),
    auditService: ref.watch(auditServiceProvider),
    permissionEngine: ref.watch(permissionEngineProvider),
  );
});

final stockMovementServiceProvider = Provider<StockMovementService>((ref) {
  return StockMovementService(
    stockLevelRepository: ref.watch(stockLevelRepositoryProvider),
    movementRepository: ref.watch(stockMovementRepositoryProvider),
    inventoryEngine: ref.watch(inventoryEngineProvider),
    auditService: ref.watch(auditServiceProvider),
    permissionEngine: ref.watch(permissionEngineProvider),
  );
});

final inventoryTransferServiceProvider = Provider<InventoryTransferService>((ref) {
  return InventoryTransferService(
    transferRepository: ref.watch(inventoryTransferRepositoryProvider),
    stockLevelRepository: ref.watch(stockLevelRepositoryProvider),
    inventoryEngine: ref.watch(inventoryEngineProvider),
    movementService: ref.watch(stockMovementServiceProvider),
    auditService: ref.watch(auditServiceProvider),
    permissionEngine: ref.watch(permissionEngineProvider),
  );
});

final stockAdjustmentRepositoryProvider = Provider<StockAdjustmentRepository>((ref) {
  return StockAdjustmentRepositoryImpl(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final stockCountServiceProvider = Provider<StockCountService>((ref) {
  return StockCountService(
    countRepository: ref.watch(stockCountRepositoryProvider),
    stockLevelRepository: ref.watch(stockLevelRepositoryProvider),
    adjustmentRepository: ref.watch(stockAdjustmentRepositoryProvider),
    movementService: ref.watch(stockMovementServiceProvider),
    auditService: ref.watch(auditServiceProvider),
    permissionEngine: ref.watch(permissionEngineProvider),
  );
});

final barcodeStockActionServiceProvider = Provider<BarcodeStockActionService>((ref) {
  return BarcodeStockActionService(
    productRepository: ref.watch(productRepositoryProvider),
    inventoryItemRepository: ref.watch(inventoryItemRepositoryProvider),
    stockLevelRepository: ref.watch(stockLevelRepositoryProvider),
    movementService: ref.watch(stockMovementServiceProvider),
    permissionEngine: ref.watch(permissionEngineProvider),
  );
});

InventorySyncProcessor _processor(Ref ref, String entityType, String table) {
  return InventorySyncProcessor(
    remote: ref.watch(inventoryRemoteDataSourceProvider),
    entityTypeName: entityType,
    remoteTable: table,
  );
}

final warehouseSyncProcessorProvider = Provider((ref) => _processor(ref, Warehouse.entityTypeName, 'warehouses'));
final inventoryItemSyncProcessorProvider =
    Provider((ref) => _processor(ref, InventoryItem.entityTypeName, 'inventory_items'));
final stockLevelSyncProcessorProvider = Provider((ref) => _processor(ref, StockLevel.entityTypeName, 'stock_levels'));
final stockMovementSyncProcessorProvider =
    Provider((ref) => _processor(ref, StockMovement.entityTypeName, 'inventory_movements'));
final inventoryTransferSyncProcessorProvider =
    Provider((ref) => _processor(ref, InventoryTransfer.entityTypeName, 'inventory_transfers'));
final stockCountSyncProcessorProvider = Provider((ref) => _processor(ref, StockCount.entityTypeName, 'stock_counts'));
