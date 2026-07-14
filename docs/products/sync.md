# Product Catalog — Sync

## Registered processors

`productModuleInitializerProvider` registers:

| Processor | Entity | Remote table |
|-----------|--------|--------------|
| `ProductSyncProcessor` | `product` | `products` |
| `CategorySyncProcessor` | `category` | `categories` |
| `BrandSyncProcessor` | `brand` | `brands` |

## Category / Brand sync

Local CRUD via `CategoryCatalogService` / `BrandCatalogService` enqueues operations through `SyncQueueWriter`. When online, `SyncCoordinator` dispatches to the matching `EntitySyncProcessor`.

### Push flow

1. Repository persists entity locally (Drift) with `isDirty: true`
2. `SyncQueueWriter.enqueue` records operation + payload
3. `CategorySyncProcessor` / `BrandSyncProcessor` push to Supabase
4. Audit log: `change_type: category_sync` / `brand_sync`

### Pull flow

`pullDelta` fetches rows updated since checkpoint (`updated_at >= since`). Conflict detection uses `ConflictResolver` in the sync coordinator.

### Offline

- Category and brand CRUD work fully offline.
- Queue items retry automatically via `SyncCoordinator`.
- Progress reported through `SyncCoordinator` progress stream.

## Bootstrap

```dart
await container.read(productModuleInitializerProvider)();
```

Called from `Bootstrap.initialize` after infrastructure init.
