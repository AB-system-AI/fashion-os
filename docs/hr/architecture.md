# HR Architecture

## Layers

```
UI → Riverpod → Services → Repositories → syncable_records (Drift) → SyncQueue → HrSyncProcessor → Supabase
```

Business rules live in **HREngine**. Widgets contain no business logic.

## Services

| Service | Responsibility |
|---------|----------------|
| `EmployeeService` | Employee CRUD, availability |
| `AttendanceService` | Clock in, history |
| `ShiftService` | Shift scheduling |
| `LeaveService` | Leave requests and approval |
| `PayrollService` | Calculate and approve payroll |
| `SalaryService` | Salary structures |
| `CommissionService` | POS sale commissions |
| `PerformanceService` | Performance reviews |
| `DocumentService` | Employee documents |
| `HrIntegrationService` | POS event hooks |

## Events published

- `AttendanceRecordedEvent`
- `PayrollCalculatedEvent`
- `PayrollApprovedEvent`
- `LeaveApprovedEvent`

## Cross-module integration

| Module | Integration |
|--------|-------------|
| POS | Sale created → employee availability; commissions from sales |
| Accounting | Payroll approved → salary expense / payroll liability journals |
| CRM | Performance metrics on reviews |
