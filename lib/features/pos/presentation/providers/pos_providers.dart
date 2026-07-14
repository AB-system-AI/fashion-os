import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_providers.dart';
import 'package:fashion_pos_enterprise/core/business/di/business_providers.dart';
import 'package:fashion_pos_enterprise/core/di/enterprise_providers.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/di/infrastructure_providers.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/hardware/di/hardware_providers.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:fashion_pos_enterprise/features/customers/presentation/providers/customer_providers.dart';
import 'package:fashion_pos_enterprise/features/products/presentation/providers/product_providers.dart';
import 'package:fashion_pos_enterprise/features/pos/data/datasources/pos_remote_datasource.dart';
import 'package:fashion_pos_enterprise/features/pos/data/repositories/pos_repository_impl.dart';
import 'package:fashion_pos_enterprise/features/pos/data/sync/pos_sync_processor.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/entities/coupon.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/entities/exchange_reference.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/entities/layaway_order.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/entities/payment.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/entities/receipt.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/entities/return_reference.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/entities/sale.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/entities/suspended_sale.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/repositories/cash_repository.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/repositories/coupon_repository.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/repositories/receipt_repository.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/repositories/sale_repository.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/services/checkout_service.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/services/pos_service.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/services/pos_support_services.dart';

final posRemoteDataSourceProvider = Provider<PosRemoteDataSource>((ref) => PosRemoteDataSource());

final saleRepositoryProvider = Provider<SaleRepository>((ref) {
  return SaleLocalRepository(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentLocalRepository(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final cashRepositoryProvider = Provider<CashRepository>((ref) {
  return CashLocalRepository(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final receiptRepositoryProvider = Provider<ReceiptRepository>((ref) {
  return ReceiptLocalRepository(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final couponRepositoryProvider = Provider<CouponRepository>((ref) {
  return CouponLocalRepository(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final suspendedSaleRepositoryProvider = Provider<SuspendedSaleRepository>((ref) {
  return SuspendedSaleLocalRepository(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final returnRepositoryProvider = Provider<ReturnRepository>((ref) {
  return ReturnLocalRepository(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final exchangeRepositoryProvider = Provider<ExchangeRepository>((ref) {
  return ExchangeLocalRepository(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final posServiceProvider = Provider<POSService>((ref) {
  return POSService(
    saleRepository: ref.watch(saleRepositoryProvider),
    suspendedSaleRepository: ref.watch(suspendedSaleRepositoryProvider),
    salesEngine: ref.watch(salesEngineProvider),
    productSearch: ref.watch(productSearchServiceProvider),
    auditService: ref.watch(auditServiceProvider),
    permissionEngine: ref.watch(permissionEngineProvider),
  );
});

final checkoutServiceProvider = Provider<CheckoutService>((ref) {
  return CheckoutService(
    saleRepository: ref.watch(saleRepositoryProvider),
    paymentRepository: ref.watch(paymentRepositoryProvider),
    cashRepository: ref.watch(cashRepositoryProvider),
    salesEngine: ref.watch(salesEngineProvider),
    stockMovementService: ref.watch(stockMovementServiceProvider),
    auditService: ref.watch(auditServiceProvider),
    permissionEngine: ref.watch(permissionEngineProvider),
    numberGenerator: ref.watch(numberGeneratorEngineProvider),
  );
});

final cashDrawerServiceProvider = Provider<CashDrawerService>((ref) {
  return CashDrawerService(
    cashRepository: ref.watch(cashRepositoryProvider),
    cashSessionEngine: ref.watch(cashSessionEngineProvider),
    salesEngine: ref.watch(salesEngineProvider),
    auditService: ref.watch(auditServiceProvider),
    permissionEngine: ref.watch(permissionEngineProvider),
    numberGenerator: ref.watch(numberGeneratorEngineProvider),
  );
});

final receiptServiceProvider = Provider<ReceiptService>((ref) {
  return ReceiptService(
    repository: ref.watch(receiptRepositoryProvider),
    receiptEngine: ref.watch(receiptEngineProvider),
    printerHub: ref.watch(printerHubProvider),
    auditService: ref.watch(auditServiceProvider),
    permissionEngine: ref.watch(permissionEngineProvider),
    numberGenerator: ref.watch(numberGeneratorEngineProvider),
  );
});

final couponServiceProvider = Provider<CouponService>((ref) {
  return CouponService(
    repository: ref.watch(couponRepositoryProvider),
    salesEngine: ref.watch(salesEngineProvider),
    auditService: ref.watch(auditServiceProvider),
    permissionEngine: ref.watch(permissionEngineProvider),
  );
});

final splitPaymentServiceProvider = Provider<SplitPaymentService>((ref) {
  return SplitPaymentService(salesEngine: ref.watch(salesEngineProvider));
});

final barcodeSaleServiceProvider = Provider<BarcodeSaleService>((ref) {
  return BarcodeSaleService(
    search: ref.watch(productSearchServiceProvider),
    salesEngine: ref.watch(salesEngineProvider),
  );
});

final quickSaleServiceProvider = Provider<QuickSaleService>((ref) {
  return QuickSaleService(salesEngine: ref.watch(salesEngineProvider));
});

final posCustomerLookupServiceProvider = Provider<PosCustomerLookupService>((ref) {
  return PosCustomerLookupService(customerLookup: ref.watch(customerLookupServiceProvider));
});

final returnValidationServiceProvider = Provider<ReturnValidationService>((ref) {
  return ReturnValidationService(
    salesEngine: ref.watch(salesEngineProvider),
    saleRepository: ref.watch(saleRepositoryProvider),
  );
});

final exchangeValidationServiceProvider = Provider<ExchangeValidationService>((ref) {
  return ExchangeValidationService(salesEngine: ref.watch(salesEngineProvider));
});

final layawayServiceProvider = Provider<LayawayService>((ref) {
  return LayawayService(
    salesEngine: ref.watch(salesEngineProvider),
    auditService: ref.watch(auditServiceProvider),
    permissionEngine: ref.watch(permissionEngineProvider),
    numberGenerator: ref.watch(numberGeneratorEngineProvider),
  );
});

final promotionApplicationServiceProvider = Provider<PromotionApplicationService>((ref) {
  return PromotionApplicationService(salesEngine: ref.watch(salesEngineProvider));
});

final giftReceiptServiceProvider = Provider<GiftReceiptService>((ref) {
  return GiftReceiptService(
    auditService: ref.watch(auditServiceProvider),
    permissionEngine: ref.watch(permissionEngineProvider),
    numberGenerator: ref.watch(numberGeneratorEngineProvider),
  );
});

PosSyncProcessor _processor(Ref ref, String entityType, String table) => PosSyncProcessor(
      remote: ref.watch(posRemoteDataSourceProvider),
      entityTypeName: entityType,
      remoteTable: table,
    );

final salesSyncProcessorProvider = Provider<SalesSyncProcessor>(
  (ref) => _processor(ref, Sale.entityTypeName, 'sale_orders'),
);

final cashSessionSyncProcessorProvider = Provider<CashSessionSyncProcessor>(
  (ref) => _processor(ref, 'cash_session', 'cash_sessions'),
);

final receiptSyncProcessorProvider = Provider<ReceiptSyncProcessor>(
  (ref) => _processor(ref, Receipt.entityTypeName, 'receipt_history'),
);

final returnSyncProcessorProvider = Provider<ReturnSyncProcessor>(
  (ref) => _processor(ref, ReturnReference.entityTypeName, 'sale_returns'),
);

final exchangeSyncProcessorProvider = Provider<ExchangeSyncProcessor>(
  (ref) => _processor(ref, ExchangeReference.entityTypeName, 'exchanges'),
);

final layawaySyncProcessorProvider = Provider<LayawaySyncProcessor>(
  (ref) => _processor(ref, LayawayOrder.entityTypeName, 'layaway_orders'),
);

final paymentSyncProcessorProvider = Provider<PosSyncProcessor>(
  (ref) => _processor(ref, Payment.entityTypeName, 'sale_payments'),
);

final couponSyncProcessorProvider = Provider<PosSyncProcessor>(
  (ref) => _processor(ref, Coupon.entityTypeName, 'coupons'),
);

final suspendedSaleSyncProcessorProvider = Provider<PosSyncProcessor>(
  (ref) => _processor(ref, SuspendedSale.entityTypeName, 'sale_orders'),
);
