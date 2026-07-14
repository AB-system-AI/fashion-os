# Dependency Report — RC1

## Core Dependencies

| Package | Purpose | Status |
|---------|---------|--------|
| flutter_riverpod | State management & DI | Active |
| go_router | Navigation | Active |
| drift | Local SQLite database | Active |
| supabase_flutter | Remote backend | Active |
| equatable | Value equality | Active |
| collection | Utility extensions | Active |
| gap | UI spacing | Active |

## Internal Module Dependencies

| Consumer | Depends On |
|----------|------------|
| automation | core/business (engines), core/audit, core/permissions |
| integrations | core/import_export, core/business/notification |
| system | core/audit, core/infrastructure/sync |
| sales | inventory, manufacturing, customers, analytics |
| manufacturing | inventory, purchasing |
| pos | products, inventory, customers, accounting |

## No Circular Dependencies Detected

Domain layers do not import presentation layers. Feature modules import core but not each other's presentation layers (cross-module via integration services only).

## External API Dependencies

**None required for RC1.** All AI, OAuth, email, SMS, push providers are abstracted with NoOp implementations.

## Build Tools

- `build_runner` — Drift code generation
- `flutter_test` — Unit/widget tests

## Recommended Pre-Release

```bash
dart pub outdated
dart run build_runner build --delete-conflicting-outputs
```
