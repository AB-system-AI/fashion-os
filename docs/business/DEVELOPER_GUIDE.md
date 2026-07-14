# Business Engine — Developer Guide

## Getting Started

Import engines via Riverpod providers:

```dart
import 'package:fashion_pos_enterprise/core/di/enterprise_providers.dart';

class CheckoutUseCase {
  CheckoutUseCase(this._ref);
  final Ref _ref;

  Future<Result<SaleCalculationResult>> calculate(CheckoutInput input) async {
    final facade = _ref.read(businessEngineFacadeProvider);
    return facade.calculateSale(
      pricingContexts: input.pricingContexts,
      discountLines: input.discountLines,
      taxGroup: input.taxGroup,
      couponCode: input.couponCode,
      customerId: input.customerId,
    );
  }
}
```

## Engine Usage Patterns

### Registering Rules at Startup

Engines support runtime registration. Configure rules when a tenant loads:

```dart
final pricing = ref.read(pricingEngineProvider);
pricing.registerRule(PriceRule(
  id: 'happy-hour',
  name: 'Happy Hour +5%',
  priceListType: PriceListType.happyHour,
  adjustmentPercent: -20,
  startAt: DateTime(2026, 1, 1, 17),
  endAt: DateTime(2026, 1, 1, 19),
  priority: 5,
));

final promotions = ref.read(promotionEngineProvider);
promotions.registerPromotion(Promotion(
  id: 'summer-sale',
  name: 'Summer 15%',
  discountType: DiscountType.percentage,
  priority: 10,
  percentOff: 15,
  categoryIds: ['summer-collection'],
));
```

### Validation Before Persistence

Always validate through `ValidationEngine` in use cases, not in repositories:

```dart
final validation = ref.read(validationEngineProvider);
final results = validation.validateAll([
  validation.validateDuplicateBarcode(barcode: barcode, existingBarcodes: existing),
  validation.validatePrice(price),
  validation.validateStock(quantity),
]);
if (results.isFailure) return Error(results.failureOrNull!);
```

### Domain Events

Subscribe to cross-module events:

```dart
final bus = ref.read(domainEventBusProvider);
bus.subscribe(DomainEventTypes.stockChanged, (event) {
  final stock = event as StockChangedEvent;
  // trigger reorder rule evaluation
});
```

Publish from engines is automatic (e.g. `PromotionAppliedEvent`, `LoyaltyTierChangedEvent`). Feature use cases can also publish:

```dart
bus.publish(SaleCompletedEvent(
  eventId: sale.id,
  occurredAt: DateTime.now().toUtc(),
  saleId: sale.id,
  grandTotalMinor: sale.total.minorUnits,
  currencyCode: sale.total.currencyCode,
));
```

### Number Sequences

Replace `InMemorySequenceStore` with a Drift-backed implementation for production:

```dart
class DriftSequenceStore implements SequenceStore {
  @override
  Future<int> nextSequence({...}) async {
    // atomic increment in local DB
  }
}

// Override in ProviderContainer
sequenceStoreProvider.overrideWithValue(DriftSequenceStore(db));
```

### Custom Business Rules

```dart
final rules = ref.read(ruleEngineProvider);
rules.registerRule(BusinessRule(
  id: 'low-stock',
  name: 'Notify manager on low stock',
  priority: 100,
  condition: RuleCondition(
    field: 'available',
    operator: RuleOperator.lessThan,
    value: 10,
  ),
  action: RuleAction(
    type: 'notify',
    parameters: {
      'channel': 'push',
      'title': 'Low Stock',
      'body': 'Variant {{variantId}} needs reorder',
      'recipient_id': 'manager',
    },
  ),
));

await rules.evaluateAndExecute({
  'available': snapshot.available,
  'variantId': snapshot.variantId,
});
```

For custom actions, register handlers:

```dart
rules.registerActionHandler('create_purchase_order', (action, context) async {
  // delegate to purchase use case
});
```

## Money Handling

Always use `Money` (minor units) for calculations:

```dart
final price = Money.fromMajor(19.99);       // 1999 minor units
final tax = Percentage(20).applyToMoney(price);
```

Never use `double` for monetary arithmetic in business logic.

## Workflow Integration

```dart
final workflow = ref.read(workflowEngineProvider);
workflow.registerDefinition(WorkflowDefinition(
  id: 'return_approval',
  name: 'Return Approval',
  type: WorkflowType.returns,
  steps: [
    WorkflowStepDefinition(id: 'init', name: 'Initiate', order: 0),
    WorkflowStepDefinition(id: 'mgr', name: 'Manager Review', order: 1, requiredRole: 'manager'),
    WorkflowStepDefinition(id: 'done', name: 'Process Refund', order: 2),
  ],
));

final instance = workflow.start(
  instanceId: returnId,
  definitionId: 'return_approval',
  entityId: returnId,
).dataOrNull!;
```

## What NOT to Do

- Do not put `if (price < 0)` checks in widgets or repositories
- Do not calculate tax in POS screens
- Do not hardcode promotion logic in product modules
- Do not bypass `Result<T>` — propagate failures to the UI layer

## File Naming Conventions

| Type | Pattern | Example |
|------|---------|---------|
| Engine | `*_engine.dart` | `pricing_engine.dart` |
| Entity | `*_models.dart` | `pricing_models.dart` |
| Validator | `business_validators.dart` | shared validators |
| Event | `business_events.dart` | typed events |
| Test | `*_test.dart` | `pricing_engine_test.dart` |
