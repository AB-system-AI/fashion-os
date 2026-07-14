import 'package:fashion_pos_enterprise/core/infrastructure/database/app_database.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/base_local_repository.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/sync_queue_writer.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/entities/accounts.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/entities/cheques.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/entities/expenses.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/entities/forecast.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/entities/movements.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/entities/vouchers.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/enums/treasury_enums.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/repositories/treasury_repositories.dart';

typedef TreasuryEntityMapper<T> = T Function(Map<String, dynamic> json, LocalRecord record);

class TreasuryRepositoryImpl<T extends SyncableEntity> extends BaseLocalRepository<T> {
  TreasuryRepositoryImpl({
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
  final TreasuryEntityMapper<T> fromPayload;
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

class CashBoxLocalRepository extends TreasuryRepositoryImpl<CashBox> implements CashBoxRepository {
  CashBoxLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: CashBox.entityTypeName,
          fromPayload: CashBox.fromPayload,
          toSearchFields: (e) => (name: e.name, sku: null, barcode: null, storeId: e.storeId),
        );

  @override
  Future<List<CashBox>> listByStore(String tenantId, String? storeId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500, storeId: storeId));
    return page.items;
  }
}

class BankLocalRepository extends TreasuryRepositoryImpl<Bank> implements BankRepository {
  BankLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: Bank.entityTypeName,
          fromPayload: Bank.fromPayload,
          toSearchFields: (e) => (name: e.name, sku: e.code, barcode: null, storeId: null),
        );

  @override
  Future<List<Bank>> listActive(String tenantId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((b) => b.isActive).toList();
  }
}

class BankAccountLocalRepository extends TreasuryRepositoryImpl<BankAccount> implements BankAccountRepository {
  BankAccountLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: BankAccount.entityTypeName,
          fromPayload: BankAccount.fromPayload,
          toSearchFields: (e) => (name: e.accountNumber, sku: e.bankId, barcode: null, storeId: null),
        );

  @override
  Future<List<BankAccount>> listByBank(String tenantId, String bankId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((a) => a.bankId == bankId).toList();
  }

  @override
  Future<List<BankAccount>> listActive(String tenantId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((a) => a.status == BankAccountStatus.active).toList();
  }
}

class PettyCashLocalRepository extends TreasuryRepositoryImpl<PettyCash> implements PettyCashRepository {
  PettyCashLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: PettyCash.entityTypeName,
          fromPayload: PettyCash.fromPayload,
          toSearchFields: (e) => (name: e.name, sku: e.custodianId, barcode: null, storeId: null),
        );
}

class TransferLocalRepository extends TreasuryRepositoryImpl<Transfer> implements TransferRepository {
  TransferLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: Transfer.entityTypeName,
          fromPayload: Transfer.fromPayload,
          toSearchFields: (e) => (name: e.transferNumber, sku: e.fromAccountId, barcode: e.toAccountId, storeId: null),
        );

  @override
  Future<List<Transfer>> listByStatus(String tenantId, TransferStatus status) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((t) => t.status == status).toList();
  }
}

class ChequeLocalRepository extends TreasuryRepositoryImpl<Cheque> implements ChequeRepository {
  ChequeLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: Cheque.entityTypeName,
          fromPayload: Cheque.fromPayload,
          toSearchFields: (e) => (name: e.chequeNumber, sku: e.bankAccountId, barcode: null, storeId: null),
        );

  @override
  Future<List<Cheque>> listByStatus(String tenantId, ChequeStatus status) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((c) => c.status == status).toList();
  }
}

class ChequeBookLocalRepository extends TreasuryRepositoryImpl<ChequeBook> implements ChequeBookRepository {
  ChequeBookLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: ChequeBook.entityTypeName,
          fromPayload: ChequeBook.fromPayload,
          toSearchFields: (e) => (name: e.bankAccountId, sku: '${e.startNumber}', barcode: '${e.endNumber}', storeId: null),
        );

  @override
  Future<List<ChequeBook>> listByBankAccount(String tenantId, String bankAccountId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((b) => b.bankAccountId == bankAccountId).toList();
  }
}

class PaymentVoucherLocalRepository extends TreasuryRepositoryImpl<PaymentVoucher> implements PaymentVoucherRepository {
  PaymentVoucherLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: PaymentVoucher.entityTypeName,
          fromPayload: PaymentVoucher.fromPayload,
          toSearchFields: (e) => (name: e.voucherNumber, sku: e.payeeName, barcode: null, storeId: null),
        );

  @override
  Future<List<PaymentVoucher>> listByStatus(String tenantId, VoucherStatus status) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((v) => v.status == status).toList();
  }
}

class ReceiptVoucherLocalRepository extends TreasuryRepositoryImpl<ReceiptVoucher> implements ReceiptVoucherRepository {
  ReceiptVoucherLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: ReceiptVoucher.entityTypeName,
          fromPayload: ReceiptVoucher.fromPayload,
          toSearchFields: (e) => (name: e.voucherNumber, sku: e.payerName, barcode: null, storeId: null),
        );

  @override
  Future<List<ReceiptVoucher>> listByStatus(String tenantId, VoucherStatus status) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((v) => v.status == status).toList();
  }
}

class ExpenseRequestLocalRepository extends TreasuryRepositoryImpl<ExpenseRequest> implements ExpenseRequestRepository {
  ExpenseRequestLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: ExpenseRequest.entityTypeName,
          fromPayload: ExpenseRequest.fromPayload,
          toSearchFields: (e) => (name: e.requestNumber, sku: e.category, barcode: null, storeId: null),
        );

  @override
  Future<List<ExpenseRequest>> listByStatus(String tenantId, ExpenseRequestStatus status) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((e) => e.status == status).toList();
  }
}

class ExpenseApprovalLocalRepository extends TreasuryRepositoryImpl<ExpenseApproval> implements ExpenseApprovalRepository {
  ExpenseApprovalLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: ExpenseApproval.entityTypeName,
          fromPayload: ExpenseApproval.fromPayload,
          toSearchFields: (e) => (name: e.expenseRequestId, sku: e.approverId, barcode: null, storeId: null),
        );

  @override
  Future<List<ExpenseApproval>> listByRequest(String tenantId, String expenseRequestId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((a) => a.expenseRequestId == expenseRequestId).toList();
  }
}

class CashForecastLocalRepository extends TreasuryRepositoryImpl<CashForecast> implements CashForecastRepository {
  CashForecastLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: CashForecast.entityTypeName,
          fromPayload: CashForecast.fromPayload,
          toSearchFields: (e) => (name: e.forecastDate.toIso8601String(), sku: e.period.value, barcode: null, storeId: null),
        );

  @override
  Future<List<CashForecast>> listByPeriod(String tenantId, ForecastPeriod period) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((f) => f.period == period).toList();
  }
}

class BankReconciliationLocalRepository extends TreasuryRepositoryImpl<BankReconciliation> implements BankReconciliationRepository {
  BankReconciliationLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: BankReconciliation.entityTypeName,
          fromPayload: BankReconciliation.fromPayload,
          toSearchFields: (e) => (name: e.bankAccountId, sku: e.status.value, barcode: null, storeId: null),
        );

  @override
  Future<List<BankReconciliation>> listByBankAccount(String tenantId, String bankAccountId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((r) => r.bankAccountId == bankAccountId).toList();
  }

  @override
  Future<List<BankReconciliation>> listByStatus(String tenantId, ReconciliationStatus status) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((r) => r.status == status).toList();
  }
}

class TreasurySettingsLocalRepository extends TreasuryRepositoryImpl<TreasurySettings> implements TreasurySettingsRepository {
  TreasurySettingsLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: TreasurySettings.entityTypeName,
          fromPayload: TreasurySettings.fromPayload,
          toSearchFields: (e) => (name: e.baseCurrency, sku: null, barcode: null, storeId: null),
        );

  @override
  Future<TreasurySettings?> getSettings(String tenantId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 1));
    return page.items.isEmpty ? null : page.items.first;
  }

  @override
  Future<TreasurySettings> saveSettings(TreasurySettings settings) => update(settings);
}

class CashMovementLocalRepository extends TreasuryRepositoryImpl<CashMovement> implements CashMovementRepository {
  CashMovementLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: CashMovement.entityTypeName,
          fromPayload: CashMovement.fromPayload,
          toSearchFields: (e) => (name: e.cashBoxId, sku: e.reference, barcode: null, storeId: null),
        );

  @override
  Future<List<CashMovement>> listByCashBox(String tenantId, String cashBoxId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((m) => m.cashBoxId == cashBoxId).toList();
  }
}

class BankMovementLocalRepository extends TreasuryRepositoryImpl<BankMovement> implements BankMovementRepository {
  BankMovementLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: BankMovement.entityTypeName,
          fromPayload: BankMovement.fromPayload,
          toSearchFields: (e) => (name: e.bankAccountId, sku: e.reference, barcode: null, storeId: null),
        );

  @override
  Future<List<BankMovement>> listByBankAccount(String tenantId, String bankAccountId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((m) => m.bankAccountId == bankAccountId).toList();
  }
}

class TreasuryAccountLocalRepository extends TreasuryRepositoryImpl<TreasuryAccount> implements TreasuryAccountRepository {
  TreasuryAccountLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: TreasuryAccount.entityTypeName,
          fromPayload: TreasuryAccount.fromPayload,
          toSearchFields: (e) => (name: e.name, sku: e.code, barcode: null, storeId: null),
        );
}
