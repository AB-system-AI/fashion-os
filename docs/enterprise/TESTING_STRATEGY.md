# Enterprise Testing Strategy

Complete testing approach for a production POS platform serving thousands of stores.

## Test Pyramid

```
        ┌─────────────┐
        │  Load/E2E   │  ← k6, integration_test (staging)
        ├─────────────┤
        │ Integration │  ← offline, sync, recovery flows
        ├─────────────┤
        │ Widget/UI   │  ← screens, design system
        ├─────────────┤
        │    Unit     │  ← domain, services, validators
        └─────────────┘
```

## Unit Tests

**Scope:** Pure logic with no I/O.

| Area | Examples |
|------|----------|
| Security | `password_validator_test.dart` |
| License | Grace period evaluation, offline cache fallback |
| Pagination | `PaginationQuery.offset`, `PaginatedResult.totalPages` |
| Import/Export | CSV parse/serialize round-trip |
| Performance | Budget threshold assertions |

**Location:** `test/core/`, `test/features/<module>/domain/`

**Run:** `flutter test test/core`

## Widget Tests

**Scope:** UI components and pages with mocked providers.

| Area | Examples |
|------|----------|
| Design system | Buttons, form fields, empty/error states |
| Auth | `welcome_page_test.dart` |
| POS | Cart line list, numeric keypad (future) |

**Pattern:** `ProviderScope(overrides: [...])` + `pumpWidget`

## Integration Tests

**Scope:** Multi-service flows on device/emulator.

| Flow | Validates |
|------|-----------|
| Bootstrap | DB init, recovery, image cache |
| POS crash recovery | Kill app mid-sale → restore cart |
| Offline sale | Complete sale without network |
| Sync | Queue → process when online |
| License | Offline grace after cache |

**Location:** `integration_test/`

**Run:** `flutter test integration_test/`

## Offline Tests

Dedicated suite verifying the **no-compromise offline rule**:

1. Disable connectivity (mock `ConnectivityService`)
2. Complete full sale lifecycle
3. Verify local DB state
4. Re-enable connectivity
5. Assert sync queue drained

## Sync Tests

| Scenario | Expected |
|----------|----------|
| Duplicate enqueue | Idempotent entity_id handling |
| Retry exhaustion | `retry_count < 5` then failed status |
| Conflict | Server wins / client wins (future) |

## Performance Tests

| Metric | Tool | Threshold |
|--------|------|-----------|
| Product search | `ProductSearchService` + 10k seed | < 100ms p95 |
| Barcode lookup | `findByBarcode` | < 100ms |
| DB migration v1→v2 | timed integration | < 5s |

Use `PerformanceMonitor.averages` in test assertions.

## Load Tests (Server)

**Tool:** k6 or pgbench against Supabase staging.

| Target | Volume |
|--------|--------|
| Products per tenant | 100,000 |
| Sale orders | 1,000,000 |
| Concurrent POS devices | 50 per store |

Validate indexes from `20250712000002_performance_indexes.sql`.

## Security Tests

| Check | Method |
|-------|--------|
| DB encryption | Verify SQLCipher header, key in secure storage only |
| RLS isolation | Cross-tenant query returns empty |
| Auth brute-force | `is_login_locked` RPC |
| Audit completeness | Every mutation produces audit row |

## CI/CD Pipeline (Prepared)

```yaml
# .github/workflows/ci.yml (future)
jobs:
  analyze: flutter analyze
  unit: flutter test
  integration: flutter test integration_test/ --device-id emulator
  migration: supabase db lint + supabase test db
```

## Test Data

- `supabase/seeds/02_demo_tenant.sql` — demo tenant
- Local test fixtures in `test/fixtures/` (future)
- Factory builders per feature module

## Coverage Targets

| Layer | Target |
|-------|--------|
| Core services | ≥ 80% |
| Domain models | ≥ 90% |
| UI (widget) | Critical paths only |
| Integration | All offline/sync flows |

## Module Test Requirements

Each feature module must document:

1. Architecture decisions
2. Database changes (migrations)
3. Business rules
4. Sequence diagram
5. Test strategy (this template)
6. Extension points

See `docs/enterprise/MODULE_SYSTEM.md`.
