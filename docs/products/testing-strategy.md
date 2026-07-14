# Product Catalog Testing Strategy

## Unit tests

| Area | File |
|------|------|
| Product repository | `product_repository_test.dart` |
| Catalog service | `product_catalog_service_test.dart` |
| Category service | `category_catalog_service_test.dart` |
| Variant matrix | `variant_matrix_generator_test.dart` |
| Import/export | `import_export_test.dart` |
| Product sync | `product_sync_processor_test.dart` |
| Category sync | `category_sync_processor_test.dart` |
| Brand sync | `brand_sync_processor_test.dart` |
| Media gallery service | `product_media_gallery_service_test.dart` |
| Barcode labels | `barcode_label_test.dart` |
| Upload queue | `upload_queue_test.dart` |
| Offline media | `offline_media_test.dart` |
| Permissions | `test/core/permissions/permission_engine_test.dart` |

## Widget tests

| Screen / widget | File |
|-----------------|------|
| Product list | `product_list_page_test.dart` |
| Image gallery | `product_image_gallery_test.dart` |

## Phase 4.1 finalization coverage

- **Media integration** — gallery load offline thumbnails, upload audit, reorder audit
- **Barcode labels** — offline PNG generation, printer hub preview abstraction
- **Category/Brand sync** — processor entity type registration
- **Upload queue** — retry contract surface

## Manual QA

- [ ] Category tree: create parent → child → edit → archive (offline + sync)
- [ ] Brand CRUD with permission `brand.manage` (offline + sync)
- [ ] Product images: camera/gallery → reorder → set primary → delete → retry upload
- [ ] Barcode labels: preview → print batch (all variants)
- [ ] Variant matrix: Black/White × S/M/L → 6 variants → save offline
- [ ] Long-press product → bulk archive → sync queue
- [ ] Import preview shows duplicate SKU before commit
- [ ] Product detail timeline shows image/barcode/sync events
- [ ] Inventory preview shows available from variant stock

## Commands

```bash
flutter test test/features/products
flutter analyze
```
