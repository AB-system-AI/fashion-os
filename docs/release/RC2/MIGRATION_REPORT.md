# Migration Report — RC2

**Date:** 2026-07-14

## Full Migration Inventory

| # | File | Phase | Scope |
|---|------|-------|-------|
| 01–12 | `20250712000001` – `000012` | 1–13 | Auth through Sales OMS |
| 13 | `20250712000013_automation_enterprise.sql` | 14 | 11 tables |
| 14 | `20250712000014_integrations_enterprise.sql` | 15 | 8 tables |
| 15 | `20250712000015_system_security_enterprise.sql` | 16 | 19 tables |
| **16** | **`20250712000016_treasury_enterprise.sql`** | **Treasury** | **Banks, accounts, vouchers, cheques** |
| **17** | **`20250712000017_assets_enterprise.sql`** | **Assets** | **Register, depreciation, maintenance** |
| **18** | **`20250712000018_workflow_enterprise.sql`** | **Workflow** | **Approvals, notifications, templates** |

## RC2 New Tables (Migrations 16–18)

### Treasury (~12 tables)
treasury_banks, treasury_bank_accounts, treasury_cash_accounts, treasury_vouchers, treasury_payments, treasury_receipts, treasury_transfers, treasury_expenses, treasury_cheques, treasury_reconciliations, treasury_forecasts, treasury_settings

### Assets (~14 tables)
asset_categories, assets, asset_transfers, asset_maintenance_requests, asset_maintenance_schedules, asset_depreciation_schedules, asset_depreciation_entries, asset_disposals, asset_contracts, asset_audits, asset_settings, ...

### Workflow (~8 tables)
workflow_instances, approval_requests, approval_steps, approval_templates, escalation_rules, notifications, notification_preferences, workflow_settings

## RLS Policy Pattern

All tables use tenant-scoped RLS:
```sql
CREATE POLICY tenant_isolation ON public.{table}
  FOR ALL USING (tenant_id = auth.jwt() ->> 'tenant_id');
```

## Permission Seed Migration (RC2)

Existing tenants with legacy codes must map:

| Legacy | RC2 |
|--------|-----|
| `maintenance.manage` (manufacturing) | `manufacturing.maintenance.manage` |
| `maintenance.manage` (system) | `system.maintenance.manage` |
| `maintenance.view/manage` (assets) | `assets.maintenance.view/manage` |
| `bank.manage` (treasury ops) | `treasury.bank.manage` |
| `receipt.manage` (treasury ops) | `treasury.receipt.manage` |

## Apply Migrations

```bash
supabase db push
```

## Rollback Strategy

- Forward-only migrations
- Soft delete enables data recovery
- `migration_history_entries` tracks applied migrations
