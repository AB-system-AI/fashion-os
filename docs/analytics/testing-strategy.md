# Testing Strategy

## Unit tests

- `test/features/analytics/analytics_engine_test.dart` — KPI math, trends, forecasts
- `test/features/analytics/analytics_sync_processor_test.dart` — entity/table mapping
- `test/features/analytics/report_definition_service_test.dart` — RBAC + audit
- `test/features/analytics/analytics_permissions_test.dart` — permission codes

## Widget tests

- `test/features/analytics/metric_card_widget_test.dart`

## Commands

```bash
flutter test test/features/analytics/
flutter analyze
```
