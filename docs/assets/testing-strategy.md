# Assets Testing Strategy

## Unit tests

| File | Coverage |
|------|----------|
| `assets_permissions_test.dart` | Stable permission string constants |
| `assets_sync_processor_test.dart` | Entity type ↔ remote table mapping |
| `assets_engine_test.dart` | Depreciation, lifecycle, utilization, warranty |

## Widget tests

| File | Coverage |
|------|----------|
| `assets_dashboard_page_test.dart` | Permission gating and navigation tiles |

## Integration (future)

- End-to-end transfer → location update → event audit
- Depreciation posting → book value reconciliation
- Maintenance request → asset status `in_maintenance`

## Conventions

Follow `test/features/sales/` and `test/features/automation/` patterns: pure engine tests without mocks, sync processor table mapping assertions, dashboard tests with `currentUserProvider` override.
