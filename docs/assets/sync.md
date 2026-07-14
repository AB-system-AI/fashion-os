# Assets Sync

## Processors

All processors extend `AssetsSyncProcessor` with entity-specific typedefs:

- `AssetSyncProcessor`
- `MaintenanceSyncProcessor`
- `DepreciationSyncProcessor`
- `DisposalSyncProcessor`

## Remote tables

| Entity | Table |
|--------|-------|
| asset | `assets` |
| asset_category | `asset_categories` |
| asset_location | `asset_locations` |
| asset_depreciation | `asset_depreciation` |
| asset_transfer | `asset_transfers` |
| asset_disposal | `asset_disposals` |
| maintenance_request | `maintenance_requests` |
| maintenance_schedule | `maintenance_schedules` |
| maintenance_task | `maintenance_tasks` |
| maintenance_cost | `maintenance_costs` |
| service_contract | `service_contracts` |
| warranty | `warranties` |
| asset_audit | `asset_audits` |
| asset_settings | `asset_settings` |

## Migration

`supabase/migrations/20250712000017_assets_enterprise.sql` — 14 tables with tenant-scoped RLS.
