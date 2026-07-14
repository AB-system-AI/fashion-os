# Phase 3.6 — Business Engine

Production-grade business rules layer. All pricing, tax, loyalty, validation, and workflow logic lives here — never in UI, controllers, or repositories.

## Architecture

```
lib/core/business/
├── domain/
│   ├── enums/           # PriceListType, TaxMode, LoyaltyTier, WorkflowType, …
│   ├── value_objects/   # Money, Percentage, Quantity
│   └── entities/        # PricingContext, Promotion, TaxGroup, LoyaltyAccount, …
├── engines/             # 16 isolated business engines
├── validators/          # Reusable business validators
├── events/              # DomainEventBus + typed domain events
├── contracts/           # SequenceStore, ExchangeRateProvider
├── di/                  # Riverpod providers
└── business_engine_facade.dart  # Sale calculation orchestrator
```

## Design Principles

| Principle | Application |
|-----------|-------------|
| **DDD** | Engines are domain services; entities are pure data + invariants |
| **SOLID** | Each engine has a single responsibility; extend via registration |
| **Clean Architecture** | Pure Dart — no Flutter imports in engines |
| **Event-driven** | Modules communicate via `DomainEventBus`, not direct calls |
| **Result boundaries** | All engine operations return `Result<T>` with typed failures |

## Engines

| Engine | Responsibility |
|--------|----------------|
| `PricingEngine` | Retail/wholesale/VIP/distributor/tier/time-based pricing, rules, margins |
| `DiscountEngine` | Percentage and fixed discounts on line items |
| `PromotionEngine` | Coupons, BOGO, bundles, priority, conflict resolution |
| `TaxEngine` | VAT, inclusive/exclusive, tax groups, compound rates |
| `LoyaltyEngine` | Points, tiers, birthday rewards, auto upgrade/downgrade |
| `InventoryRulesEngine` | Min/max stock, reservations, reorder rules |
| `ValidationEngine` | Duplicate barcode/SKU, price, stock, employee, customer, payment |
| `ReceiptEngine` | Template-based receipt generation |
| `BarcodeEngine` | EAN-13, Code128, QR, custom SKU |
| `NumberGeneratorEngine` | Invoice, PO, receipt, SKU sequences |
| `WorkflowEngine` | Purchase, sales, returns, transfers, approvals |
| `NotificationEngine` | Push, email, SMS, WhatsApp, in-app providers |
| `CurrencyEngine` | Currency formatting and conversion prep |
| `ExchangeRateEngine` | Multi-currency conversion via `ExchangeRateProvider` |
| `CashSessionEngine` | Cash drawer open/close, movements |
| `BusinessCalendarEngine` | Working hours, holidays, financial year, closings |
| `RuleEngine` | Configurable IF-THEN rules with custom action handlers |

## Dependency Injection

All engines are registered in `business_providers.dart` and re-exported from `enterprise_providers.dart`:

```dart
final pricing = ref.watch(pricingEngineProvider);
final facade = ref.watch(businessEngineFacadeProvider);
```

## Domain Events

| Event | Type constant |
|-------|---------------|
| `SaleCreatedEvent` | `sale.created` |
| `SaleCompletedEvent` | `sale.completed` |
| `ProductUpdatedEvent` | `product.updated` |
| `StockChangedEvent` | `stock.changed` |
| `CustomerCreatedEvent` | `customer.created` |
| `PurchaseReceivedEvent` | `purchase.received` |
| `LoyaltyTierChangedEvent` | `loyalty.tier_changed` |
| `PromotionAppliedEvent` | `promotion.applied` |

## Sale Calculation Flow

`BusinessEngineFacade.calculateSale()` orchestrates:

1. **Pricing** — resolve unit price per line via `PricingEngine`
2. **Promotions** — apply eligible promotions via `PromotionEngine`
3. **Discounts** — sum applied discounts via `DiscountEngine`
4. **Tax** — compute net tax via `TaxEngine`

## Relationship to Other Layers

```
┌─────────────────────────────────────────┐
│  Features (POS, Products, Customers)    │  ← UI + use cases only
├─────────────────────────────────────────┤
│  Business Engine (lib/core/business/)   │  ← ALL business logic
├─────────────────────────────────────────┤
│  Infrastructure (lib/core/infrastructure/)│  ← DB, sync, network
└─────────────────────────────────────────┘
```

Feature modules call engines through use cases. Repositories persist data; they never calculate prices or taxes.

## Tests

See `test/core/business/` and `docs/business/TESTING_STRATEGY.md`.

## Extension

See `docs/business/EXTENSION_POINTS.md` and `docs/business/DEVELOPER_GUIDE.md`.
