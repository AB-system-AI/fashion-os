import 'package:fashion_pos_enterprise/core/infrastructure/pagination/paginated_result.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/base_local_repository.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/entities/accounts.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/entities/cheques.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/entities/expenses.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/entities/forecast.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/entities/movements.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/entities/vouchers.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/enums/treasury_enums.dart';

abstract class CashBoxRepository implements BaseLocalRepository<CashBox> {
  Future<List<CashBox>> listByStore(String tenantId, String? storeId);
}

abstract class BankRepository implements BaseLocalRepository<Bank> {
  Future<List<Bank>> listActive(String tenantId);
}

abstract class BankAccountRepository implements BaseLocalRepository<BankAccount> {
  Future<List<BankAccount>> listByBank(String tenantId, String bankId);
  Future<List<BankAccount>> listActive(String tenantId);
}

abstract class PettyCashRepository implements BaseLocalRepository<PettyCash> {}

abstract class TransferRepository implements BaseLocalRepository<Transfer> {
  Future<List<Transfer>> listByStatus(String tenantId, TransferStatus status);
}

abstract class ChequeRepository implements BaseLocalRepository<Cheque> {
  Future<List<Cheque>> listByStatus(String tenantId, ChequeStatus status);
}

abstract class ChequeBookRepository implements BaseLocalRepository<ChequeBook> {
  Future<List<ChequeBook>> listByBankAccount(String tenantId, String bankAccountId);
}

abstract class PaymentVoucherRepository implements BaseLocalRepository<PaymentVoucher> {
  Future<List<PaymentVoucher>> listByStatus(String tenantId, VoucherStatus status);
}

abstract class ReceiptVoucherRepository implements BaseLocalRepository<ReceiptVoucher> {
  Future<List<ReceiptVoucher>> listByStatus(String tenantId, VoucherStatus status);
}

abstract class ExpenseRequestRepository implements BaseLocalRepository<ExpenseRequest> {
  Future<List<ExpenseRequest>> listByStatus(String tenantId, ExpenseRequestStatus status);
}

abstract class ExpenseApprovalRepository implements BaseLocalRepository<ExpenseApproval> {
  Future<List<ExpenseApproval>> listByRequest(String tenantId, String expenseRequestId);
}

abstract class CashForecastRepository implements BaseLocalRepository<CashForecast> {
  Future<List<CashForecast>> listByPeriod(String tenantId, ForecastPeriod period);
}

abstract class BankReconciliationRepository implements BaseLocalRepository<BankReconciliation> {
  Future<List<BankReconciliation>> listByBankAccount(String tenantId, String bankAccountId);
  Future<List<BankReconciliation>> listByStatus(String tenantId, ReconciliationStatus status);
}

abstract class TreasurySettingsRepository implements BaseLocalRepository<TreasurySettings> {
  Future<TreasurySettings?> getSettings(String tenantId);
  Future<TreasurySettings> saveSettings(TreasurySettings settings);
}

abstract class CashMovementRepository implements BaseLocalRepository<CashMovement> {
  Future<List<CashMovement>> listByCashBox(String tenantId, String cashBoxId);
}

abstract class BankMovementRepository implements BaseLocalRepository<BankMovement> {
  Future<List<BankMovement>> listByBankAccount(String tenantId, String bankAccountId);
}

abstract class TreasuryAccountRepository implements BaseLocalRepository<TreasuryAccount> {}
