# Testing Strategy

| File | Coverage |
|------|----------|
| `admin_permissions_test.dart` | Permission code stability |
| `administration_engine_test.dart` | Org, tenant, RBAC, license, health, usage rules |
| `admin_sync_processor_test.dart` | Entity ↔ table mapping |
| `admin_service_test.dart` | Engine validation helpers |
| `admin_dashboard_page_test.dart` | Widget navigation with `admin.view` |
| `admin_organizations_test.dart` | Entity payload contract |

Run: `flutter test test/features/admin/`
