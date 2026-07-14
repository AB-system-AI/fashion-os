# Customers Testing Strategy

```bash
flutter test test/features/customers/
flutter test test/core/business/loyalty_engine_test.dart
flutter analyze lib/features/customers
```

## Coverage

- `customer_repository_test.dart` — offline persistence + sync queue
- `customer_service_test.dart` — permission checks
- `loyalty_service_test.dart` — engine adjust/expire
- `customer_sync_processor_test.dart` — entity type mapping
- `crm_dashboard_page_test.dart` — RBAC widget test
