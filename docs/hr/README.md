# FashionOS Enterprise HR & Payroll

Phase 10 delivers human resources and payroll: employees, attendance, shifts, leave, payroll, commissions, and performance — fully offline-first with automatic integration to POS and Accounting.

## Quick start

1. Bootstrap registers `hrModuleInitializerProvider` (sync processors + integration).
2. Navigate to `/hr` from Foundation or directly.
3. All mutations persist locally and enqueue sync automatically.

## Module layout

```
lib/features/hr/
  domain/     entities, enums, repositories, services
  data/       repositories, remote datasource, sync processors
  presentation/ providers, pages
  routing/    paths and GoRouter routes
  di/         module initializer
```

## Business engine

`lib/core/business/engines/hr/hr_engine.dart` — attendance, payroll, overtime, leave, commission calculations.

## Related docs

- [architecture.md](architecture.md)
- [payroll.md](payroll.md)
- [attendance.md](attendance.md)
- [sync.md](sync.md)
- [testing-strategy.md](testing-strategy.md)
- [extension-guide.md](extension-guide.md)
