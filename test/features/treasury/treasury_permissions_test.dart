import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';

void main() {
  test('treasury permission codes are stable', () {
    expect(TreasuryPermissions.view, 'treasury.view');
    expect(TreasuryPermissions.manage, 'treasury.manage');
    expect(CashPermissions.manage, 'cash.manage');
    expect(TreasuryBankPermissions.manage, 'treasury.bank.manage');
    expect(ChequePermissions.manage, 'cheque.manage');
    expect(TransferPermissions.manage, 'transfer.manage');
    expect(ExpensePermissions.manage, 'expense.manage');
    expect(PaymentPermissions.manage, 'payment.manage');
    expect(TreasuryReceiptPermissions.manage, 'treasury.receipt.manage');
    expect(ReconciliationPermissions.manage, 'reconciliation.manage');
    expect(ForecastPermissions.view, 'forecast.view');
  });
}
