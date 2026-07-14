# Business Engine — Testing Strategy

## Test Location

```
test/core/business/
├── pricing_engine_test.dart
├── discount_engine_test.dart
├── promotion_engine_test.dart
├── tax_engine_test.dart
├── loyalty_engine_test.dart
├── validation_engine_test.dart
├── inventory_rules_engine_test.dart
├── workflow_engine_test.dart
├── rule_engine_test.dart
├── barcode_engine_test.dart
├── number_generator_engine_test.dart
└── domain_event_bus_test.dart
```

## Running Tests

```bash
flutter test test/core/business
```

## Test Categories

### Unit Tests (Engines)

Each engine is tested in isolation with no Flutter bindings, database, or network:

| Engine | Key scenarios |
|--------|---------------|
| Pricing | Retail/VIP multipliers, manual override, rule priority |
| Discount | Percentage, fixed, validation boundaries |
| Promotion | Conflict resolution, coupons, buy-X-get-Y |
| Tax | Exclusive/inclusive VAT, empty tax group rejection |
| Loyalty | Earn, redeem, tier auto-upgrade, insufficient points |
| Validation | Duplicate barcode, blocked customer, validateAll |
| Inventory | Min stock alerts, reservation, reorder |
| Workflow | Start, role-gated advance, cancel |
| Rule | Condition match/miss, custom action handlers |
| Barcode | EAN-13 check digit, Code128, custom SKU |
| Number Generator | Sequential formats, date prefix |

### Rule Tests

`rule_engine_test.dart` covers:

- Condition operators (`lessThan`, `greaterThan`, `equal`)
- Priority ordering
- Custom `registerActionHandler` execution
- Built-in `notify` action dispatch

### Integration-Style Tests (Facade)

Add `business_engine_facade_test.dart` when checkout use cases stabilize:

```dart
test('full sale calculation', () {
  final facade = BusinessEngineFacade(
    pricing: PricingEngine(),
    promotion: PromotionEngine(),
    discount: DiscountEngine(),
    tax: TaxEngine(),
  );
  // assert subtotal, discounts, tax, grand total
});
```

## Test Data Conventions

- Use `Money.fromMajor()` — never raw doubles for money
- Use `DateTime.utc()` for deterministic time-based rules
- Use `InMemorySequenceStore` for number generator tests
- No mocks required for pure engine tests

## Coverage Goals

| Area | Target |
|------|--------|
| Engine public API | 100% of methods exercised |
| Validation paths | Success + failure for each validator |
| Edge cases | Zero amounts, empty lists, boundary percentages |
| Event bus | Subscribe, publish, unsubscribe |

## CI Integration

```yaml
- name: Business engine tests
  run: flutter test test/core/business --reporter expanded
```

## What Not to Test Here

- UI widget tests
- Repository persistence (covered in infrastructure tests)
- Supabase sync (covered in infrastructure tests)

Business engine tests must remain fast (< 5 seconds total) and fully offline.
