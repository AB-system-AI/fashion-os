# Treasury Architecture

```
UI (pages) → Riverpod providers → Services → Repositories → Drift → Sync → Supabase
                     ↓
              TreasuryEngine (pure rules)
                     ↓
         TreasuryIntegrationService → DomainEventBus
```

## Layers

| Layer | Location |
|-------|----------|
| Engine | `lib/core/business/engines/treasury/` |
| Domain | `lib/features/treasury/domain/` |
| Data | `lib/features/treasury/data/` |
| Presentation | `lib/features/treasury/presentation/` |
| DI | `lib/features/treasury/di/` |

## Key services

- `CashService`, `BankService`, `TransferService`
- `PaymentService`, `ReceiptService`, `ExpenseService`
- `ChequeService`, `ReconciliationService`, `ForecastService`
- `TreasuryDashboardService`
