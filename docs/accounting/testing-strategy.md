# Accounting Testing Strategy

## Unit tests

| Area | File |
|------|------|
| AccountingEngine | `test/features/accounting/accounting_engine_test.dart` |
| Journal posting | `test/features/accounting/journal_posting_test.dart` |
| Repository | `test/features/accounting/accounting_repository_test.dart` |
| Sync processors | `test/features/accounting/accounting_sync_processor_test.dart` |

## Widget tests

| Page | File |
|------|------|
| Dashboard | `test/features/accounting/accounting_dashboard_page_test.dart` |

## Patterns

- Use `AppDatabase.inMemory()` for repository and posting integration tests.
- Mock `AuditService` with `mocktail` when testing services that audit.
- Use `InMemorySequenceStore` for journal number generation in tests.
- Permission tests override `currentUserProvider` with explicit permission sets.

## Commands

```bash
flutter test test/features/accounting/
flutter analyze lib/features/accounting lib/core/business/engines/accounting
```

## Coverage goals

- Double-entry validation (balanced / unbalanced)
- Posting updates ledger and account balances
- Sync queue enqueue on mutation
- Dashboard permission gating
