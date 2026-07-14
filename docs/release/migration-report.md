# Migration Report — RC1

## Migration Inventory

| # | File | Phase | Tables |
|---|------|-------|--------|
| 01 | `20250712000001_auth_enterprise.sql` | 1 | Auth, tenants, users |
| 02 | `20250712000002_performance_indexes.sql` | 2 | Indexes |
| 03 | `20250712000003_inventory_warehouse.sql` | 3 | Inventory |
| 04 | `20250712000004_purchasing_enterprise.sql` | 4 | Purchasing |
| 05 | `20250712000005_customers_crm_enterprise.sql` | 5 | CRM |
| 06 | `20250712000006_sales_pos_enterprise.sql` | 6 | POS |
| 07 | `20250712000007_accounting_enterprise.sql` | 7 | Accounting |
| 08 | `20250712000008_hr_payroll_enterprise.sql` | 8 | HR |
| 09 | `20250712000009_manufacturing_enterprise.sql` | 9 | Manufacturing |
| 10 | `20250712000010_manufacturing_hardening.sql` | 10 | Mfg hardening |
| 11 | `20250712000011_reporting_analytics_enterprise.sql` | 12 | Analytics |
| 12 | `20250712000012_sales_orders_enterprise.sql` | 13 | Sales OMS |
| 13 | `20250712000013_automation_enterprise.sql` | **14** | **11 tables** |
| 14 | `20250712000014_integrations_enterprise.sql` | **15** | **8 tables** |
| 15 | `20250712000015_system_security_enterprise.sql` | **16** | **19 tables** |

## New Tables (Phases 14–16): 38

### Automation (11)
automation_rules, automation_workflows, workflow_steps, scheduled_jobs, job_queue, automation_executions, automation_logs, approval_workflows, approval_requests, document_templates, automation_settings

### Integrations (8)
integration_connectors, webhooks, api_keys, integration_logs, import_jobs, export_jobs, oauth_connections, printer_profiles

### System (19)
feature_flags, system_audit_entries, role_definitions, permission_assignments, system_health_snapshots, error_log_entries, background_job_status, sync_monitor_snapshots, storage_usage_snapshots, license_records, subscription_records, environment_settings, security_sessions, device_registrations, login_history_entries, maintenance_mode, system_configuration, release_notes, migration_history_entries

## RLS Policy Pattern

All new tables use tenant-scoped RLS:
```sql
CREATE POLICY tenant_isolation ON public.{table}
  FOR ALL USING (tenant_id = auth.jwt() ->> 'tenant_id');
```

## Apply Migrations

```bash
supabase db push
# or
supabase migration up
```

## Rollback Strategy

- Migrations are forward-only
- Soft delete (`deleted_at`) enables data recovery without schema rollback
- `migration_history_entries` table tracks applied migrations per tenant
