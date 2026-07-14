import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_engine.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/entities/inventory_item.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/entities/stock_level.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/repositories/inventory_repositories.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/services/stock_movement_service.dart';
import 'package:fashion_pos_enterprise/features/products/domain/repositories/product_repositories.dart';

/// Barcode-driven stock actions using existing product/inventory lookup.
class BarcodeStockActionService {
  BarcodeStockActionService({
    required ProductRepository productRepository,
    required InventoryItemRepository inventoryItemRepository,
    required StockLevelRepository stockLevelRepository,
    required StockMovementService movementService,
    required PermissionEngine permissionEngine,
  })  : _products = productRepository,
        _items = inventoryItemRepository,
        _levels = stockLevelRepository,
        _movements = movementService,
        _permissions = permissionEngine;

  final ProductRepository _products;
  final InventoryItemRepository _items;
  final StockLevelRepository _levels;
  final StockMovementService _movements;
  final PermissionEngine _permissions;

  Future<Result<StockLevel>> receiveByBarcode({
    required AuthUser user,
    required String warehouseId,
    required String barcode,
    required double quantity,
  }) => _actionByBarcode(
        user: user,
        warehouseId: warehouseId,
        barcode: barcode,
        quantity: quantity,
        receive: true,
      );

  Future<Result<StockLevel>> issueByBarcode({
    required AuthUser user,
    required String warehouseId,
    required String barcode,
    required double quantity,
  }) => _actionByBarcode(
        user: user,
        warehouseId: warehouseId,
        barcode: barcode,
        quantity: quantity,
        receive: false,
      );

  Future<Result<StockLevel>> _actionByBarcode({
    required AuthUser user,
    required String warehouseId,
    required String barcode,
    required double quantity,
    required bool receive,
  }) async {
    try {
      _permissions.require(user, InventoryPermissions.movement);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    final tenantId = user.tenantId;
    if (tenantId == null) {
      return const Error(ValidationFailure(message: 'No tenant context', code: 'no_tenant'));
    }

    final product = await _products.findByBarcode(tenantId, barcode);
    if (product != null) {
      return receive
          ? _movements.receiveStock(
              user: user,
              warehouseId: warehouseId,
              productId: product.id,
              quantity: quantity,
              notes: 'Barcode $barcode',
            )
          : _movements.issueStock(
              user: user,
              warehouseId: warehouseId,
              productId: product.id,
              quantity: quantity,
              notes: 'Barcode $barcode',
            );
    }

    final item = await _items.findByBarcode(tenantId, barcode);
    if (item == null) {
      return const Error(ValidationFailure(message: 'Barcode not found', code: 'not_found'));
    }

    return receive
        ? _movements.receiveStock(
            user: user,
            warehouseId: warehouseId,
            productId: item.productId,
            variantId: item.variantId,
            quantity: quantity,
            notes: 'Barcode $barcode',
          )
        : _movements.issueStock(
            user: user,
            warehouseId: warehouseId,
            productId: item.productId,
            variantId: item.variantId,
            quantity: quantity,
            notes: 'Barcode $barcode',
          );
  }
}
