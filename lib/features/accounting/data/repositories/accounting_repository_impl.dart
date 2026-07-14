import 'package:fashion_pos_enterprise/core/infrastructure/database/app_database.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/pagination/paginated_result.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/base_local_repository.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/sync_queue_writer.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/entities/account.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/entities/bank_account.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/entities/cost_center.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/entities/currency.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/entities/financial_document.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/entities/fiscal_year.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/entities/journal_entry.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/entities/ledger_transaction.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/entities/tax_code.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/enums/accounting_enums.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/repositories/accounting_repositories.dart';

typedef AccountingEntityMapper<T> = T Function(Map<String, dynamic> json, LocalRecord record);

class AccountingRepositoryImpl<T extends SyncableEntity> extends BaseLocalRepository<T> {
  AccountingRepositoryImpl({
    required AppDatabase database,
    required SyncQueueWriter syncQueue,
    required String entityType,
    required this.fromPayload,
    required this.toSearchFields,
  }) : super(database: database, entityType: entityType, syncQueue: syncQueue);

  final AccountingEntityMapper<T> fromPayload;
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

class AccountLocalRepository extends AccountingRepositoryImpl<Account> implements AccountingRepository {
  AccountLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : _db = database,
        _syncQueue = syncQueue,
        super(
          database: database,
          syncQueue: syncQueue,
          entityType: Account.entityTypeName,
          fromPayload: Account.fromPayload,
          toSearchFields: (e) => (name: e.name, sku: e.code, barcode: null, storeId: null),
        );

  final AppDatabase _db;
  final SyncQueueWriter _syncQueue;

  @override
  Future<Account?> findByCode(String tenantId, String code) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: Account.entityTypeName, search: code, pageSize: 20),
    );
    for (final r in records) {
      final a = mapFromLocalRecord(r);
      if (a.code == code) return a;
    }
    return null;
  }

  @override
  Future<List<Account>> listByType(String tenantId, AccountType type) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: Account.entityTypeName, pageSize: 500),
    );
    return records.map(mapFromLocalRecord).where((a) => a.accountType == type).toList();
  }

  @override
  Future<PaginatedResult<Account>> getPage(RepositoryQuery query) => super.getPage(query);

  @override
  Future<AccountGroup> createGroup(AccountGroup group) async {
    final repo = AccountingRepositoryImpl<AccountGroup>(
      database: _db,
      syncQueue: _syncQueue,
      entityType: AccountGroup.entityTypeName,
      fromPayload: AccountGroup.fromPayload,
      toSearchFields: (e) => (name: e.name, sku: e.code, barcode: null, storeId: null),
    );
    return repo.create(group);
  }

  @override
  Future<AccountGroup?> findGroupByCode(String tenantId, String code) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: AccountGroup.entityTypeName, search: code, pageSize: 20),
    );
    for (final r in records) {
      final g = AccountGroup.fromPayload(r.payload, r);
      if (g.code == code) return g;
    }
    return null;
  }

  @override
  Future<CostCenter> createCostCenter(CostCenter center) async {
    final repo = AccountingRepositoryImpl<CostCenter>(
      database: _db,
      syncQueue: _syncQueue,
      entityType: CostCenter.entityTypeName,
      fromPayload: CostCenter.fromPayload,
      toSearchFields: (e) => (name: e.name, sku: e.code, barcode: null, storeId: e.storeId),
    );
    return repo.create(center);
  }

  @override
  Future<TaxCode> createTaxCode(TaxCode code) async {
    final repo = AccountingRepositoryImpl<TaxCode>(
      database: _db,
      syncQueue: _syncQueue,
      entityType: TaxCode.entityTypeName,
      fromPayload: TaxCode.fromPayload,
      toSearchFields: (e) => (name: e.name, sku: e.code, barcode: null, storeId: null),
    );
    return repo.create(code);
  }

  @override
  Future<TaxGroup> createTaxGroup(TaxGroup group) async {
    final repo = AccountingRepositoryImpl<TaxGroup>(
      database: _db,
      syncQueue: _syncQueue,
      entityType: TaxGroup.entityTypeName,
      fromPayload: TaxGroup.fromPayload,
      toSearchFields: (e) => (name: e.name, sku: e.code, barcode: null, storeId: null),
    );
    return repo.create(group);
  }
}

class JournalLocalRepository extends AccountingRepositoryImpl<JournalEntry> implements JournalRepository {
  JournalLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : _db = database,
        super(
          database: database,
          syncQueue: syncQueue,
          entityType: JournalEntry.entityTypeName,
          fromPayload: JournalEntry.fromPayload,
          toSearchFields: (e) => (name: e.entryNumber, sku: e.entryNumber, barcode: null, storeId: e.storeId),
        );

  final AppDatabase _db;

  @override
  Future<JournalEntry?> findByEntryNumber(String tenantId, String entryNumber) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: JournalEntry.entityTypeName, search: entryNumber, pageSize: 20),
    );
    for (final r in records) {
      final e = mapFromLocalRecord(r);
      if (e.entryNumber == entryNumber) return e;
    }
    return null;
  }

  @override
  Future<JournalEntry?> findByReference(String tenantId, String referenceType, String referenceId) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: JournalEntry.entityTypeName, pageSize: 200),
    );
    for (final r in records) {
      final e = mapFromLocalRecord(r);
      if (e.referenceType == referenceType && e.referenceId == referenceId) return e;
    }
    return null;
  }

  @override
  Future<List<JournalEntry>> listByStatus(String tenantId, JournalStatus status, {int limit = 100}) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: JournalEntry.entityTypeName, pageSize: limit),
    );
    return records.map(mapFromLocalRecord).where((e) => e.status == status).toList();
  }
}

class LedgerLocalRepository extends AccountingRepositoryImpl<LedgerTransaction> implements LedgerRepository {
  LedgerLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : _db = database,
        super(
          database: database,
          syncQueue: syncQueue,
          entityType: LedgerTransaction.entityTypeName,
          fromPayload: LedgerTransaction.fromPayload,
          toSearchFields: (e) => (name: e.accountCode, sku: e.journalEntryId, barcode: null, storeId: e.storeId),
        );

  final AppDatabase _db;

  @override
  Future<List<LedgerTransaction>> listByAccount(String tenantId, String accountId, {int limit = 500}) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: LedgerTransaction.entityTypeName, pageSize: limit),
    );
    return records.map(mapFromLocalRecord).where((t) => t.accountId == accountId).toList();
  }

  @override
  Future<List<LedgerTransaction>> listByJournal(String tenantId, String journalEntryId) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: LedgerTransaction.entityTypeName, pageSize: 200),
    );
    return records.map(mapFromLocalRecord).where((t) => t.journalEntryId == journalEntryId).toList();
  }

  @override
  Future<List<LedgerTransaction>> listByDateRange(String tenantId, DateTime from, DateTime to) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: LedgerTransaction.entityTypeName, pageSize: 1000),
    );
    return records
        .map(mapFromLocalRecord)
        .where((t) => !t.entryDate.isBefore(from) && !t.entryDate.isAfter(to))
        .toList();
  }
}

class BankLocalRepository extends AccountingRepositoryImpl<BankAccount> implements BankRepository {
  BankLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : _db = database,
        _syncQueue = syncQueue,
        super(
          database: database,
          syncQueue: syncQueue,
          entityType: BankAccount.entityTypeName,
          fromPayload: BankAccount.fromPayload,
          toSearchFields: (e) => (name: e.name, sku: e.accountNumber, barcode: null, storeId: null),
        );

  final AppDatabase _db;
  final SyncQueueWriter _syncQueue;

  @override
  Future<List<BankTransaction>> listTransactions(String tenantId, String bankAccountId) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: BankTransaction.entityTypeName, pageSize: 500),
    );
    return records
        .map((r) => BankTransaction.fromPayload(r.payload, r))
        .where((t) => t.bankAccountId == bankAccountId)
        .toList();
  }

  @override
  Future<BankTransaction> createTransaction(BankTransaction transaction) async {
    final repo = AccountingRepositoryImpl<BankTransaction>(
      database: _db,
      syncQueue: _syncQueue,
      entityType: BankTransaction.entityTypeName,
      fromPayload: BankTransaction.fromPayload,
      toSearchFields: (e) => (name: e.reference, sku: e.bankAccountId, barcode: null, storeId: null),
    );
    return repo.create(transaction);
  }

  @override
  Future<ReconciliationSession> createReconciliation(ReconciliationSession session) async {
    final repo = AccountingRepositoryImpl<ReconciliationSession>(
      database: _db,
      syncQueue: _syncQueue,
      entityType: ReconciliationSession.entityTypeName,
      fromPayload: ReconciliationSession.fromPayload,
      toSearchFields: (e) => (name: e.bankAccountId, sku: null, barcode: null, storeId: null),
    );
    return repo.create(session);
  }
}

class CurrencyLocalRepository extends AccountingRepositoryImpl<ExchangeRate> implements CurrencyRepository {
  CurrencyLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : _db = database,
        super(
          database: database,
          syncQueue: syncQueue,
          entityType: ExchangeRate.entityTypeName,
          fromPayload: ExchangeRate.fromPayload,
          toSearchFields: (e) => (name: '${e.fromCurrency}/${e.toCurrency}', sku: e.fromCurrency, barcode: null, storeId: null),
        );

  final AppDatabase _db;

  @override
  Future<ExchangeRate?> findRate(String tenantId, String from, String to, DateTime on) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: ExchangeRate.entityTypeName, pageSize: 100),
    );
    ExchangeRate? best;
    for (final r in records) {
      final rate = mapFromLocalRecord(r);
      if (rate.fromCurrency == from && rate.toCurrency == to) {
        if (best == null || rate.effectiveDate.isAfter(best.effectiveDate)) best = rate;
      }
    }
    return best;
  }

  @override
  Future<AccountingCurrency?> findCurrency(String tenantId, String code) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: AccountingCurrency.entityTypeName, search: code, pageSize: 20),
    );
    for (final r in records) {
      final c = AccountingCurrency.fromPayload(r.payload, r);
      if (c.code == code) return c;
    }
    return null;
  }

  @override
  Future<PaymentTerm?> findPaymentTerm(String tenantId, String code) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: PaymentTerm.entityTypeName, search: code, pageSize: 20),
    );
    for (final r in records) {
      final t = PaymentTerm.fromPayload(r.payload, r);
      if (t.code == code) return t;
    }
    return null;
  }

  @override
  Future<FiscalYear?> findOpenFiscalYear(String tenantId) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: FiscalYear.entityTypeName, pageSize: 20),
    );
    for (final r in records) {
      final y = FiscalYear.fromPayload(r.payload, r);
      if (!y.closed) return y;
    }
    return null;
  }

  @override
  Future<FiscalPeriod?> findOpenPeriod(String tenantId, DateTime date) async {
    final records = await _db.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: FiscalPeriod.entityTypeName, pageSize: 50),
    );
    for (final r in records) {
      final p = FiscalPeriod.fromPayload(r.payload, r);
      if (p.status == FiscalPeriodStatus.open &&
          !date.isBefore(p.startDate) &&
          !date.isAfter(p.endDate)) {
        return p;
      }
    }
    return null;
  }
}
