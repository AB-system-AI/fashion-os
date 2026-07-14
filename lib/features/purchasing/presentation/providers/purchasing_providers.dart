import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_providers.dart';
import 'package:fashion_pos_enterprise/core/business/di/business_providers.dart';
import 'package:fashion_pos_enterprise/core/di/enterprise_providers.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:fashion_pos_enterprise/features/products/presentation/providers/product_providers.dart';
import 'package:fashion_pos_enterprise/features/purchasing/data/datasources/purchasing_remote_datasource.dart';
import 'package:fashion_pos_enterprise/features/purchasing/data/repositories/purchasing_repository_impl.dart';
import 'package:fashion_pos_enterprise/features/purchasing/data/sync/purchase_sync_processor.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/entities/purchase_order.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/entities/purchase_receipt.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/entities/purchase_return.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/entities/supplier.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/entities/supplier_payment.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/repositories/purchasing_repositories.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/services/barcode_receiving_service.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/services/purchase_order_service.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/services/purchase_receipt_service.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/services/purchase_return_service.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/services/purchasing_report_service.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/services/supplier_financial_service.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/services/supplier_service.dart';

final purchasingRemoteDataSourceProvider = Provider<PurchasingRemoteDataSource>((ref) => PurchasingRemoteDataSource());

final supplierRepositoryProvider = Provider<SupplierRepository>((ref) {
  return SupplierRepositoryImpl(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final purchaseOrderRepositoryProvider = Provider<PurchaseOrderRepository>((ref) {
  return PurchaseOrderRepositoryImpl(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final purchaseReceiptRepositoryProvider = Provider<PurchaseReceiptRepository>((ref) {
  return PurchaseReceiptRepositoryImpl(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final purchaseReturnRepositoryProvider = Provider<PurchaseReturnRepository>((ref) {
  return PurchaseReturnRepositoryImpl(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final supplierPaymentRepositoryProvider = Provider<SupplierPaymentRepository>((ref) {
  return SupplierPaymentRepositoryImpl(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final supplierStatementRepositoryProvider = Provider<SupplierStatementRepository>((ref) {
  return SupplierStatementRepositoryImpl(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final supplierServiceProvider = Provider<SupplierService>((ref) {
  return SupplierService(
    repository: ref.watch(supplierRepositoryProvider),
    purchaseOrderRepository: ref.watch(purchaseOrderRepositoryProvider),
    auditService: ref.watch(auditServiceProvider),
    permissionEngine: ref.watch(permissionEngineProvider),
    numberGenerator: ref.watch(numberGeneratorEngineProvider),
  );
});

final purchaseOrderServiceProvider = Provider<PurchaseOrderService>((ref) {
  return PurchaseOrderService(
    repository: ref.watch(purchaseOrderRepositoryProvider),
    purchaseEngine: ref.watch(purchaseEngineProvider),
    auditService: ref.watch(auditServiceProvider),
    permissionEngine: ref.watch(permissionEngineProvider),
    numberGenerator: ref.watch(numberGeneratorEngineProvider),
  );
});

final purchaseReceiptServiceProvider = Provider<PurchaseReceiptService>((ref) {
  return PurchaseReceiptService(
    purchaseOrderRepository: ref.watch(purchaseOrderRepositoryProvider),
    receiptRepository: ref.watch(purchaseReceiptRepositoryProvider),
    supplierRepository: ref.watch(supplierRepositoryProvider),
    purchaseEngine: ref.watch(purchaseEngineProvider),
    stockMovementService: ref.watch(stockMovementServiceProvider),
    auditService: ref.watch(auditServiceProvider),
    permissionEngine: ref.watch(permissionEngineProvider),
    numberGenerator: ref.watch(numberGeneratorEngineProvider),
    eventBus: ref.watch(domainEventBusProvider),
  );
});

final purchaseReturnServiceProvider = Provider<PurchaseReturnService>((ref) {
  return PurchaseReturnService(
    returnRepository: ref.watch(purchaseReturnRepositoryProvider),
    supplierRepository: ref.watch(supplierRepositoryProvider),
    stockMovementService: ref.watch(stockMovementServiceProvider),
    auditService: ref.watch(auditServiceProvider),
    permissionEngine: ref.watch(permissionEngineProvider),
    numberGenerator: ref.watch(numberGeneratorEngineProvider),
  );
});

final supplierFinancialServiceProvider = Provider<SupplierFinancialService>((ref) {
  return SupplierFinancialService(
    supplierRepository: ref.watch(supplierRepositoryProvider),
    paymentRepository: ref.watch(supplierPaymentRepositoryProvider),
    statementRepository: ref.watch(supplierStatementRepositoryProvider),
    purchaseOrderRepository: ref.watch(purchaseOrderRepositoryProvider),
    auditService: ref.watch(auditServiceProvider),
    permissionEngine: ref.watch(permissionEngineProvider),
  );
});

final barcodeReceivingServiceProvider = Provider<BarcodeReceivingService>((ref) {
  return BarcodeReceivingService(
    productRepository: ref.watch(productRepositoryProvider),
    purchaseOrderRepository: ref.watch(purchaseOrderRepositoryProvider),
    receiptService: ref.watch(purchaseReceiptServiceProvider),
    permissionEngine: ref.watch(permissionEngineProvider),
  );
});

final purchasingReportServiceProvider = Provider<PurchasingReportService>((ref) {
  return PurchasingReportService(
    supplierRepository: ref.watch(supplierRepositoryProvider),
    purchaseOrderRepository: ref.watch(purchaseOrderRepositoryProvider),
    purchaseReceiptRepository: ref.watch(purchaseReceiptRepositoryProvider),
    purchaseEngine: ref.watch(purchaseEngineProvider),
  );
});

PurchaseSyncProcessor _processor(Ref ref, String entityType, String table) {
  return PurchaseSyncProcessor(
    remote: ref.watch(purchasingRemoteDataSourceProvider),
    entityTypeName: entityType,
    remoteTable: table,
  );
}

final supplierSyncProcessorProvider = Provider((ref) => _processor(ref, Supplier.entityTypeName, 'suppliers'));
final purchaseOrderSyncProcessorProvider =
    Provider((ref) => _processor(ref, PurchaseOrder.entityTypeName, 'purchase_orders'));
final purchaseReceiptSyncProcessorProvider =
    Provider((ref) => _processor(ref, PurchaseReceipt.entityTypeName, 'purchase_receipts'));
final purchaseReturnSyncProcessorProvider =
    Provider((ref) => _processor(ref, PurchaseReturn.entityTypeName, 'purchase_returns'));
final supplierPaymentSyncProcessorProvider =
    Provider((ref) => _processor(ref, SupplierPayment.entityTypeName, 'supplier_payments'));
final supplierStatementSyncProcessorProvider =
    Provider((ref) => _processor(ref, SupplierStatement.entityTypeName, 'supplier_statements'));
