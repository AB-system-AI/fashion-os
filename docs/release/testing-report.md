# Testing Report — RC1

## Test Coverage by Module (Phases 14–16)

### Automation (`test/features/automation/`)
| File | Type | Coverage |
|------|------|----------|
| automation_engine_test.dart | Engine | Rule evaluation, workflow plans, approval checks |
| scheduler_engine_test.dart | Engine | Cron parsing, next run computation, recurring jobs |
| automation_sync_processor_test.dart | Sync | Push/pull delta, entity type mapping |
| automation_permissions_test.dart | Permission | Permission code constants |

### Integrations (`test/features/integrations/`)
| File | Type | Coverage |
|------|------|----------|
| integration_connector_engine_test.dart | Engine | Health, rate limit, retry logic |
| integrations_sync_processor_test.dart | Sync | Push/pull for connector entities |
| integrations_permissions_test.dart | Permission | Permission code constants |
| connector_service_test.dart | Service | Connector CRUD, enable/disable |

### System (`test/features/system/`)
| File | Type | Coverage |
|------|------|----------|
| system_permissions_test.dart | Permission | Permission code constants |
| system_dashboard_page_test.dart | Widget | Dashboard renders |
| system_sync_processor_test.dart | Sync | Push/pull for system entities |

## Full Project Test Inventory

Prior phases include tests under:
- `test/features/products/`, `inventory/`, `purchasing/`, `customers/`
- `test/features/pos/`, `accounting/`, `hr/`, `manufacturing/`
- `test/features/analytics/`, `sales/`
- `test/core/`

## Run Commands

```bash
# New modules only
flutter test test/features/automation/
flutter test test/features/integrations/
flutter test test/features/system/

# Full suite
flutter test

# With coverage
flutter test --coverage
```

## Gaps (Acceptable for RC1)

- No end-to-end integration tests with live Supabase
- Widget tests cover dashboards only; sub-pages rely on service tests
- AI service tests use NoOp providers (behavior verification only)

## CI Recommendation

```yaml
- run: flutter analyze
- run: flutter test --coverage
- run: dart run build_runner build --delete-conflicting-outputs
```
