# Depreciation

## Methods

| Method | Code | Calculation |
|--------|------|-------------|
| Straight-line | `straight_line` | (cost − salvage) / useful life |
| Declining balance | `declining_balance` | book value × (2 / useful life) |

## Posting

`DepreciationService.postPeriod` creates an `asset_depreciation` entry, updates asset book value, and optionally links a journal entry.

## Schedule preview

`DepreciationService.scheduleForAsset` returns projected periods without persisting.

## Permissions

Posting depreciation requires `depreciation.manage`.
