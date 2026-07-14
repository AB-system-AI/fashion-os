# HR Testing Strategy

## Unit tests

| Area | File |
|------|------|
| HREngine | `test/features/hr/hr_engine_test.dart` |
| Payroll | `test/features/hr/payroll_calculation_test.dart` |
| Repository | `test/features/hr/hr_repository_test.dart` |
| Sync | `test/features/hr/hr_sync_processor_test.dart` |

## Widget tests

| Page | File |
|------|------|
| Dashboard | `test/features/hr/hr_dashboard_page_test.dart` |

## Commands

```bash
flutter test test/features/hr/
flutter analyze lib/features/hr lib/core/business/engines/hr
```
