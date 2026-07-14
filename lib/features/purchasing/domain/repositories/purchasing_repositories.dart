import 'package:fashion_pos_enterprise/core/infrastructure/repository/base_local_repository.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/entities/purchase_order.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/entities/purchase_receipt.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/entities/purchase_return.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/entities/supplier.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/entities/supplier_payment.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/enums/purchasing_enums.dart';

abstract class SupplierRepository implements IRepository<Supplier> {
  Future<Supplier?> findByCode(String tenantId, String code);
}

abstract class PurchaseOrderRepository implements IRepository<PurchaseOrder> {
  Future<List<PurchaseOrder>> listBySupplier(String tenantId, String supplierId, {int limit = 100});
  Future<List<PurchaseOrder>> listByStatus(String tenantId, PurchaseOrderStatus status, {int limit = 100});
}

abstract class PurchaseReceiptRepository implements IRepository<PurchaseReceipt> {
  Future<List<PurchaseReceipt>> listByPurchaseOrder(String tenantId, String purchaseOrderId);
}

abstract class PurchaseReturnRepository implements IRepository<PurchaseReturn> {}

abstract class SupplierPaymentRepository implements IRepository<SupplierPayment> {
  Future<List<SupplierPayment>> listBySupplier(String tenantId, String supplierId, {int limit = 200});
}

abstract class SupplierStatementRepository implements IRepository<SupplierStatement> {
  Future<SupplierStatement?> latestForSupplier(String tenantId, String supplierId);
}
