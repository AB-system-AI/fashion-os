import 'package:fashion_pos_enterprise/core/infrastructure/database/app_database.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/base_local_repository.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/sync_queue_writer.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/entities/purchase_order.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/entities/purchase_receipt.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/entities/purchase_return.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/entities/supplier.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/entities/supplier_payment.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/enums/purchasing_enums.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/repositories/purchasing_repositories.dart';

typedef PurchasingEntityMapper<T> = T Function(Map<String, dynamic> json, LocalRecord record);

class PurchasingRepositoryImpl<T extends SyncableEntity> extends BaseLocalRepository<T> {
  PurchasingRepositoryImpl({
    required AppDatabase database,
    required SyncQueueWriter syncQueue,
    required String entityType,
    required this.fromPayload,
    required this.toSearchFields,
  }) : super(database: database, entityType: entityType, syncQueue: syncQueue);

  final PurchasingEntityMapper<T> fromPayload;
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

class SupplierRepositoryImpl extends PurchasingRepositoryImpl<Supplier> implements SupplierRepository {
  SupplierRepositoryImpl({required AppDatabase database, required SyncQueueWriter syncQueue})
      : _db = database,
        super(
          database: database,
          syncQueue: syncQueue,
          entityType: Supplier.entityTypeName,
          fromPayload: Supplier.fromPayload,
          toSearchFields: (e) => (name: e.companyName, sku: e.supplierCode, barcode: null, storeId: null),
        );

  final AppDatabase _db;

  @override
  Future<Supplier?> findByCode(String tenantId, String code) async {
    final page = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: Supplier.entityTypeName, search: code, pageSize: 20),
    );
    for (final record in page) {
      final supplier = mapFromLocalRecord(record);
      if (supplier.supplierCode == code) return supplier;
    }
    return null;
  }
}

class PurchaseOrderRepositoryImpl extends PurchasingRepositoryImpl<PurchaseOrder>
    implements PurchaseOrderRepository {
  PurchaseOrderRepositoryImpl({required AppDatabase database, required SyncQueueWriter syncQueue})
      : _db = database,
        super(
          database: database,
          syncQueue: syncQueue,
          entityType: PurchaseOrder.entityTypeName,
          fromPayload: PurchaseOrder.fromPayload,
          toSearchFields: (e) => (name: e.poNumber, sku: e.supplierId, barcode: null, storeId: e.warehouseId),
        );

  final AppDatabase _db;

  @override
  Future<List<PurchaseOrder>> listBySupplier(String tenantId, String supplierId, {int limit = 100}) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: PurchaseOrder.entityTypeName, pageSize: limit),
    );
    return records.map(mapFromLocalRecord).where((o) => o.supplierId == supplierId).toList();
  }

  @override
  Future<List<PurchaseOrder>> listByStatus(String tenantId, PurchaseOrderStatus status, {int limit = 100}) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: PurchaseOrder.entityTypeName, pageSize: limit),
    );
    return records.map(mapFromLocalRecord).where((o) => o.status == status).toList();
  }
}

class PurchaseReceiptRepositoryImpl extends PurchasingRepositoryImpl<PurchaseReceipt>
    implements PurchaseReceiptRepository {
  PurchaseReceiptRepositoryImpl({required AppDatabase database, required SyncQueueWriter syncQueue})
      : _db = database,
        super(
          database: database,
          syncQueue: syncQueue,
          entityType: PurchaseReceipt.entityTypeName,
          fromPayload: PurchaseReceipt.fromPayload,
          toSearchFields: (e) => (name: e.receiptNumber, sku: e.purchaseOrderId, barcode: null, storeId: e.warehouseId),
        );

  final AppDatabase _db;

  @override
  Future<List<PurchaseReceipt>> listByPurchaseOrder(String tenantId, String purchaseOrderId) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: PurchaseReceipt.entityTypeName, pageSize: 200),
    );
    return records.map(mapFromLocalRecord).where((r) => r.purchaseOrderId == purchaseOrderId).toList();
  }
}

class PurchaseReturnRepositoryImpl extends PurchasingRepositoryImpl<PurchaseReturn>
    implements PurchaseReturnRepository {
  PurchaseReturnRepositoryImpl({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: PurchaseReturn.entityTypeName,
          fromPayload: PurchaseReturn.fromPayload,
          toSearchFields: (e) => (name: e.returnNumber, sku: e.supplierId, barcode: null, storeId: e.warehouseId),
        );
}

class SupplierPaymentRepositoryImpl extends PurchasingRepositoryImpl<SupplierPayment>
    implements SupplierPaymentRepository {
  SupplierPaymentRepositoryImpl({required AppDatabase database, required SyncQueueWriter syncQueue})
      : _db = database,
        super(
          database: database,
          syncQueue: syncQueue,
          entityType: SupplierPayment.entityTypeName,
          fromPayload: SupplierPayment.fromPayload,
          toSearchFields: (e) => (name: e.reference, sku: e.supplierId, barcode: null, storeId: null),
        );

  final AppDatabase _db;

  @override
  Future<List<SupplierPayment>> listBySupplier(String tenantId, String supplierId, {int limit = 200}) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: SupplierPayment.entityTypeName, pageSize: limit),
    );
    return records.map(mapFromLocalRecord).where((p) => p.supplierId == supplierId).toList();
  }
}

class SupplierStatementRepositoryImpl extends PurchasingRepositoryImpl<SupplierStatement>
    implements SupplierStatementRepository {
  SupplierStatementRepositoryImpl({required AppDatabase database, required SyncQueueWriter syncQueue})
      : _db = database,
        super(
          database: database,
          syncQueue: syncQueue,
          entityType: SupplierStatement.entityTypeName,
          fromPayload: SupplierStatement.fromPayload,
          toSearchFields: (e) => (name: e.supplierId, sku: null, barcode: null, storeId: null),
        );

  final AppDatabase _db;

  @override
  Future<SupplierStatement?> latestForSupplier(String tenantId, String supplierId) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(
        tenantId: tenantId,
        entityType: SupplierStatement.entityTypeName,
        pageSize: 50,
        sortBy: 'updated_at',
      ),
    );
    final statements = records.map(mapFromLocalRecord).where((s) => s.supplierId == supplierId).toList();
    if (statements.isEmpty) return null;
    statements.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return statements.first;
  }
}
