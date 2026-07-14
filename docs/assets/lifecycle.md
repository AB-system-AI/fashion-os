# Asset Lifecycle

## Status flow

```
active ↔ idle ↔ in_maintenance
   ↓         ↓
transferred  disposed
```

## Operations

| Operation | Service | Permission |
|-----------|---------|------------|
| Register asset | `AssetService.create` | `assets.manage` |
| Transfer | `TransferService` | `assets.manage` |
| Dispose | `DisposalService` | `disposal.manage` |
| Depreciate | `DepreciationService.postPeriod` | `depreciation.manage` |

## Events

- `asset.transferred` — location change, manufacturing/analytics audit
- `asset.disposed` — gain/loss, accounting/analytics audit
