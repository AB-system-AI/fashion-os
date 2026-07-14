import 'package:fashion_pos_enterprise/core/infrastructure/database/app_database.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/pagination/paginated_result.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/base_local_repository.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/sync_queue_writer.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/entities/cash_movement.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/entities/cash_session.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/entities/coupon.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/entities/exchange_reference.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/entities/payment.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/entities/receipt.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/entities/return_reference.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/entities/sale.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/entities/suspended_sale.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/enums/pos_enums.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/repositories/cash_repository.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/repositories/coupon_repository.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/repositories/receipt_repository.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/repositories/sale_repository.dart';

typedef PosEntityMapper<T> = T Function(Map<String, dynamic> json, LocalRecord record);

class PosRepositoryImpl<T extends SyncableEntity> extends BaseLocalRepository<T> {
  PosRepositoryImpl({
    required AppDatabase database,
    required SyncQueueWriter syncQueue,
    required String entityType,
    required this.fromPayload,
    required this.toSearchFields,
  }) : super(database: database, entityType: entityType, syncQueue: syncQueue);

  final PosEntityMapper<T> fromPayload;
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
}

class SaleLocalRepository extends PosRepositoryImpl<Sale> implements SaleRepository {
  SaleLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : _db = database,
        super(
          database: database,
          syncQueue: syncQueue,
          entityType: Sale.entityTypeName,
          fromPayload: Sale.fromPayload,
          toSearchFields: (e) => (name: e.orderNumber, sku: e.orderNumber, barcode: null, storeId: e.storeId),
        );

  final AppDatabase _db;

  @override
  Future<Sale?> findByOrderNumber(String tenantId, String orderNumber) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: Sale.entityTypeName, search: orderNumber, pageSize: 20),
    );
    for (final r in records) {
      final sale = mapFromLocalRecord(r);
      if (sale.orderNumber == orderNumber) return sale;
    }
    return null;
  }

  @override
  Future<List<Sale>> listBySession(String tenantId, String cashSessionId) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: Sale.entityTypeName, pageSize: 200),
    );
    return records.map(mapFromLocalRecord).where((s) => s.cashSessionId == cashSessionId).toList();
  }

  @override
  Future<List<Sale>> listByStatus(String tenantId, SaleStatus status, {int limit = 50}) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: Sale.entityTypeName, pageSize: limit),
    );
    return records.map(mapFromLocalRecord).where((s) => s.status == status).toList();
  }

  @override
  Future<PaginatedResult<Sale>> getPage(RepositoryQuery query) => super.getPage(query);
}

class PaymentLocalRepository extends PosRepositoryImpl<Payment> implements PaymentRepository {
  PaymentLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : _db = database,
        super(
          database: database,
          syncQueue: syncQueue,
          entityType: Payment.entityTypeName,
          fromPayload: Payment.fromPayload,
          toSearchFields: (e) => (name: e.saleOrderId, sku: null, barcode: null, storeId: null),
        );

  final AppDatabase _db;

  @override
  Future<List<Payment>> listBySale(String tenantId, String saleOrderId) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: Payment.entityTypeName, pageSize: 50),
    );
    return records.map(mapFromLocalRecord).where((p) => p.saleOrderId == saleOrderId).toList();
  }
}

class CashLocalRepository extends PosRepositoryImpl<CashSession> implements CashRepository {
  CashLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : _db = database,
        _syncQueue = syncQueue,
        super(
          database: database,
          syncQueue: syncQueue,
          entityType: CashSession.entityTypeName,
          fromPayload: CashSession.fromPayload,
          toSearchFields: (e) => (name: e.sessionNumber, sku: e.sessionNumber, barcode: null, storeId: e.storeId),
        );

  final AppDatabase _db;
  final SyncQueueWriter _syncQueue;

  @override
  Future<CashSession?> findOpenSession(String tenantId, String registerId) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: CashSession.entityTypeName, pageSize: 50),
    );
    for (final r in records) {
      final session = mapFromLocalRecord(r);
      if (session.registerId == registerId && session.isOpen) return session;
    }
    return null;
  }

  @override
  Future<List<CashMovement>> listMovements(String tenantId, String sessionId) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: CashMovement.entityTypeName, pageSize: 200),
    );
    return records
        .map((r) => CashMovement.fromPayload(r.payload, r))
        .where((m) => m.sessionId == sessionId)
        .toList();
  }

  @override
  Future<CashMovement> createMovement(CashMovement movement) async {
    final repo = PosRepositoryImpl<CashMovement>(
      database: _db,
      syncQueue: _syncQueue,
      entityType: CashMovement.entityTypeName,
      fromPayload: CashMovement.fromPayload,
      toSearchFields: (e) => (name: e.sessionId, sku: null, barcode: null, storeId: null),
    );
    return repo.create(movement);
  }
}

class ReceiptLocalRepository extends PosRepositoryImpl<Receipt> implements ReceiptRepository {
  ReceiptLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : _db = database,
        super(
          database: database,
          syncQueue: syncQueue,
          entityType: Receipt.entityTypeName,
          fromPayload: Receipt.fromPayload,
          toSearchFields: (e) => (name: e.receiptNumber, sku: e.receiptNumber, barcode: e.barcode, storeId: e.storeId),
        );

  final AppDatabase _db;

  @override
  Future<Receipt?> findBySaleOrder(String tenantId, String saleOrderId) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: Receipt.entityTypeName, pageSize: 20),
    );
    for (final r in records) {
      final receipt = mapFromLocalRecord(r);
      if (receipt.saleOrderId == saleOrderId) return receipt;
    }
    return null;
  }

  @override
  Future<Receipt?> findByReceiptNumber(String tenantId, String receiptNumber) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: Receipt.entityTypeName, search: receiptNumber, pageSize: 20),
    );
    for (final r in records) {
      final receipt = mapFromLocalRecord(r);
      if (receipt.receiptNumber == receiptNumber) return receipt;
    }
    return null;
  }

  @override
  Future<List<Receipt>> listPrintHistory(String tenantId, String saleOrderId) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: Receipt.entityTypeName, pageSize: 50),
    );
    return records.map(mapFromLocalRecord).where((r) => r.saleOrderId == saleOrderId).toList();
  }
}

class CouponLocalRepository extends PosRepositoryImpl<Coupon> implements CouponRepository {
  CouponLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : _db = database,
        super(
          database: database,
          syncQueue: syncQueue,
          entityType: Coupon.entityTypeName,
          fromPayload: Coupon.fromPayload,
          toSearchFields: (e) => (name: e.code, sku: e.code, barcode: null, storeId: null),
        );

  final AppDatabase _db;

  @override
  Future<Coupon?> findByCode(String tenantId, String code) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: Coupon.entityTypeName, search: code, pageSize: 20),
    );
    for (final r in records) {
      final coupon = mapFromLocalRecord(r);
      if (coupon.code.toUpperCase() == code.toUpperCase()) return coupon;
    }
    return null;
  }
}

class SuspendedSaleLocalRepository extends PosRepositoryImpl<SuspendedSale> implements SuspendedSaleRepository {
  SuspendedSaleLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : _db = database,
        super(
          database: database,
          syncQueue: syncQueue,
          entityType: SuspendedSale.entityTypeName,
          fromPayload: SuspendedSale.fromPayload,
          toSearchFields: (e) => (name: e.label ?? e.sale.orderNumber, sku: e.sale.orderNumber, barcode: null, storeId: e.storeId),
        );

  final AppDatabase _db;

  @override
  Future<List<SuspendedSale>> listByStore(String tenantId, String storeId) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: SuspendedSale.entityTypeName, pageSize: 100),
    );
    return records.map(mapFromLocalRecord).where((s) => s.storeId == storeId).toList();
  }
}

class ReturnLocalRepository extends PosRepositoryImpl<ReturnReference> implements ReturnRepository {
  ReturnLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : _db = database,
        super(
          database: database,
          syncQueue: syncQueue,
          entityType: ReturnReference.entityTypeName,
          fromPayload: ReturnReference.fromPayload,
          toSearchFields: (e) => (name: e.returnNumber, sku: e.returnNumber, barcode: null, storeId: e.storeId),
        );

  final AppDatabase _db;

  @override
  Future<ReturnReference?> findByReturnNumber(String tenantId, String returnNumber) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: ReturnReference.entityTypeName, search: returnNumber, pageSize: 20),
    );
    for (final r in records) {
      final ret = mapFromLocalRecord(r);
      if (ret.returnNumber == returnNumber) return ret;
    }
    return null;
  }
}

class ExchangeLocalRepository extends PosRepositoryImpl<ExchangeReference> implements ExchangeRepository {
  ExchangeLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : _db = database,
        super(
          database: database,
          syncQueue: syncQueue,
          entityType: ExchangeReference.entityTypeName,
          fromPayload: ExchangeReference.fromPayload,
          toSearchFields: (e) => (name: e.exchangeNumber, sku: e.exchangeNumber, barcode: null, storeId: e.storeId),
        );

  final AppDatabase _db;

  @override
  Future<ExchangeReference?> findByExchangeNumber(String tenantId, String exchangeNumber) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: ExchangeReference.entityTypeName, search: exchangeNumber, pageSize: 20),
    );
    for (final r in records) {
      final ex = mapFromLocalRecord(r);
      if (ex.exchangeNumber == exchangeNumber) return ex;
    }
    return null;
  }
}
