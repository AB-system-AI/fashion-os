# Testing Report — RC2

**Date:** 2026-07-14

## Phase 18 New Tests

| File | Type | Coverage |
|------|------|----------|
| `test/app/foundation_page_test.dart` | Widget | All 16 module entry buttons |
| `test/core/permissions/permission_namespace_test.dart` | Unit | Maintenance/bank/receipt namespace isolation |
| `test/features/treasury/treasury_dashboard_page_test.dart` | Widget | Treasury dashboard navigation |
| `test/features/workflow/workflow_dashboard_page_test.dart` | Widget | Workflow dashboard navigation |

## Module Test Inventory (Treasury, Assets, Workflow)

### Treasury (`test/features/treasury/`)
| File | Coverage |
|------|----------|
| treasury_engine_test.dart | Interest, balance calculations |
| treasury_service_test.dart | Voucher CRUD, permissions |
| treasury_sync_processor_test.dart | Push/pull delta |
| treasury_permissions_test.dart | Namespaced permission codes |
| treasury_dashboard_page_test.dart | Dashboard widget |

### Assets (`test/features/assets/`)
| File | Coverage |
|------|----------|
| assets_engine_test.dart | Depreciation calculations |
| assets_sync_processor_test.dart | Push/pull delta |
| assets_permissions_test.dart | Namespaced maintenance codes |
| assets_dashboard_page_test.dart | Dashboard widget |

### Workflow (`test/features/workflow/`)
| File | Coverage |
|------|----------|
| approval_engine_test.dart | Approval routing, escalation |
| workflow_sync_processor_test.dart | Push/pull delta |
| workflow_permissions_test.dart | Permission constants |
| workflow_dashboard_page_test.dart | Dashboard widget |

## Updated Tests (RC2 Permission Fix)

| File | Change |
|------|--------|
| treasury_permissions_test.dart | `TreasuryBankPermissions`, `TreasuryReceiptPermissions` |
| assets_permissions_test.dart | `assets.maintenance.*` codes |
| system_permissions_test.dart | `system.maintenance.manage` |

## Run Commands

```bash
# Phase 18 new tests
flutter test test/app/foundation_page_test.dart
flutter test test/core/permissions/permission_namespace_test.dart

# RC2 modules
flutter test test/features/treasury/
flutter test test/features/assets/
flutter test test/features/workflow/

# Full suite
flutter test
```

## Coverage Gaps (Acceptable for RC2)

- No E2E tests with live Supabase
- Sub-pages rely on service/engine tests
- AI/communication providers use NoOp (behavior-only tests)

## CI Recommendation

```yaml
- run: flutter analyze
- run: flutter test --coverage
- run: dart run build_runner build --delete-conflicting-outputs
```
