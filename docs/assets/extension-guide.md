# Assets Module — Extension Guide

## Adding a New Asset Type

1. Extend `AssetType` in `domain/enums/assets_enums.dart`
2. Add validation rules in `AssetsEngine`
3. Update `asset.dart` entity payload mapping if new fields required
4. Add Supabase column via forward migration (do not edit `20250712000017`)

## Accounting Auto-Posting

Subscribe in `AssetIntegrationService` or call `PostingService` from `DisposalService` / `DepreciationService`:

- Acquisition → debit fixed asset, credit cash/AP
- Depreciation → debit depreciation expense, credit accumulated depreciation
- Disposal → gain/loss on disposal accounts via `AccountingEngine`

## Manufacturing Machine Assets

Link `Asset.machineId` to manufacturing work center. Subscribe to `DomainEventTypes` for downtime in `AssetIntegrationService`.

## Custom Depreciation Methods

Extend `AssetsEngine.calculateDepreciation()` with new `DepreciationMethod` enum values.

## Sync

Register new entity sync processor in `assets_module_initializer.dart` following `AssetSyncProcessor` pattern.
