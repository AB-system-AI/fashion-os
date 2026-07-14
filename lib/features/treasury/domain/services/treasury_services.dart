import 'package:uuid/uuid.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_action.dart';
import 'package:fashion_pos_enterprise/core/audit/audit_service.dart';
import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/business/engines/number_generator_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/treasury/treasury_engine.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/pagination/paginated_result.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_engine.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/entities/accounts.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/entities/cheques.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/entities/expenses.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/entities/forecast.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/entities/movements.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/entities/vouchers.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/enums/treasury_enums.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/repositories/treasury_repositories.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/value_objects/treasury_value_objects.dart';

class CashService {
  CashService({
    required CashBoxRepository repository,
    required CashMovementRepository movements,
    required TreasuryEngine engine,
    required AuditService audit,
    required PermissionEngine permissions,
    Uuid? uuid,
  })  : _repo = repository,
        _movements = movements,
        _engine = engine,
        _audit = audit,
        _permissions = permissions,
        _uuid = uuid ?? const Uuid();

  final CashBoxRepository _repo;
  final CashMovementRepository _movements;
  final TreasuryEngine _engine;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final Uuid _uuid;

  Future<Result<CashBox>> createBox({required AuthUser user, required String name, String? storeId}) async {
    try {
      _permissions.require(user, CashPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final now = DateTime.now().toUtc();
    final box = await _repo.create(CashBox(
      id: _uuid.v4(),
      tenantId: user.tenantId!,
      name: name,
      storeId: storeId,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    await _audit.log(action: AuditAction.create, entityType: CashBox.entityTypeName, tenantId: box.tenantId, employeeId: user.employeeId, entityId: box.id);
    return Success(box);
  }

  Future<PaginatedResult<CashBox>> list(String tenantId) => _repo.getPage(RepositoryQuery(tenantId: tenantId, pageSize: 200));

  Future<Result<CashMovement>> recordMovement({
    required AuthUser user,
    required String cashBoxId,
    required MovementDirection direction,
    required double amount,
    String? reference,
  }) async {
    try {
      _permissions.require(user, CashPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final box = await _repo.getById(cashBoxId);
    if (box == null) return const Error(ValidationFailure(message: 'Cash box not found', code: 'not_found'));
    final delta = direction == MovementDirection.inflow ? amount : -amount;
    final now = DateTime.now().toUtc();
    final movement = await _movements.create(CashMovement(
      id: _uuid.v4(),
      tenantId: user.tenantId!,
      cashBoxId: cashBoxId,
      direction: direction,
      amount: amount,
      reference: reference,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    await _repo.update(box.copyWith(
      balance: box.balance + delta,
      version: box.version + 1,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    return Success(movement);
  }
}

class BankService {
  BankService({
    required BankRepository banks,
    required BankAccountRepository accounts,
    required BankMovementRepository movements,
    required TreasuryEngine engine,
    required AuditService audit,
    required PermissionEngine permissions,
    Uuid? uuid,
  })  : _banks = banks,
        _accounts = accounts,
        _movements = movements,
        _engine = engine,
        _audit = audit,
        _permissions = permissions,
        _uuid = uuid ?? const Uuid();

  final BankRepository _banks;
  final BankAccountRepository _accounts;
  final BankMovementRepository _movements;
  final TreasuryEngine _engine;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final Uuid _uuid;

  Future<Result<Bank>> createBank({required AuthUser user, required String name, String? code}) async {
    try {
      _permissions.require(user, TreasuryBankPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final now = DateTime.now().toUtc();
    final bank = await _banks.create(Bank(
      id: _uuid.v4(),
      tenantId: user.tenantId!,
      name: name,
      code: code,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    await _audit.log(action: AuditAction.create, entityType: Bank.entityTypeName, tenantId: bank.tenantId, employeeId: user.employeeId, entityId: bank.id);
    return Success(bank);
  }

  Future<Result<BankAccount>> createAccount({
    required AuthUser user,
    required String bankId,
    required String accountNumber,
    double interestRate = 0,
  }) async {
    try {
      _permissions.require(user, TreasuryBankPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final now = DateTime.now().toUtc();
    final account = await _accounts.create(BankAccount(
      id: _uuid.v4(),
      tenantId: user.tenantId!,
      bankId: bankId,
      accountNumber: accountNumber,
      interestRate: interestRate,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    return Success(account);
  }

  Future<PaginatedResult<Bank>> listBanks(String tenantId) => _banks.getPage(RepositoryQuery(tenantId: tenantId, pageSize: 200));

  Future<PaginatedResult<BankAccount>> listAccounts(String tenantId) => _accounts.getPage(RepositoryQuery(tenantId: tenantId, pageSize: 200));

  InterestCalculation calculateInterest({required double principal, required double annualRate, required int days}) =>
      _engine.calculateInterest(principal: principal, annualRate: annualRate, days: days);
}

class TransferService {
  TransferService({
    required TransferRepository repository,
    required TreasuryEngine engine,
    required AuditService audit,
    required PermissionEngine permissions,
    required NumberGeneratorEngine numberGenerator,
    Uuid? uuid,
  })  : _repo = repository,
        _engine = engine,
        _audit = audit,
        _permissions = permissions,
        _numbers = numberGenerator,
        _uuid = uuid ?? const Uuid();

  final TransferRepository _repo;
  final TreasuryEngine _engine;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final NumberGeneratorEngine _numbers;
  final Uuid _uuid;

  Future<Result<Transfer>> create({required AuthUser user, required TransferInput input, required double fromBalance}) async {
    try {
      _permissions.require(user, TransferPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final validation = _engine.validateTransfer(input: input, fromBalance: fromBalance);
    if (!validation.isValid) {
      return Error(ValidationFailure(message: validation.errors.join('; '), code: 'validation_failed'));
    }
    final number = await _numbers.next(type: DocumentNumberType.transfer, tenantId: user.tenantId!);
    if (number.isFailure) return Error(number.failureOrNull!);
    final now = DateTime.now().toUtc();
    final transfer = await _repo.create(Transfer(
      id: _uuid.v4(),
      tenantId: user.tenantId!,
      transferNumber: number.dataOrNull!.value,
      fromAccountId: input.fromAccountId,
      toAccountId: input.toAccountId,
      amount: input.amount,
      currencyCode: input.currencyCode,
      exchangeRate: input.exchangeRate,
      notes: input.notes,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    await _audit.log(action: AuditAction.create, entityType: Transfer.entityTypeName, tenantId: transfer.tenantId, employeeId: user.employeeId, entityId: transfer.id);
    return Success(transfer);
  }

  Future<Result<Transfer>> complete({required AuthUser user, required Transfer transfer}) async {
    if (!_engine.canTransitionTransfer(transfer.status, TransferStatus.completed)) {
      return const Error(ValidationFailure(message: 'Invalid transfer transition', code: 'invalid_transition'));
    }
    final now = DateTime.now().toUtc();
    final saved = await _repo.update(transfer.copyWith(
      status: TransferStatus.completed,
      version: transfer.version + 1,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    return Success(saved);
  }

  Future<PaginatedResult<Transfer>> list(String tenantId) => _repo.getPage(RepositoryQuery(tenantId: tenantId, pageSize: 200));
}

class ChequeService {
  ChequeService({
    required ChequeRepository repository,
    required TreasuryEngine engine,
    required AuditService audit,
    required PermissionEngine permissions,
    required NumberGeneratorEngine numberGenerator,
    Uuid? uuid,
  })  : _repo = repository,
        _engine = engine,
        _audit = audit,
        _permissions = permissions,
        _numbers = numberGenerator,
        _uuid = uuid ?? const Uuid();

  final ChequeRepository _repo;
  final TreasuryEngine _engine;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final NumberGeneratorEngine _numbers;
  final Uuid _uuid;

  Future<Result<Cheque>> issue({
    required AuthUser user,
    required String bankAccountId,
    required double amount,
    required String payee,
  }) async {
    try {
      _permissions.require(user, ChequePermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final number = await _numbers.next(type: DocumentNumberType.cheque, tenantId: user.tenantId!);
    if (number.isFailure) return Error(number.failureOrNull!);
    final now = DateTime.now().toUtc();
    final cheque = await _repo.create(Cheque(
      id: _uuid.v4(),
      tenantId: user.tenantId!,
      chequeNumber: number.dataOrNull!.value,
      bankAccountId: bankAccountId,
      amount: amount,
      payee: payee,
      issueDate: now,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    return Success(cheque);
  }

  Future<Result<Cheque>> transition({required AuthUser user, required Cheque cheque, required ChequeStatus to}) async {
    final check = _engine.canTransitionCheque(cheque.status, to);
    if (!check.allowed) return Error(ValidationFailure(message: check.reason ?? 'Invalid transition', code: 'invalid_transition'));
    final now = DateTime.now().toUtc();
    final saved = await _repo.update(cheque.copyWith(status: to, version: cheque.version + 1, updatedAt: now, syncStatus: LocalSyncStatus.pending, isDirty: true));
    return Success(saved);
  }

  Future<PaginatedResult<Cheque>> list(String tenantId) => _repo.getPage(RepositoryQuery(tenantId: tenantId, pageSize: 200));
}

class PaymentService {
  PaymentService({
    required PaymentVoucherRepository repository,
    required TreasuryEngine engine,
    required AuditService audit,
    required PermissionEngine permissions,
    required NumberGeneratorEngine numberGenerator,
    Uuid? uuid,
  })  : _repo = repository,
        _engine = engine,
        _audit = audit,
        _permissions = permissions,
        _numbers = numberGenerator,
        _uuid = uuid ?? const Uuid();

  final PaymentVoucherRepository _repo;
  final TreasuryEngine _engine;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final NumberGeneratorEngine _numbers;
  final Uuid _uuid;

  Future<Result<PaymentVoucher>> create({required AuthUser user, required PaymentInput input}) async {
    try {
      _permissions.require(user, PaymentPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final number = await _numbers.next(type: DocumentNumberType.paymentVoucher, tenantId: user.tenantId!);
    if (number.isFailure) return Error(number.failureOrNull!);
    final now = DateTime.now().toUtc();
    final voucher = await _repo.create(PaymentVoucher(
      id: _uuid.v4(),
      tenantId: user.tenantId!,
      voucherNumber: number.dataOrNull!.value,
      payeeName: input.payeeName,
      amount: input.amount,
      accountId: input.accountId,
      currencyCode: input.currencyCode,
      reference: input.reference,
      notes: input.notes,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    return Success(voucher);
  }

  Future<PaginatedResult<PaymentVoucher>> list(String tenantId) => _repo.getPage(RepositoryQuery(tenantId: tenantId, pageSize: 200));
}

class ReceiptService {
  ReceiptService({
    required ReceiptVoucherRepository repository,
    required TreasuryEngine engine,
    required AuditService audit,
    required PermissionEngine permissions,
    required NumberGeneratorEngine numberGenerator,
    Uuid? uuid,
  })  : _repo = repository,
        _engine = engine,
        _audit = audit,
        _permissions = permissions,
        _numbers = numberGenerator,
        _uuid = uuid ?? const Uuid();

  final ReceiptVoucherRepository _repo;
  final TreasuryEngine _engine;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final NumberGeneratorEngine _numbers;
  final Uuid _uuid;

  Future<Result<ReceiptVoucher>> create({required AuthUser user, required ReceiptInput input}) async {
    try {
      _permissions.require(user, TreasuryReceiptPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final number = await _numbers.next(type: DocumentNumberType.receiptVoucher, tenantId: user.tenantId!);
    if (number.isFailure) return Error(number.failureOrNull!);
    final now = DateTime.now().toUtc();
    final voucher = await _repo.create(ReceiptVoucher(
      id: _uuid.v4(),
      tenantId: user.tenantId!,
      voucherNumber: number.dataOrNull!.value,
      payerName: input.payerName,
      amount: input.amount,
      accountId: input.accountId,
      currencyCode: input.currencyCode,
      reference: input.reference,
      notes: input.notes,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    return Success(voucher);
  }

  Future<PaginatedResult<ReceiptVoucher>> list(String tenantId) => _repo.getPage(RepositoryQuery(tenantId: tenantId, pageSize: 200));
}

class ExpenseService {
  ExpenseService({
    required ExpenseRequestRepository repository,
    required ExpenseApprovalRepository approvals,
    required TreasurySettingsRepository settings,
    required TreasuryEngine engine,
    required AuditService audit,
    required PermissionEngine permissions,
    required NumberGeneratorEngine numberGenerator,
    Uuid? uuid,
  })  : _repo = repository,
        _approvals = approvals,
        _settings = settings,
        _engine = engine,
        _audit = audit,
        _permissions = permissions,
        _numbers = numberGenerator,
        _uuid = uuid ?? const Uuid();

  final ExpenseRequestRepository _repo;
  final ExpenseApprovalRepository _approvals;
  final TreasurySettingsRepository _settings;
  final TreasuryEngine _engine;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final NumberGeneratorEngine _numbers;
  final Uuid _uuid;

  Future<Result<ExpenseRequest>> create({required AuthUser user, required ExpenseInput input}) async {
    try {
      _permissions.require(user, ExpensePermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final number = await _numbers.next(type: DocumentNumberType.expenseRequest, tenantId: user.tenantId!);
    if (number.isFailure) return Error(number.failureOrNull!);
    final now = DateTime.now().toUtc();
    final request = await _repo.create(ExpenseRequest(
      id: _uuid.v4(),
      tenantId: user.tenantId!,
      requestNumber: number.dataOrNull!.value,
      description: input.description,
      amount: input.amount,
      category: input.category,
      requestedBy: user.employeeId ?? user.id,
      departmentId: input.departmentId,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    return Success(request);
  }

  Future<Result<ExpenseRequest>> submit({required AuthUser user, required ExpenseRequest request}) async {
    if (!_engine.canTransitionExpense(request.status, ExpenseRequestStatus.submitted)) {
      return const Error(ValidationFailure(message: 'Invalid expense transition', code: 'invalid_transition'));
    }
    final settings = await _settings.getSettings(user.tenantId!);
    final threshold = settings?.expenseApprovalThreshold ?? 500;
    final now = DateTime.now().toUtc();
    final status = _engine.requiresExpenseApproval(amount: request.amount, threshold: threshold)
        ? ExpenseRequestStatus.submitted
        : ExpenseRequestStatus.approved;
    final saved = await _repo.update(request.copyWith(status: status, version: request.version + 1, updatedAt: now, syncStatus: LocalSyncStatus.pending, isDirty: true));
    return Success(saved);
  }

  Future<PaginatedResult<ExpenseRequest>> list(String tenantId) => _repo.getPage(RepositoryQuery(tenantId: tenantId, pageSize: 200));
}

class ReconciliationService {
  ReconciliationService({
    required BankReconciliationRepository repository,
    required BankAccountRepository accounts,
    required TreasuryEngine engine,
    required AuditService audit,
    required PermissionEngine permissions,
    Uuid? uuid,
  })  : _repo = repository,
        _accounts = accounts,
        _engine = engine,
        _audit = audit,
        _permissions = permissions,
        _uuid = uuid ?? const Uuid();

  final BankReconciliationRepository _repo;
  final BankAccountRepository _accounts;
  final TreasuryEngine _engine;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final Uuid _uuid;

  Future<Result<BankReconciliation>> start({
    required AuthUser user,
    required String bankAccountId,
    required DateTime statementDate,
    required double statementBalance,
    List<ReconciliationLineInput> lines = const [],
  }) async {
    try {
      _permissions.require(user, ReconciliationPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final account = await _accounts.getById(bankAccountId);
    if (account == null) return const Error(ValidationFailure(message: 'Bank account not found', code: 'not_found'));
    final result = _engine.reconcile(bookBalance: account.balance, statementBalance: statementBalance, lines: lines);
    final now = DateTime.now().toUtc();
    final recon = await _repo.create(BankReconciliation(
      id: _uuid.v4(),
      tenantId: user.tenantId!,
      bankAccountId: bankAccountId,
      statementDate: statementDate,
      bookBalance: account.balance,
      statementBalance: statementBalance,
      variance: result.variance,
      status: result.isBalanced ? ReconciliationStatus.balanced : ReconciliationStatus.unbalanced,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    return Success(recon);
  }

  Future<PaginatedResult<BankReconciliation>> list(String tenantId) => _repo.getPage(RepositoryQuery(tenantId: tenantId, pageSize: 200));
}

class ForecastService {
  ForecastService({
    required CashForecastRepository repository,
    required CashBoxRepository cashBoxes,
    required BankAccountRepository bankAccounts,
    required PettyCashRepository pettyCash,
    required TreasuryEngine engine,
    required PermissionEngine permissions,
    Uuid? uuid,
  })  : _repo = repository,
        _cashBoxes = cashBoxes,
        _bankAccounts = bankAccounts,
        _pettyCash = pettyCash,
        _engine = engine,
        _permissions = permissions,
        _uuid = uuid ?? const Uuid();

  final CashForecastRepository _repo;
  final CashBoxRepository _cashBoxes;
  final BankAccountRepository _bankAccounts;
  final PettyCashRepository _pettyCash;
  final TreasuryEngine _engine;
  final PermissionEngine _permissions;
  final Uuid _uuid;

  Future<Result<List<ForecastPoint>>> generate({
    required AuthUser user,
    required double openingBalance,
    required List<({DateTime date, double inflow, double outflow})> periods,
  }) async {
    try {
      _permissions.require(user, ForecastPermissions.view);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    return Success(_engine.buildCashForecast(openingBalance: openingBalance, periods: periods));
  }

  Future<LiquiditySnapshot> liquiditySnapshot(String tenantId) async {
    final cashPage = await _cashBoxes.getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    final bankPage = await _bankAccounts.getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    final pettyPage = await _pettyCash.getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return _engine.calculateLiquidity(
      cashBalance: cashPage.items.fold(0.0, (s, b) => s + b.balance),
      bankBalance: bankPage.items.fold(0.0, (s, b) => s + b.balance),
      pettyCashBalance: pettyPage.items.fold(0.0, (s, p) => s + p.balance),
    );
  }

  Future<PaginatedResult<CashForecast>> list(String tenantId) => _repo.getPage(RepositoryQuery(tenantId: tenantId, pageSize: 200));
}

class TreasuryDashboardService {
  TreasuryDashboardService({
    required CashBoxRepository cashBoxes,
    required BankAccountRepository bankAccounts,
    required PaymentVoucherRepository payments,
    required ReceiptVoucherRepository receipts,
    required ChequeRepository cheques,
    required TreasuryEngine engine,
    required PermissionEngine permissions,
  })  : _cashBoxes = cashBoxes,
        _bankAccounts = bankAccounts,
        _payments = payments,
        _receipts = receipts,
        _cheques = cheques,
        _engine = engine,
        _permissions = permissions;

  final CashBoxRepository _cashBoxes;
  final BankAccountRepository _bankAccounts;
  final PaymentVoucherRepository _payments;
  final ReceiptVoucherRepository _receipts;
  final ChequeRepository _cheques;
  final TreasuryEngine _engine;
  final PermissionEngine _permissions;

  Future<TreasuryKpis> kpis(String tenantId) async {
    final cashPage = await _cashBoxes.getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    final bankPage = await _bankAccounts.getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    final paymentPage = await _payments.getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    final receiptPage = await _receipts.getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    final chequePage = await _cheques.getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    final cashOnHand = cashPage.items.fold(0.0, (s, b) => s + b.balance);
    final bankBalance = bankPage.items.fold(0.0, (s, b) => s + b.balance);
    final pendingPayments = paymentPage.items.where((p) => p.status != VoucherStatus.posted).fold(0.0, (s, p) => s + p.amount);
    final pendingReceipts = receiptPage.items.where((r) => r.status != VoucherStatus.posted).fold(0.0, (s, r) => s + r.amount);
    final uncleared = chequePage.items.where((c) => c.status != ChequeStatus.cleared).fold(0.0, (s, c) => s + c.amount);
    return _engine.calculateKpis(
      cashOnHand: cashOnHand,
      bankBalance: bankBalance,
      pendingPayments: pendingPayments,
      pendingReceipts: pendingReceipts,
      unclearedCheques: uncleared,
      currentLiabilities: pendingPayments,
    );
  }
}
