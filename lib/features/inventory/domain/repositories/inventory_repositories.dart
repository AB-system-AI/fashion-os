import 'package:fashion_pos_enterprise/core/infrastructure/repository/base_local_repository.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/entities/inventory_item.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/entities/inventory_transfer.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/entities/stock_adjustment.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/entities/stock_count.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/entities/stock_level.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/entities/stock_movement.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/entities/stock_reservation.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/entities/warehouse.dart';

abstract class WarehouseRepository implements IRepository<Warehouse> {}

abstract class WarehouseLocationRepository implements IRepository<WarehouseLocation> {
  Future<List<WarehouseLocation>> listByWarehouse(String tenantId, String warehouseId);
}

abstract class InventoryItemRepository implements IRepository<InventoryItem> {
  Future<InventoryItem?> findByBarcode(String tenantId, String barcode);
}

abstract class StockLevelRepository implements IRepository<StockLevel> {
  Future<StockLevel?> findLevel({
    required String tenantId,
    required String warehouseId,
    required String productId,
    String? variantId,
  });
}

abstract class StockMovementRepository implements IRepository<StockMovement> {
  Future<List<StockMovement>> listByWarehouse(String tenantId, String warehouseId, {int limit = 100});
}

abstract class StockReservationRepository implements IRepository<StockReservation> {}

abstract class StockAdjustmentRepository implements IRepository<StockAdjustment> {}

abstract class InventoryTransferRepository implements IRepository<InventoryTransfer> {}

abstract class StockCountRepository implements IRepository<StockCount> {}
