# Inventory Testing Strategy

## Unit

| Area | Path |
|---|---|
| InventoryEngine | `test/core/business/inventory_engine_test.dart` |
| Stock movement permissions | `test/features/inventory/stock_movement_service_test.dart` |
| Warehouse repository | `test/features/inventory/warehouse_repository_test.dart` |
| Sync processor types | `test/features/inventory/inventory_sync_processor_test.dart` |

## Widget

| Screen | Path |
|---|---|
| Dashboard | `test/features/inventory/inventory_dashboard_page_test.dart` |

## Integration (future)

- Full transfer workflow with in-memory Drift
- Stock count → adjustment → movement chain
- Barcode lookup with product catalog fixtures

## Commands

```bash
flutter test test/core/business/inventory_engine_test.dart
flutter test test/features/inventory/
```
