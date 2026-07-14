# Treasury Testing Strategy

## Unit tests

| File | Coverage |
|------|----------|
| `treasury_engine_test.dart` | Transfer validation, cheque transitions, reconciliation, forecast, KPIs, interest |
| `treasury_sync_processor_test.dart` | Entity type ↔ remote table mapping |
| `treasury_permissions_test.dart` | Stable permission code strings |
| `treasury_service_test.dart` | Engine + number generator integration |

## Conventions

- Engine tests use pure `TreasuryEngine` without mocks
- Permission tests guard against accidental code renames
- Sync mapping tests mirror sales OMS pattern
