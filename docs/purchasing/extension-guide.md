# Purchasing Extension Guide

## Add a new synced entity

1. Create entity implementing `SyncableEntity` with `entityTypeName`
2. Add repository interface + `PurchasingRepositoryImpl` subclass
3. Register provider in `purchasing_providers.dart`
4. Register `PurchaseSyncProcessor` in `purchasing_module_initializer.dart`
5. Add Supabase migration with `version`, `updated_at`, `deleted_at`
6. Add permissions to `permission_codes.dart`

## Add a workflow step

1. Add status to `PurchaseOrderStatus` or `PurchaseReturnStatus`
2. Add service method with `PermissionEngine.require`
3. Call `_audit.log` after repository update
4. Expose action on detail page with permission check

## Barcode receiving

Extend `BarcodeReceivingService` or call `PurchaseReceiptService.receive` with resolved line quantities.
