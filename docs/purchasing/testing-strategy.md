# Purchasing Testing Strategy

## Unit tests

- `test/core/business/purchase_engine_test.dart` — totals, validation, receive rules
- `test/features/purchasing/supplier_service_test.dart` — permissions, CRUD
- `test/features/purchasing/supplier_repository_test.dart` — offline persistence, sync queue

## Widget tests

- `test/features/purchasing/purchasing_dashboard_page_test.dart` — RBAC gating

## Commands

```bash
flutter test test/core/business/purchase_engine_test.dart
flutter test test/features/purchasing/
flutter analyze
```
