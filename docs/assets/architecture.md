# Assets Architecture

## Layers

```
presentation/     → pages, providers, routes
domain/           → entities, repositories, services, integration
data/             → repository impl, remote datasource, sync processors
core/business/    → AssetsEngine (pure logic)
```

## Engine

**AssetsEngine** — lifecycle transitions, depreciation schedules, transfer/disposal validation, maintenance costing, warranty checks, utilization KPIs, domain events.

## Entity types (sync)

`asset`, `asset_category`, `asset_location`, `asset_depreciation`, `asset_transfer`, `asset_disposal`, `maintenance_request`, `maintenance_schedule`, `maintenance_task`, `maintenance_cost`, `service_contract`, `warranty`, `asset_audit`, `asset_settings`

## Permissions

| Group | Codes |
|-------|-------|
| AssetsPermissions | `assets.view`, `assets.manage` |
| AssetMaintenancePermissions | `assets.maintenance.view`, `assets.maintenance.manage` |
| DepreciationPermissions | `depreciation.manage` |
| DisposalPermissions | `disposal.manage` |

## Cross-module integration

`AssetIntegrationService` subscribes to `asset.disposed` and `asset.transferred` for accounting, manufacturing, and analytics audit hooks.
