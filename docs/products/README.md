# Product Catalog Module

FashionOS Phase 4 / 4.1 delivers a production-ready, offline-first product catalog.

## Phase 4.1 finalization

- **Media integration** — `ProductImageGallery` fully wired to `MediaEngine` (camera, gallery, reorder, primary, delete, replace, thumbnails, compression, WebP, offline cache, upload queue, sync status, retry)
- **Barcode labels** — generate, preview, print via `PrinterHub` abstraction (Code128, EAN-13, QR; batch variant printing)
- **Category / Brand sync** — `CategorySyncProcessor` and `BrandSyncProcessor` with delta push, audit, offline queue
- **Audit** — image upload/delete/reorder/replace, barcode generate/print, category/brand sync

## Phase 4.1 additions

- **Category CRUD** with unlimited hierarchy, parent validation, archive/restore
- **Brand CRUD** with archive/restore
- **Variant management** UI + cartesian matrix generator
- **Product images** via Media Engine (gallery, reorder, primary)
- **Bulk operations** — delete, restore, archive, activate/deactivate, price/category/brand/supplier updates
- **Import** — CSV/Excel with validation preview, duplicate detection, rollback
- **Export** — CSV, Excel, PDF catalog, filtered/selected export
- **Advanced search & filters** — status, price, dates, has image/variants
- **Product timeline** — audit-backed activity feed
- **Inventory preview** — read-only summary via `InventoryRulesEngine`
- **Barcode** — generate, regenerate, label print from product detail

## Permissions

| Code | Capability |
|------|------------|
| `product.variant.manage` | Variant matrix and edits |
| `product.bulk` | Bulk toolbar actions |
| `category.manage` | Category CRUD |
| `brand.manage` | Brand CRUD |

See [Architecture](./architecture.md) for diagrams and [Testing Strategy](./testing-strategy.md) for coverage.

## Routes

| Path | Screen |
|------|--------|
| `/products` | Product list |
| `/products/new` | Create product |
| `/products/:id` | Product detail |
| `/products/:id/edit` | Edit product |
| `/products/:id/variants` | Variant management |
| `/products/:id/labels` | Barcode label preview & print |
| `/products/categories` | Category tree |
| `/products/brands` | Brand list |
| `/products/import` | CSV import/export |

## Layering

```
presentation/   → Riverpod controllers & pages (no business rules)
domain/         → Entities, repository contracts, catalog services
data/           → Drift repositories, remote datasource, sync processor
```

All mutations flow through domain services (`ProductCatalogService`, `CategoryCatalogService`, `BrandCatalogService`, `ProductMediaGalleryService`, `BarcodeLabelPrintService`), which coordinate validation, media, audit, permissions, and sync.

## Bootstrap

`productModuleInitializerProvider` registers `ProductSyncProcessor`, `CategorySyncProcessor`, and `BrandSyncProcessor` with `SyncCoordinator` during app bootstrap.

## Related docs

- [Architecture](./architecture.md)
- [Media integration](./media-integration.md)
- [Sync](./sync.md)
- [Barcode labels](./barcode.md)
- [Extension guide](./extension-guide.md)
- [Testing strategy](./testing-strategy.md)
