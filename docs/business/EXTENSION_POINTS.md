# Business Engine — Extension Points

## Engine Registration

All engines support runtime registration without modifying engine source:

| Engine | Registration API |
|--------|------------------|
| `PricingEngine` | `registerRule(PriceRule)` |
| `PromotionEngine` | `registerPromotion(Promotion)` |
| `NumberGeneratorEngine` | `registerFormat(NumberSequenceFormat)` |
| `WorkflowEngine` | `registerDefinition(WorkflowDefinition)` |
| `RuleEngine` | `registerRule(BusinessRule)`, `registerActionHandler(type, handler)` |
| `NotificationEngine` | `registerProvider(NotificationProvider)` |

## Contract Implementations

### SequenceStore

Replace in-memory store for production persistence:

```dart
abstract class SequenceStore {
  Future<int> nextSequence({
    required String tenantId,
    required DocumentNumberType documentType,
    String? storeId,
  });
}
```

Implement with Drift table `document_sequences(tenant_id, store_id, type, last_value)`.

### ExchangeRateProvider

```dart
abstract class ExchangeRateProvider {
  Future<double?> getRate({required String fromCurrency, required String toCurrency, DateTime? at});
}
```

Implement with:
- Static rates for offline mode (`StaticExchangeRateProvider` — default)
- API-backed rates for online sync
- Cached rates with TTL

### NotificationProvider

Implement per channel:

```dart
class FcmNotificationProvider implements NotificationProvider {
  @override
  NotificationChannel get channel => NotificationChannel.push;

  @override
  Future<NotificationResult> send(NotificationMessage message) async {
    // FCM integration
  }
}
```

Register at app startup:

```dart
notificationEngineProvider.overrideWith((ref) {
  return NotificationEngine(providers: [
    FcmNotificationProvider(),
    SmtpEmailProvider(),
    TwilioSmsProvider(),
  ]);
});
```

## Custom Rule Actions

Extend `RuleEngine` without modifying core:

```dart
ruleEngine.registerActionHandler('upgrade_membership', (action, context) async {
  final customerId = context['customerId'] as String;
  final tier = action.parameters['tier'] as String;
  // call loyalty use case
});

ruleEngine.registerActionHandler('create_purchase_order', (action, context) async {
  // call purchase use case with suggested quantity
});
```

## Custom Workflow Steps

`WorkflowStepDefinition.metadata` carries extension data:

```dart
WorkflowStepDefinition(
  id: 'custom_inspection',
  name: 'Quality Inspection',
  order: 2,
  requiredRole: 'warehouse',
  metadata: {'handler': 'quality_inspection', 'timeout_hours': 24},
)
```

Feature modules read metadata in use cases to invoke custom handlers.

## Custom Validators

Extend `BusinessValidators` and inject into `ValidationEngine`:

```dart
class ExtendedValidators extends BusinessValidators {
  Result<void> validateSeasonalProduct({required bool inSeason}) {
    if (!inSeason) {
      return const Error(ValidationFailure(message: 'Product out of season', code: 'seasonal'));
    }
    return const Success(null);
  }
}

validationEngineProvider.overrideWith((ref) => ValidationEngine(validators: ExtendedValidators()));
```

## Custom Domain Events

Add new events in feature modules or extend `business_events.dart`:

```dart
class InvoiceVoidedEvent extends DomainEvent {
  @override
  String get eventType => 'invoice.voided';
  // ...
}
```

Subscribe with the event type string:

```dart
bus.subscribe('invoice.voided', handler);
```

## Receipt Templates

`ReceiptEngine` accepts `ReceiptTemplate` with configurable sections. Add templates per tenant:

```dart
receiptEngine.registerTemplate(ReceiptTemplate(
  id: 'retail_a4',
  name: 'Retail A4',
  showLogo: true,
  showQrCode: true,
  showTaxBreakdown: true,
  footerLines: ['Thank you for shopping!', 'Returns within 14 days'],
  customFields: ['loyalty_points', 'cashier_name'],
));
```

## Barcode Label Printing (Future)

`BarcodeEngine` returns `BarcodePayload.encodedData`. A future `LabelPrintProvider` in infrastructure hardware layer consumes this payload — business engine stays format-agnostic.

## Promotion Conflict Strategies

Add new strategies by extending `PromotionConflictStrategy` enum and `_resolveConflicts` in `PromotionEngine`, or configure per promotion:

- `highestPriority` — single best promotion
- `bestForCustomer` — apply all, customer gets best total
- `stackable` — only stackable promotions combined
- `exclusive` — first eligible only

## Tax Regional Extensions

`TaxRate` supports `countryCode` and `regionCode`. Feature modules filter rates by store location before passing `TaxGroup` to `TaxEngine`. The engine itself is region-agnostic.

## Calendar Extensions

`BusinessCalendarEngine` methods accept `CalendarEvent` lists loaded from tenant config. Extend with:

- Ramadan hours
- Per-store timezone overrides
- Financial period locking

## DI Overrides (Per Tenant)

```dart
ProviderScope(
  overrides: [
    pricingEngineProvider.overrideWith((ref) {
      final engine = PricingEngine();
      for (final rule in tenant.priceRules) {
        engine.registerRule(rule);
      }
      return engine;
    }),
  ],
  child: MyApp(),
);
```
