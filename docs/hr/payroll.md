# Payroll

## Calculation flow

1. `PayrollService.calculateRun` loads active employees.
2. `HREngine.calculatePayroll` per employee: base + allowances + bonuses + commissions + overtime − deductions − tax.
3. Payroll items persisted per line type.
4. `PayrollCalculatedEvent` published.
5. `PayrollService.approve` requires `payroll.approve` permission.
6. `PayrollApprovedEvent` triggers accounting auto-journal.

## Document numbers

Payroll runs use `PR-` prefix via `DocumentNumberType.payrollRun`.

## Accounting journals (auto)

On `payroll.approved`:

- Debit Salaries Expense (6100)
- Credit Payroll Payable (2300)
- Credit Payroll Tax Payable (2110)

Configured in `AccountingIntegrationService` and `AccountingEngine.payrollApprovedLines`.
