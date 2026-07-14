import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_providers.dart';
import 'package:fashion_pos_enterprise/core/business/di/business_providers.dart';
import 'package:fashion_pos_enterprise/core/di/enterprise_providers.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/features/customers/presentation/providers/customer_providers.dart';
import 'package:fashion_pos_enterprise/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/presentation/providers/manufacturing_providers.dart';
import 'package:fashion_pos_enterprise/features/sales/data/datasources/sales_remote_datasource.dart';
import 'package:fashion_pos_enterprise/features/sales/data/repositories/sales_repository_impl.dart';
import 'package:fashion_pos_enterprise/features/sales/data/sync/sales_sync_processor.dart';
import 'package:fashion_pos_enterprise/features/sales/domain/entities/delivery.dart';
import 'package:fashion_pos_enterprise/features/sales/domain/entities/order.dart';
import 'package:fashion_pos_enterprise/features/sales/domain/entities/quotation.dart';
import 'package:fashion_pos_enterprise/features/sales/domain/entities/returns.dart';
import 'package:fashion_pos_enterprise/features/sales/domain/entities/shipment.dart';
import 'package:fashion_pos_enterprise/features/sales/domain/entities/timeline.dart';
import 'package:fashion_pos_enterprise/features/sales/domain/repositories/sales_repositories.dart';
import 'package:fashion_pos_enterprise/features/sales/domain/services/sales_integration_service.dart';
import 'package:fashion_pos_enterprise/features/sales/domain/services/sales_services.dart';

final salesRemoteDataSourceProvider = Provider<SalesRemoteDataSource>((ref) => SalesRemoteDataSource());

final quotationRepositoryProvider = Provider<QuotationRepository>((ref) {
  return QuotationLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final salesOrderRepositoryProvider = Provider<SalesOrderRepository>((ref) {
  return SalesOrderLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final salesReservationRepositoryProvider = Provider<SalesReservationRepository>((ref) {
  return SalesReservationLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final shipmentRepositoryProvider = Provider<ShipmentRepository>((ref) {
  return ShipmentLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final deliveryRepositoryProvider = Provider<DeliveryRepository>((ref) {
  return DeliveryLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final returnRepositoryProvider = Provider<ReturnRepository>((ref) {
  return ReturnLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final exchangeRepositoryProvider = Provider<ExchangeRepository>((ref) {
  return ExchangeLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final customerTimelineRepositoryProvider = Provider<CustomerTimelineRepository>((ref) {
  return CustomerTimelineLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final salesSettingsRepositoryProvider = Provider<SalesSettingsRepository>((ref) {
  return SalesSettingsLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final customerTimelineServiceProvider = Provider<CustomerTimelineService>((ref) => CustomerTimelineService(repository: ref.watch(customerTimelineRepositoryProvider)));

final quotationServiceProvider = Provider<QuotationService>((ref) => QuotationService(
      repository: ref.watch(quotationRepositoryProvider),
      engine: ref.watch(salesOrderEngineProvider),
      audit: ref.watch(auditServiceProvider),
      permissions: ref.watch(permissionEngineProvider),
      numberGenerator: ref.watch(numberGeneratorEngineProvider),
      timeline: ref.watch(customerTimelineServiceProvider),
    ));

final reservationServiceProvider = Provider<ReservationService>((ref) => ReservationService(
      repository: ref.watch(salesReservationRepositoryProvider),
      orders: ref.watch(salesOrderRepositoryProvider),
      stockLevels: ref.watch(stockLevelRepositoryProvider),
      stockReservations: ref.watch(stockReservationRepositoryProvider),
      inventoryEngine: ref.watch(inventoryEngineProvider),
      engine: ref.watch(salesOrderEngineProvider),
      audit: ref.watch(auditServiceProvider),
      permissions: ref.watch(permissionEngineProvider),
      timeline: ref.watch(customerTimelineServiceProvider),
    ));

final salesOrderServiceProvider = Provider<SalesOrderService>((ref) => SalesOrderService(
      repository: ref.watch(salesOrderRepositoryProvider),
      quotations: ref.watch(quotationRepositoryProvider),
      engine: ref.watch(salesOrderEngineProvider),
      audit: ref.watch(auditServiceProvider),
      permissions: ref.watch(permissionEngineProvider),
      numberGenerator: ref.watch(numberGeneratorEngineProvider),
      customers: ref.watch(customerRepositoryProvider),
      reservations: ref.watch(reservationServiceProvider),
      timeline: ref.watch(customerTimelineServiceProvider),
      productionOrders: ref.watch(productionOrderServiceProvider),
    ));

final shipmentServiceProvider = Provider<ShipmentService>((ref) => ShipmentService(
      repository: ref.watch(shipmentRepositoryProvider),
      orders: ref.watch(salesOrderRepositoryProvider),
      engine: ref.watch(salesOrderEngineProvider),
      audit: ref.watch(auditServiceProvider),
      permissions: ref.watch(permissionEngineProvider),
      numberGenerator: ref.watch(numberGeneratorEngineProvider),
      stockMovement: ref.watch(stockMovementServiceProvider),
      timeline: ref.watch(customerTimelineServiceProvider),
    ));

final deliveryServiceProvider = Provider<DeliveryService>((ref) => DeliveryService(
      repository: ref.watch(deliveryRepositoryProvider),
      shipments: ref.watch(shipmentRepositoryProvider),
      engine: ref.watch(salesOrderEngineProvider),
      audit: ref.watch(auditServiceProvider),
      permissions: ref.watch(permissionEngineProvider),
      numberGenerator: ref.watch(numberGeneratorEngineProvider),
      timeline: ref.watch(customerTimelineServiceProvider),
    ));

final returnServiceProvider = Provider<ReturnService>((ref) => ReturnService(
      repository: ref.watch(returnRepositoryProvider),
      orders: ref.watch(salesOrderRepositoryProvider),
      engine: ref.watch(salesOrderEngineProvider),
      audit: ref.watch(auditServiceProvider),
      permissions: ref.watch(permissionEngineProvider),
      timeline: ref.watch(customerTimelineServiceProvider),
    ));

final exchangeServiceProvider = Provider<ExchangeService>((ref) => ExchangeService(
      repository: ref.watch(exchangeRepositoryProvider),
      engine: ref.watch(salesOrderEngineProvider),
      audit: ref.watch(auditServiceProvider),
      permissions: ref.watch(permissionEngineProvider),
      timeline: ref.watch(customerTimelineServiceProvider),
    ));

final salesReportServiceProvider = Provider<SalesReportService>((ref) => SalesReportService(
      quotations: ref.watch(quotationRepositoryProvider),
      orders: ref.watch(salesOrderRepositoryProvider),
      reservations: ref.watch(salesReservationRepositoryProvider),
      shipments: ref.watch(shipmentRepositoryProvider),
      engine: ref.watch(salesOrderEngineProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final salesIntegrationServiceProvider = Provider<SalesIntegrationService>((ref) => SalesIntegrationService(
      eventBus: ref.watch(domainEventBusProvider),
      audit: ref.watch(auditServiceProvider),
    ));

SalesSyncProcessor _processor(Ref ref, String entityType, String table) => SalesSyncProcessor(
      remote: ref.watch(salesRemoteDataSourceProvider),
      entityTypeName: entityType,
      remoteTable: table,
    );

final quotationSyncProcessorProvider = Provider<QuotationSyncProcessor>((ref) => _processor(ref, Quotation.entityTypeName, 'quotations'));
final quotationLineSyncProcessorProvider = Provider<QuotationSyncProcessor>((ref) => _processor(ref, QuotationLine.entityTypeName, 'quotation_lines'));
final salesOrderSyncProcessorProvider = Provider<SalesOrderSyncProcessor>((ref) => _processor(ref, SalesOrder.entityTypeName, 'sales_orders'));
final salesOrderLineSyncProcessorProvider = Provider<SalesOrderSyncProcessor>((ref) => _processor(ref, SalesOrderLine.entityTypeName, 'sales_order_lines'));
final salesReservationSyncProcessorProvider = Provider<SalesReservationSyncProcessor>((ref) => _processor(ref, SalesReservation.entityTypeName, 'sales_reservations'));
final backOrderSyncProcessorProvider = Provider<BackOrderSyncProcessor>((ref) => _processor(ref, BackOrder.entityTypeName, 'back_orders'));
final shipmentSyncProcessorProvider = Provider<ShipmentSyncProcessor>((ref) => _processor(ref, Shipment.entityTypeName, 'shipments'));
final shipmentLineSyncProcessorProvider = Provider<ShipmentSyncProcessor>((ref) => _processor(ref, ShipmentLine.entityTypeName, 'shipment_lines'));
final deliverySyncProcessorProvider = Provider<DeliverySyncProcessor>((ref) => _processor(ref, Delivery.entityTypeName, 'deliveries'));
final deliveryLineSyncProcessorProvider = Provider<DeliverySyncProcessor>((ref) => _processor(ref, DeliveryLine.entityTypeName, 'delivery_lines'));
final returnSyncProcessorProvider = Provider<ReturnSyncProcessor>((ref) => _processor(ref, SalesReturnRequest.entityTypeName, 'sales_return_requests'));
final exchangeSyncProcessorProvider = Provider<ExchangeSyncProcessor>((ref) => _processor(ref, ExchangeRequest.entityTypeName, 'exchange_requests'));
final customerTimelineSyncProcessorProvider = Provider<SalesSyncProcessor>((ref) => _processor(ref, CustomerOrderTimeline.entityTypeName, 'customer_order_timeline'));
final salesSettingsSyncProcessorProvider = Provider<SalesSyncProcessor>((ref) => _processor(ref, SalesSettings.entityTypeName, 'sales_settings'));
