# HR Sync

Processors registered in `hrModuleInitializerProvider`:

| Processor | Entity type | Remote table |
|-----------|-------------|--------------|
| EmployeeSyncProcessor | `employee` | `employees` |
| AttendanceSyncProcessor | `attendance_record` | `attendance_records` |
| PayrollSyncProcessor | `payroll_run` | `payroll_runs` |
| LeaveSyncProcessor | `leave_request` | `leave_requests` |

Migration: `20250712000008_hr_payroll_enterprise.sql`

## Offline behavior

Every mutation writes to `syncable_records` and enqueues sync. Failed items remain in queue for manual retry.
