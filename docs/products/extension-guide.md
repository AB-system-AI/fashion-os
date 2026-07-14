# Product Module Extension Guide

## Adding a new product field

1. Add the field to `Product` entity (`toPayload` / `fromPayload` / `copyWith`).
2. Extend `ProductCatalogService` validation or pricing if the field affects business rules.
3. Update `ProductRemoteDataSource` column mapping if synced remotely.
4. Add form input on `ProductFormPage` — keep UI dumb; pass values in the draft entity only.
5. Extend `ProductDataPortAdapter` CSV columns for import/export.
6. Add repository test coverage for round-trip persistence.

## Adding a filter or sort option

1. Extend `ProductFilterField` or `ProductSortField` in `product_enums.dart`.
2. Map the enum to `RepositoryQuery.sortBy` or `filters` in `ProductCatalogService.list`.
3. Wire UI chips or sort sheet in `ProductListPage` / `ProductListController`.

## Adding a new sync entity (e.g. attribute)

1. Create entity implementing `SyncableEntity`.
2. Implement `BaseLocalRepository` subclass.
3. Add `EntitySyncProcessor` and register in a feature `*_module_initializer.dart`.
4. Expose domain service methods with permission and audit calls.

## Media attachments

Never write files from UI. Call `ProductCatalogService.uploadProductImage`, which delegates to `MediaEngine.upload` and writes audit metadata.

## Permissions

Add codes to `permission_codes.dart`, gate service methods with `_permissions.require`, and use `permissionCheckProvider` in widgets for conditional actions.

## Design system

Prefer extending existing `AppButton`, `AppCard`, and `AppTextField` via semantic wrappers under `design_system/components/` rather than creating feature-local widgets.
