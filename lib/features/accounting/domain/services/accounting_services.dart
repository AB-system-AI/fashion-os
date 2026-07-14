import 'package:uuid/uuid.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_action.dart';
import 'package:fashion_pos_enterprise/core/audit/audit_service.dart';
import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/business/engines/accounting/accounting_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/number_generator_engine.dart';
import 'package:fashion_pos_enterprise/core/business/events/business_events.dart';
import 'package:fashion_pos_enterprise/core/business/events/domain_event_bus.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_engine.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/entities/account.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/entities/journal_entry.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/entities/journal_line.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/entities/bank_account.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/entities/currency.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/entities/fiscal_year.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/entities/ledger_transaction.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/enums/accounting_enums.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/repositories/accounting_repositories.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';

class PostingService {
  PostingService({
    required JournalRepository journalRepository,
    required LedgerRepository ledgerRepository,
    required AccountingRepository accountingRepository,
    required AccountingEngine accountingEngine,
    required AuditService auditService,
    required PermissionEngine permissionEngine,
    required NumberGeneratorEngine numberGenerator,
    Uuid? uuid,
  })  : _journals = journalRepository,
        _ledger = ledgerRepository,
        _accounts = accountingRepository,
        _engine = accountingEngine,
        _audit = auditService,
        _permissions = permissionEngine,
        _numbers = numberGenerator,
        _uuid = uuid ?? const Uuid();

  final JournalRepository _journals;
  final LedgerRepository _ledger;
  final AccountingRepository _accounts;
  final AccountingEngine _engine;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final NumberGeneratorEngine _numbers;
  final Uuid _uuid;

  Future<Result<JournalEntry>> postJournal({
    required AuthUser user,
    required JournalEntry draft,
  }) async {
    try {
      _permissions.require(user, JournalPermissions.post);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    final validation = _engine.validateJournalLines(draft.lines);
    if (validation.isFailure) return Error(validation.failureOrNull!);

    final tenantId = user.tenantId ?? draft.tenantId;
    final existing = draft.referenceType != null && draft.referenceId != null
        ? await _journals.findByReference(tenantId, draft.referenceType!, draft.referenceId!)
        : null;
    if (existing != null && existing.status == JournalStatus.posted) {
      return Success(existing);
    }

    final numberResult = draft.entryNumber.isNotEmpty
        ? Success(draft.entryNumber)
        : (await _numbers.next(type: DocumentNumberType.journalEntry, tenantId: tenantId))
            .map((n) => n.value);
    if (numberResult.isFailure) return Error(numberResult.failureOrNull!);

    final now = DateTime.now().toUtc();
    final entry = draft.copyWith(
      id: draft.id.isEmpty ? _uuid.v4() : draft.id,
      entryNumber: numberResult.dataOrNull!,
      status: JournalStatus.posted,
      postedAt: now,
      version: 1,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );

    final saved = existing == null ? await _journals.create(entry) : await _journals.update(entry);

    final accountMap = <String, Account>{};
    for (final line in saved.lines) {
      final account = await _accounts.findByCode(tenantId, line.accountCode) ??
          await _accounts.getById(line.accountId, tenantId: tenantId);
      if (account != null) accountMap[line.accountId] = account;
    }

    final ledgerTxs = _engine.buildLedgerTransactions(entry: saved, accounts: accountMap);
    for (final tx in ledgerTxs) {
      await _ledger.create(tx);
      final account = accountMap[tx.accountId];
      if (account != null) {
        await _accounts.update(_engine.applyBalanceChange(account, tx.debit, tx.credit).copyWith(
              version: account.version + 1,
              updatedAt: now,
              syncStatus: LocalSyncStatus.pending,
              isDirty: true,
            ));
      }
    }

    _engine.publishJournalPosted(journalEntryId: saved.id, tenantId: tenantId, storeId: saved.storeId);

    await _audit.log(
      action: AuditAction.create,
      entityType: JournalEntry.entityTypeName,
      tenantId: tenantId,
      storeId: saved.storeId,
      employeeId: user.employeeId,
      entityId: saved.id,
      metadata: {'entry_number': saved.entryNumber, 'source': saved.source.value},
    );

    return Success(saved);
  }

  Future<Result<JournalEntry>> createAutoJournal({
    required String tenantId,
    String? storeId,
    required JournalSource source,
    required String referenceType,
    required String referenceId,
    required List<JournalLine> lines,
    String? description,
  }) async {
    final validation = _engine.validateJournalLines(lines);
    if (validation.isFailure) return Error(validation.failureOrNull!);

    final numberResult = await _numbers.next(type: DocumentNumberType.journalEntry, tenantId: tenantId);
    if (numberResult.isFailure) return Error(numberResult.failureOrNull!);

    final now = DateTime.now().toUtc();
    final draft = JournalEntry(
      id: _uuid.v4(),
      tenantId: tenantId,
      storeId: storeId,
      entryNumber: numberResult.dataOrNull!.value,
      entryDate: now,
      status: JournalStatus.draft,
      source: source,
      referenceType: referenceType,
      referenceId: referenceId,
      description: description,
      lines: lines,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );

    return postJournal(
      user: AuthUser(
        userId: 'system',
        employeeId: 'system',
        email: 'system@local',
        emailVerified: true,
        tenantId: tenantId,
        permissions: {JournalPermissions.post},
      ),
      draft: draft,
    );
  }
}

class JournalService {
  JournalService({
    required JournalRepository repository,
    required AccountingEngine engine,
    required AuditService audit,
    required PermissionEngine permissions,
  })  : _repo = repository,
        _engine = engine,
        _audit = audit,
        _permissions = permissions;

  final JournalRepository _repo;
  final AccountingEngine _engine;
  final AuditService _audit;
  final PermissionEngine _permissions;

  Future<Result<JournalEntry>> createDraft({required AuthUser user, required JournalEntry draft}) async {
    try {
      _permissions.require(user, JournalPermissions.create);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final validation = _engine.validateJournalLines(draft.lines);
    if (validation.isFailure) return Error(validation.failureOrNull!);
    final saved = await _repo.create(draft);
    await _audit.log(
      action: AuditAction.create,
      entityType: JournalEntry.entityTypeName,
      tenantId: saved.tenantId,
      employeeId: user.employeeId,
      entityId: saved.id,
    );
    return Success(saved);
  }

  Future<List<JournalEntry>> listPosted(String tenantId) =>
      _repo.listByStatus(tenantId, JournalStatus.posted);
}

class LedgerService {
  LedgerService({required LedgerRepository repository, required PermissionEngine permissions})
      : _repo = repository,
        _permissions = permissions;

  final LedgerRepository _repo;
  final PermissionEngine _permissions;

  Future<Result<List<LedgerTransaction>>> generalLedger({
    required AuthUser user,
    required String tenantId,
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      _permissions.require(user, LedgerPermissions.view);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final start = from ?? DateTime.utc(2000);
    final end = to ?? DateTime.now().toUtc();
    return Success(await _repo.listByDateRange(tenantId, start, end));
  }
}

class TrialBalanceService {
  TrialBalanceService({
    required AccountingRepository accounts,
    required LedgerRepository ledger,
    required AccountingEngine engine,
    required PermissionEngine permissions,
  })  : _accounts = accounts,
        _ledger = ledger,
        _engine = engine,
        _permissions = permissions;

  final AccountingRepository _accounts;
  final LedgerRepository _ledger;
  final AccountingEngine _engine;
  final PermissionEngine _permissions;

  Future<Result<TrialBalanceReport>> generate({required AuthUser user, required String tenantId}) async {
    try {
      _permissions.require(user, FinancialReportPermissions.financial);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final page = await _accounts.getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    final txs = await _ledger.listByDateRange(tenantId, DateTime.utc(2000), DateTime.now().toUtc());
    return Success(_engine.buildTrialBalance(page.items, txs));
  }
}

class FinancialReportService {
  FinancialReportService({
    required AccountingRepository accounts,
    required AccountingEngine engine,
    required PermissionEngine permissions,
  })  : _accounts = accounts,
        _engine = engine,
        _permissions = permissions;

  final AccountingRepository _accounts;
  final AccountingEngine _engine;
  final PermissionEngine _permissions;

  Future<Result<BalanceSheetReport>> balanceSheet({required AuthUser user, required String tenantId}) async {
    try {
      _permissions.require(user, FinancialReportPermissions.financial);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final page = await _accounts.getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return Success(_engine.buildBalanceSheet(page.items));
  }

  Future<Result<IncomeStatementReport>> incomeStatement({required AuthUser user, required String tenantId}) async {
    try {
      _permissions.require(user, FinancialReportPermissions.financial);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final page = await _accounts.getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return Success(_engine.buildIncomeStatement(page.items));
  }
}

class ClosingService {
  ClosingService({
    required CurrencyRepository currencyRepository,
    required AccountingEngine engine,
    required AuditService audit,
    required PermissionEngine permissions,
  })  : _currency = currencyRepository,
        _engine = engine,
        _audit = audit,
        _permissions = permissions;

  final CurrencyRepository _currency;
  final AccountingEngine _engine;
  final AuditService _audit;
  final PermissionEngine _permissions;

  Future<Result<FiscalPeriod>> closePeriod({required AuthUser user, required FiscalPeriod period}) async {
    try {
      _permissions.require(user, FiscalPermissions.close);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    _engine.publishFiscalClosed(fiscalPeriodId: period.id, tenantId: period.tenantId);
    await _audit.log(
      action: AuditAction.update,
      entityType: FiscalPeriod.entityTypeName,
      tenantId: period.tenantId,
      employeeId: user.employeeId,
      entityId: period.id,
    );
    return Success(period);
  }
}

class FiscalYearService {
  FiscalYearService({required CurrencyRepository repository}) : _repo = repository;

  final CurrencyRepository _repo;

  Future<FiscalYear?> currentYear(String tenantId) => _repo.findOpenFiscalYear(tenantId);

  Future<FiscalPeriod?> currentPeriod(String tenantId) =>
      _repo.findOpenPeriod(tenantId, DateTime.now().toUtc());
}

class ExchangeRateService {
  ExchangeRateService({required CurrencyRepository repository, required AccountingEngine engine})
      : _repo = repository,
        _engine = engine;

  final CurrencyRepository _repo;
  final AccountingEngine _engine;

  Future<double> convert(String tenantId, double amount, String from, String to, DateTime on) async {
    final rate = await _repo.findRate(tenantId, from, to, on);
    return _engine.convertAmount(amount, rate?.rate ?? 1);
  }
}

class BankService {
  BankService({
    required BankRepository repository,
    required AuditService audit,
    required PermissionEngine permissions,
    Uuid? uuid,
  })  : _repo = repository,
        _audit = audit,
        _permissions = permissions,
        _uuid = uuid ?? const Uuid();

  final BankRepository _repo;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final Uuid _uuid;

  Future<Result<BankTransaction>> recordTransaction({
    required AuthUser user,
    required BankTransaction transaction,
  }) async {
    try {
      _permissions.require(user, BankPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final saved = await _repo.createTransaction(transaction);
    await _audit.log(
      action: AuditAction.create,
      entityType: BankTransaction.entityTypeName,
      tenantId: saved.tenantId,
      employeeId: user.employeeId,
      entityId: saved.id,
    );
    return Success(saved);
  }
}

class ReconciliationService {
  ReconciliationService({
    required BankRepository repository,
    required AccountingEngine engine,
    required AuditService audit,
    required PermissionEngine permissions,
  })  : _repo = repository,
        _engine = engine,
        _audit = audit,
        _permissions = permissions;

  final BankRepository _repo;
  final AccountingEngine _engine;
  final AuditService _audit;
  final PermissionEngine _permissions;

  Future<Result<ReconciliationSession>> complete({
    required AuthUser user,
    required ReconciliationSession session,
  }) async {
    try {
      _permissions.require(user, BankPermissions.reconcile);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final saved = await _repo.createReconciliation(session);
    _engine.publishReconciliationCompleted(sessionId: saved.id, tenantId: saved.tenantId);
    await _audit.log(
      action: AuditAction.update,
      entityType: ReconciliationSession.entityTypeName,
      tenantId: saved.tenantId,
      employeeId: user.employeeId,
      entityId: saved.id,
    );
    return Success(saved);
  }
}

class PaymentTermService {
  PaymentTermService({required CurrencyRepository repository}) : _repo = repository;

  final CurrencyRepository _repo;

  Future<PaymentTerm?> find(String tenantId, String code) => _repo.findPaymentTerm(tenantId, code);
}
