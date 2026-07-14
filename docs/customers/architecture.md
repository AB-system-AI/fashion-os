# Customers Architecture

## Layers

- **Domain**: entities, enums, repository interfaces, services
- **Data**: `CustomerRepositoryImpl`, `CustomerRemoteDataSource`, `CustomerSyncProcessor`
- **Presentation**: Riverpod providers, Material 3 pages, GoRouter routes

## Business engines

- `LoyaltyEngine` — earn, redeem, birthday, adjust, expire, campaign bonus, tier changes
- `NumberGeneratorEngine` — `CUS-` customer codes
- `BarcodeEngine` — membership barcode generation

## Services

| Service | Responsibility |
|---------|----------------|
| `CustomerService` | CRUD, archive, audit, `CustomerCreatedEvent` |
| `CustomerGroupService` | Group CRUD with pricing/discount/loyalty rules |
| `LoyaltyService` | Engine integration + persistence |
| `WalletService` | Deposit, withdraw, refund, payment, adjustment |
| `CustomerCreditService` | Credit limit validation, charge, payment |
| `CustomerStatisticsService` | Per-customer stats |
| `CustomerHistoryService` | Notes, visits, communications, favorites |
| `CustomerAnalyticsService` | Top customers, inactive, birthdays, totals |
| `CustomerLookupService` | Phone, code, barcode POS lookup |
