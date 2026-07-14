import 'package:fashion_pos_enterprise/core/infrastructure/database/app_database.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/base_local_repository.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/sync_queue_writer.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/entities/customer.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/entities/customer_activity.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/entities/customer_credit.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/entities/customer_group.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/entities/customer_loyalty_account.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/entities/customer_wallet.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/entities/loyalty_point_transaction.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/repositories/customer_repositories.dart';

typedef CustomerEntityMapper<T> = T Function(Map<String, dynamic> json, LocalRecord record);

class CustomerRepositoryImpl<T extends SyncableEntity> extends BaseLocalRepository<T> {
  CustomerRepositoryImpl({
    required AppDatabase database,
    required SyncQueueWriter syncQueue,
    required String entityType,
    required this.fromPayload,
    required this.toSearchFields,
  }) : super(database: database, entityType: entityType, syncQueue: syncQueue);

  final CustomerEntityMapper<T> fromPayload;
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

class CustomerLocalRepository extends CustomerRepositoryImpl<Customer> implements CustomerRepository {
  CustomerLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : _db = database,
        super(
          database: database,
          syncQueue: syncQueue,
          entityType: Customer.entityTypeName,
          fromPayload: Customer.fromPayload,
          toSearchFields: (e) => (name: e.fullName, sku: e.customerCode, barcode: e.membershipBarcode, storeId: null),
        );

  final AppDatabase _db;

  Future<List<Customer>> _searchRecords(String tenantId, String query, {int pageSize = 50}) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: Customer.entityTypeName, search: query, pageSize: pageSize),
    );
    return records.map(mapFromLocalRecord).toList();
  }

  @override
  Future<Customer?> findByCode(String tenantId, String code) async {
    for (final c in await _searchRecords(tenantId, code)) {
      if (c.customerCode == code) return c;
    }
    return null;
  }

  @override
  Future<Customer?> findByPhone(String tenantId, String phone) async {
    for (final c in await _searchRecords(tenantId, phone)) {
      if (c.phone == phone || c.mobile == phone) return c;
    }
    return null;
  }

  @override
  Future<Customer?> findByMembershipBarcode(String tenantId, String barcode) async {
    for (final c in await _searchRecords(tenantId, barcode)) {
      if (c.membershipBarcode == barcode) return c;
    }
    return null;
  }
}

class CustomerGroupRepositoryImpl extends CustomerRepositoryImpl<CustomerGroup> implements CustomerGroupRepository {
  CustomerGroupRepositoryImpl({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: CustomerGroup.entityTypeName,
          fromPayload: CustomerGroup.fromPayload,
          toSearchFields: (e) => (name: e.name, sku: e.code, barcode: null, storeId: null),
        );
}

class CustomerLoyaltyAccountRepositoryImpl extends CustomerRepositoryImpl<CustomerLoyaltyAccount>
    implements CustomerLoyaltyAccountRepository {
  CustomerLoyaltyAccountRepositoryImpl({required AppDatabase database, required SyncQueueWriter syncQueue})
      : _db = database,
        super(
          database: database,
          syncQueue: syncQueue,
          entityType: CustomerLoyaltyAccount.entityTypeName,
          fromPayload: CustomerLoyaltyAccount.fromPayload,
          toSearchFields: (e) => (name: e.tierName, sku: e.customerId, barcode: null, storeId: e.customerId),
        );

  final AppDatabase _db;

  @override
  Future<CustomerLoyaltyAccount?> findByCustomer(String tenantId, String customerId) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(
        tenantId: tenantId,
        entityType: CustomerLoyaltyAccount.entityTypeName,
        storeId: customerId,
        pageSize: 10,
      ),
    );
    return records.isEmpty ? null : mapFromLocalRecord(records.first);
  }

  @override
  Future<List<LoyaltyPointTransaction>> listTransactions(String tenantId, String accountId, {int limit = 100}) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: LoyaltyPointTransaction.entityTypeName, pageSize: limit),
    );
    return records
        .map((r) => LoyaltyPointTransaction.fromPayload(r.payload, r))
        .where((t) => t.accountId == accountId)
        .toList();
  }
}

class LoyaltyPointTransactionRepositoryImpl extends CustomerRepositoryImpl<LoyaltyPointTransaction>
    implements LoyaltyPointTransactionRepository {
  LoyaltyPointTransactionRepositoryImpl({required AppDatabase database, required SyncQueueWriter syncQueue})
      : _db = database,
        super(
          database: database,
          syncQueue: syncQueue,
          entityType: LoyaltyPointTransaction.entityTypeName,
          fromPayload: LoyaltyPointTransaction.fromPayload,
          toSearchFields: (e) => (name: e.description, sku: e.customerId, barcode: null, storeId: e.customerId),
        );

  final AppDatabase _db;

  @override
  Future<List<LoyaltyPointTransaction>> listByCustomer(String tenantId, String customerId, {int limit = 100}) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(
        tenantId: tenantId,
        entityType: LoyaltyPointTransaction.entityTypeName,
        storeId: customerId,
        pageSize: limit,
        sortBy: 'updated_at',
      ),
    );
    return records.map(mapFromLocalRecord).toList();
  }
}

class CustomerWalletRepositoryImpl extends CustomerRepositoryImpl<CustomerWallet> implements CustomerWalletRepository {
  CustomerWalletRepositoryImpl({required AppDatabase database, required SyncQueueWriter syncQueue})
      : _db = database,
        super(
          database: database,
          syncQueue: syncQueue,
          entityType: CustomerWallet.entityTypeName,
          fromPayload: CustomerWallet.fromPayload,
          toSearchFields: (e) => (name: e.customerId, sku: null, barcode: null, storeId: e.customerId),
        );

  final AppDatabase _db;

  @override
  Future<CustomerWallet?> findByCustomer(String tenantId, String customerId) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: CustomerWallet.entityTypeName, storeId: customerId, pageSize: 5),
    );
    return records.isEmpty ? null : mapFromLocalRecord(records.first);
  }
}

class CustomerCreditRepositoryImpl extends CustomerRepositoryImpl<CustomerCreditAccount>
    implements CustomerCreditRepository {
  CustomerCreditRepositoryImpl({required AppDatabase database, required SyncQueueWriter syncQueue})
      : _db = database,
        super(
          database: database,
          syncQueue: syncQueue,
          entityType: CustomerCreditAccount.entityTypeName,
          fromPayload: CustomerCreditAccount.fromPayload,
          toSearchFields: (e) => (name: e.customerId, sku: null, barcode: null, storeId: e.customerId),
        );

  final AppDatabase _db;

  @override
  Future<CustomerCreditAccount?> findByCustomer(String tenantId, String customerId) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: CustomerCreditAccount.entityTypeName, storeId: customerId, pageSize: 5),
    );
    return records.isEmpty ? null : mapFromLocalRecord(records.first);
  }
}

class CustomerActivityRepositoryImpl extends CustomerRepositoryImpl<CustomerActivity>
    implements CustomerActivityRepository {
  CustomerActivityRepositoryImpl({required AppDatabase database, required SyncQueueWriter syncQueue})
      : _db = database,
        super(
          database: database,
          syncQueue: syncQueue,
          entityType: CustomerActivity.entityTypeName,
          fromPayload: CustomerActivity.fromPayload,
          toSearchFields: (e) => (name: e.title, sku: e.customerId, barcode: null, storeId: e.customerId),
        );

  final AppDatabase _db;

  @override
  Future<List<CustomerActivity>> listByCustomer(String tenantId, String customerId, {int limit = 100}) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(
        tenantId: tenantId,
        entityType: CustomerActivity.entityTypeName,
        storeId: customerId,
        pageSize: limit,
        sortBy: 'updated_at',
      ),
    );
    return records.map(mapFromLocalRecord).toList();
  }
}
