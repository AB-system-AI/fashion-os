import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_engine.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/products/domain/repositories/product_repositories.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/entities/purchase_order.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/entities/purchase_receipt.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/services/purchase_receipt_service.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/repositories/purchasing_repositories.dart';

class BarcodeReceivingResult {
  const BarcodeReceivingResult({
    required this.receipt,
    required this.lineId,
    required this.quantityReceived,
  });

  final PurchaseReceipt receipt;
  final String lineId;
  final double quantityReceived;
}

/// Barcode-driven PO receiving using existing product lookup.
class BarcodeReceivingService {
  BarcodeReceivingService({
    required ProductRepository productRepository,
    required PurchaseOrderRepository purchaseOrderRepository,
    required PurchaseReceiptService receiptService,
    required PermissionEngine permissionEngine,
  })  : _products = productRepository,
        _orders = purchaseOrderRepository,
        _receipts = receiptService,
        _permissions = permissionEngine;

  final ProductRepository _products;
  final PurchaseOrderRepository _orders;
  final PurchaseReceiptService _receipts;
  final PermissionEngine _permissions;

  Future<Result<BarcodeReceivingResult>> receiveByBarcode({
    required AuthUser user,
    required String purchaseOrderId,
    required String barcode,
    required double quantity,
  }) async {
    try {
      _permissions.require(user, PurchasePermissions.receive);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    final tenantId = user.tenantId;
    if (tenantId == null) {
      return const Error(ValidationFailure(message: 'No tenant context', code: 'no_tenant'));
    }

    final order = await _orders.getById(purchaseOrderId, tenantId: tenantId);
    if (order == null) {
      return const Error(ValidationFailure(message: 'Purchase order not found', code: 'not_found'));
    }

    final product = await _products.findByBarcode(tenantId, barcode);
    if (product == null) {
      return const Error(ValidationFailure(message: 'Product not found for barcode', code: 'not_found'));
    }

    PurchaseOrderLine? matchedLine;
    for (final line in order.lines) {
      if (line.productId == product.id) {
        matchedLine = line;
        break;
      }
      if (line.variantId.isNotEmpty && product.variants.any((v) => v.id == line.variantId)) {
        matchedLine = line;
        break;
      }
    }

    if (matchedLine == null) {
      return const Error(ValidationFailure(message: 'Barcode not on purchase order', code: 'po_line_not_found'));
    }

    final receiptResult = await _receipts.receive(
      user: user,
      purchaseOrderId: purchaseOrderId,
      quantitiesByLineId: {matchedLine.id: quantity},
    );

    if (receiptResult.isFailure) return Error(receiptResult.failureOrNull!);

    return Success(
      BarcodeReceivingResult(
        receipt: receiptResult.dataOrNull!,
        lineId: matchedLine.id,
        quantityReceived: quantity,
      ),
    );
  }
}
