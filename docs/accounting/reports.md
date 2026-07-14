# Financial Reports

## Engine reports

`AccountingEngine` generates:

- **Trial balance** — debits and credits per account from ledger transactions
- **Balance sheet** — assets, liabilities, equity from account balances
- **Income statement** — revenue, COGS, expenses, net income

## Application services

- `TrialBalanceService` — loads accounts + ledger, delegates to engine
- `FinancialReportService` — balance sheet and income statement

## UI reports (dashboard routes)

| Route | Report |
|-------|--------|
| `/accounting/trial-balance` | Trial Balance |
| `/accounting/balance-sheet` | Balance Sheet |
| `/accounting/income-statement` | Income Statement |
| `/accounting/cash-flow` | Cash Flow (scaffold) |
| `/accounting/reports` | Export hub (PDF/Excel/CSV planned) |

## Planned exports

Reports hub will support PDF, Excel, and CSV export via shared export infrastructure. Additional reports:

- General Ledger
- Journal Report
- Tax / VAT Report
- Customer Balance
- Supplier Balance
- Cash Report
- Bank Report

## Permissions

- `reports.financial` — trial balance, balance sheet, income statement, general reports
- `reports.tax` — tax configuration and tax reports
