import 'package:fashion_pos_enterprise/core/infrastructure/database/app_database.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/pagination/paginated_result.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/base_local_repository.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/sync_queue_writer.dart';
import 'package:fashion_pos_enterprise/features/sales/domain/entities/delivery.dart';
import 'package:fashion_pos_enterprise/features/sales/domain/entities/order.dart';
import 'package:fashion_pos_enterprise/features/sales/domain/entities/quotation.dart';
import 'package:fashion_pos_enterprise/features/sales/domain/entities/returns.dart';
import 'package:fashion_pos_enterprise/features/sales/domain/entities/shipment.dart';
import 'package:fashion_pos_enterprise/features/sales/domain/entities/timeline.dart';
import 'package:fashion_pos_enterprise/features/sales/domain/enums/sales_enums.dart';
import 'package:fashion_pos_enterprise/features/sales/domain/repositories/sales_repositories.dart';

typedef SalesEntityMapper<T> = T Function(Map<String, dynamic> json, LocalRecord record);

class SalesRepositoryImpl<T extends SyncableEntity> extends BaseLocalRepository<T> {
  SalesRepositoryImpl({
    required AppDatabase database,
    required SyncQueueWriter syncQueue,
    required String entityType,
    required this.fromPayload,
    required this.toSearchFields,
  })  : _database = database,
        _syncQueue = syncQueue,
        super(database: database, entityType: entityType, syncQueue: syncQueue);

  final AppDatabase _database;
  final SyncQueueWriter _syncQueue;
  final SalesEntityMapper<T> fromPayload;
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

  SalesRepositoryImpl<R> child<R extends SyncableEntity>({
    required String entityType,
    required SalesEntityMapper<R> fromPayload,
    required ({String? name, String? sku, String? barcode, String? storeId}) Function(R) toSearch,
  }) =>
      SalesRepositoryImpl<R>(
        database: _database,
        syncQueue: _syncQueue,
        entityType: entityType,
        fromPayload: fromPayload,
        toSearchFields: toSearch,
      );
}

class QuotationLocalRepository extends SalesRepositoryImpl<Quotation> implements QuotationRepository {
  QuotationLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: Quotation.entityTypeName,
          fromPayload: Quotation.fromPayload,
          toSearchFields: (e) => (name: e.quotationNumber, sku: e.customerId, barcode: null, storeId: null),
        );

  @override
  Future<List<QuotationLine>> listLines(String tenantId, String quotationId) async {
    final records = await _database.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: QuotationLine.entityTypeName, pageSize: 500),
    );
    return records.map((r) => QuotationLine.fromPayload(r.payload, r)).where((l) => l.quotationId == quotationId).toList();
  }

  @override
  Future<QuotationLine> createLine(QuotationLine line) =>
      child(entityType: QuotationLine.entityTypeName, fromPayload: QuotationLine.fromPayload, toSearch: (e) => (name: e.quotationId, sku: e.productId, barcode: null, storeId: null)).create(line);

  @override
  Future<List<Quotation>> listByStatus(String tenantId, QuotationStatus status) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((q) => q.status == status).toList();
  }
}

class SalesOrderLocalRepository extends SalesRepositoryImpl<SalesOrder> implements SalesOrderRepository {
  SalesOrderLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: SalesOrder.entityTypeName,
          fromPayload: SalesOrder.fromPayload,
          toSearchFields: (e) => (name: e.orderNumber, sku: e.customerId, barcode: null, storeId: null),
        );

  @override
  Future<List<SalesOrderLine>> listLines(String tenantId, String orderId) async {
    final records = await _database.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: SalesOrderLine.entityTypeName, pageSize: 500),
    );
    return records.map((r) => SalesOrderLine.fromPayload(r.payload, r)).where((l) => l.orderId == orderId).toList();
  }

  @override
  Future<SalesOrderLine> createLine(SalesOrderLine line) =>
      child(entityType: SalesOrderLine.entityTypeName, fromPayload: SalesOrderLine.fromPayload, toSearch: (e) => (name: e.orderId, sku: e.productId, barcode: null, storeId: null)).create(line);

  @override
  Future<SalesOrderLine> updateLine(SalesOrderLine line) =>
      child(entityType: SalesOrderLine.entityTypeName, fromPayload: SalesOrderLine.fromPayload, toSearch: (e) => (name: e.orderId, sku: e.productId, barcode: null, storeId: null)).update(line);

  @override
  Future<List<SalesOrder>> listByStatus(String tenantId, SalesOrderStatus status) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((o) => o.status == status).toList();
  }

  @override
  Future<SalesInvoiceReference> createInvoiceReference(SalesInvoiceReference ref) =>
      child(entityType: SalesInvoiceReference.entityTypeName, fromPayload: SalesInvoiceReference.fromPayload, toSearch: (e) => (name: e.invoiceNumber, sku: e.orderId, barcode: null, storeId: null)).create(ref);
}

class SalesReservationLocalRepository extends SalesRepositoryImpl<SalesReservation> implements SalesReservationRepository {
  SalesReservationLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: SalesReservation.entityTypeName,
          fromPayload: SalesReservation.fromPayload,
          toSearchFields: (e) => (name: e.orderId, sku: e.productId, barcode: null, storeId: null),
        );

  @override
  Future<List<SalesReservation>> listByOrder(String tenantId, String orderId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((r) => r.orderId == orderId).toList();
  }

  @override
  Future<List<BackOrder>> listBackOrders(String tenantId, {BackOrderStatus? status}) async {
    final records = await _database.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: BackOrder.entityTypeName, pageSize: 500),
    );
    final items = records.map((r) => BackOrder.fromPayload(r.payload, r)).toList();
    if (status == null) return items;
    return items.where((b) => b.status == status).toList();
  }

  @override
  Future<BackOrder> createBackOrder(BackOrder backOrder) =>
      child(entityType: BackOrder.entityTypeName, fromPayload: BackOrder.fromPayload, toSearch: (e) => (name: e.orderId, sku: e.productId, barcode: null, storeId: null)).create(backOrder);
}

class ShipmentLocalRepository extends SalesRepositoryImpl<Shipment> implements ShipmentRepository {
  ShipmentLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: Shipment.entityTypeName,
          fromPayload: Shipment.fromPayload,
          toSearchFields: (e) => (name: e.shipmentNumber, sku: e.orderId, barcode: null, storeId: null),
        );

  @override
  Future<List<ShipmentLine>> listLines(String tenantId, String shipmentId) async {
    final records = await _database.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: ShipmentLine.entityTypeName, pageSize: 500),
    );
    return records.map((r) => ShipmentLine.fromPayload(r.payload, r)).where((l) => l.shipmentId == shipmentId).toList();
  }

  @override
  Future<ShipmentLine> createLine(ShipmentLine line) =>
      child(entityType: ShipmentLine.entityTypeName, fromPayload: ShipmentLine.fromPayload, toSearch: (e) => (name: e.shipmentId, sku: e.productId, barcode: null, storeId: null)).create(line);

  @override
  Future<List<Shipment>> listByStatus(String tenantId, ShipmentStatus status) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((s) => s.status == status).toList();
  }
}

class DeliveryLocalRepository extends SalesRepositoryImpl<Delivery> implements DeliveryRepository {
  DeliveryLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: Delivery.entityTypeName,
          fromPayload: Delivery.fromPayload,
          toSearchFields: (e) => (name: e.deliveryNumber, sku: e.orderId, barcode: null, storeId: null),
        );

  @override
  Future<List<DeliveryLine>> listLines(String tenantId, String deliveryId) async {
    final records = await _database.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: DeliveryLine.entityTypeName, pageSize: 500),
    );
    return records.map((r) => DeliveryLine.fromPayload(r.payload, r)).where((l) => l.deliveryId == deliveryId).toList();
  }

  @override
  Future<DeliveryLine> createLine(DeliveryLine line) =>
      child(entityType: DeliveryLine.entityTypeName, fromPayload: DeliveryLine.fromPayload, toSearch: (e) => (name: e.deliveryId, sku: e.productId, barcode: null, storeId: null)).create(line);
}

class ReturnLocalRepository extends SalesRepositoryImpl<SalesReturnRequest> implements ReturnRepository {
  ReturnLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: SalesReturnRequest.entityTypeName,
          fromPayload: SalesReturnRequest.fromPayload,
          toSearchFields: (e) => (name: e.returnNumber, sku: e.orderId, barcode: null, storeId: null),
        );

  @override
  Future<PaginatedResult<SalesReturnRequest>> listByOrder(String tenantId, String orderId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 200));
    return PaginatedResult(
      items: page.items.where((r) => r.orderId == orderId).toList(),
      page: page.page,
      pageSize: page.pageSize,
      totalCount: page.totalCount,
      hasMore: page.hasMore,
    );
  }
}

class ExchangeLocalRepository extends SalesRepositoryImpl<ExchangeRequest> implements ExchangeRepository {
  ExchangeLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: ExchangeRequest.entityTypeName,
          fromPayload: ExchangeRequest.fromPayload,
          toSearchFields: (e) => (name: e.exchangeNumber, sku: e.orderId, barcode: null, storeId: null),
        );
}

class CustomerTimelineLocalRepository extends SalesRepositoryImpl<CustomerOrderTimeline> implements CustomerTimelineRepository {
  CustomerTimelineLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: CustomerOrderTimeline.entityTypeName,
          fromPayload: CustomerOrderTimeline.fromPayload,
          toSearchFields: (e) => (name: e.title, sku: e.customerId, barcode: null, storeId: null),
        );

  @override
  Future<List<CustomerOrderTimeline>> listByCustomer(String tenantId, String customerId) async {
    final records = await _database.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: CustomerOrderTimeline.entityTypeName, pageSize: 200, sortBy: 'updated_at'),
    );
    return records.map(mapFromLocalRecord).where((t) => t.customerId == customerId).toList();
  }
}

class SalesSettingsLocalRepository extends SalesRepositoryImpl<SalesSettings> implements SalesSettingsRepository {
  SalesSettingsLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: SalesSettings.entityTypeName,
          fromPayload: SalesSettings.fromPayload,
          toSearchFields: (e) => (name: e.tenantId, sku: null, barcode: null, storeId: null),
        );

  @override
  Future<SalesSettings?> getSettings(String tenantId) async {
    final records = await _database.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: SalesSettings.entityTypeName, pageSize: 1),
    );
    return records.isEmpty ? null : mapFromLocalRecord(records.first);
  }

  @override
  Future<SalesSettings> saveSettings(SalesSettings settings) => create(settings);
}
