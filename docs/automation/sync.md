# Automation Sync

## Processors

11 `AutomationSyncProcessor` instances registered in `automationModuleInitializerProvider`:

| Entity | Remote table |
|--------|--------------|
| automation_rule | automation_rules |
| automation_workflow | automation_workflows |
| workflow_step | workflow_steps |
| scheduled_job | scheduled_jobs |
| job_queue_item | job_queue |
| automation_execution | automation_executions |
| automation_log | automation_logs |
| approval_workflow | approval_workflows |
| approval_request | approval_requests |
| document_template | document_templates |
| automation_settings | automation_settings |

## Pattern

Follows `SalesSyncProcessor`: push via `AutomationRemoteDataSource`, pull delta by `updated_at`, tenant-scoped RLS on Supabase.

## Offline-first

Local SQLite via `AutomationRepositoryImpl` + `SyncQueueWriter`; dirty records sync on connectivity restore.
