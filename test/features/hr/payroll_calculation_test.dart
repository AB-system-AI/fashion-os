import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/business/engines/hr/hr_engine.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/features/hr/domain/entities/payroll.dart';

void main() {
  final engine = HREngine();

  test('calculateLeaveDeduction prorates unpaid days', () {
    final deduction = engine.calculateLeaveDeduction(baseSalary: 2200, leaveDays: 2);
    expect(deduction, 200);
  });

  test('validatePayrollRun accepts matching totals', () {
    final lines = [
      engine.calculatePayroll(const PayrollLineInput(employeeId: 'e1', baseSalary: 1000, taxRate: 0.1)),
      engine.calculatePayroll(const PayrollLineInput(employeeId: 'e2', baseSalary: 2000, taxRate: 0.1)),
    ];
    final run = PayrollRun(
      id: 'r1',
      tenantId: 't1',
      payrollPeriodId: 'p1',
      runNumber: 'PR-000001',
      totalGross: 3000,
      totalDeductions: 0,
      totalTax: 300,
      totalNet: 2700,
      version: 1,
      createdAt: DateTime.utc(2025),
      updatedAt: DateTime.utc(2025),
      syncStatus: LocalSyncStatus.synced,
      isDirty: false,
    );
    expect(engine.validatePayrollRun(run, lines).isSuccess, isTrue);
  });
}
