# Manufacturing Testing Strategy

## Unit tests — engine

`test/features/manufacturing/manufacturing_engine_test.dart`

- BOM explosion (single and multi-level)
- MRP shortage detection and purchase suggestions
- Production costing and variance
- Capacity and completion scheduling
- Workflow transition validation
- Quality evaluation

## Repository tests

`test/features/manufacturing/manufacturing_repository_test.dart`

- Offline BOM create
- Sync queue enqueue

## Sync processor tests

`test/features/manufacturing/manufacturing_sync_processor_test.dart`

- Entity type → remote table mapping

## Widget tests

`test/features/manufacturing/manufacturing_dashboard_page_test.dart`

- Permission-gated dashboard tiles

## Quality tests

`test/features/manufacturing/quality_inspection_test.dart`

- Pass / fail / hold / rework outcomes

## Commands

```bash
flutter test test/features/manufacturing/
flutter analyze lib/features/manufacturing/
```
