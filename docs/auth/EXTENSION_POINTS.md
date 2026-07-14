# Extension Points — Future Features

Architecture is modular so features plug in without breaking core.

## POS & Sales (`features/pos/`)

- `PosCartRepository` — offline cart in `sales_local` table
- `BarcodeScannerService` — camera/USB scanner abstraction in `core/hardware/`
- `PrinterService` — ESC/POS Bluetooth/USB/WiFi in `core/hardware/printing/`
- `PaymentGatewayAdapter` — interface in `core/integrations/payments/`

## Product Management (`features/catalog/`)

- `ProductSyncAdapter` — implements `SyncEntityProcessor` for delta sync
- `ImportExportService` — CSV/Excel via `imports` storage bucket
- `ImageCompressionPipeline` — before `product-images` upload

## Inventory (`features/inventory/`)

- `InventoryReservationService` — `quantity_reserved` on `inventory_items`
- `StockCountSession` — offline count sheets synced via queue

## Offline Sync (`core/sync/`)

```dart
abstract class SyncEntityProcessor {
  String get entityType;
  Future<bool> process(Map<String, dynamic> queueItem);
}
```

Register processors in `SyncEngine` at bootstrap:

```dart
syncEngine.registerProcessor(ProductSyncProcessor());
syncEngine.registerProcessor(SaleSyncProcessor());
```

## AI Features (`core/ai/`)

- `AiInsightProvider` — reads from analytics warehouse (future)
- `DemandForecastService` — extension on inventory module
- Prepared hooks in `AnalyticsService.track()`

## Integrations (`core/integrations/`)

| Integration | Interface | Location |
|---|---|---|
| Payment Gateway | `PaymentGateway` | `core/integrations/payments/` |
| SMS | `SmsProvider` | `core/integrations/messaging/` |
| WhatsApp | `WhatsAppProvider` | `core/integrations/messaging/` |
| ERP | `ErpConnector` | `core/integrations/erp/` |
| Accounting | `AccountingConnector` | `core/integrations/accounting/` |

## Feature Flags

```dart
ref.read(remoteConfigServiceProvider).isFeatureEnabled('barcode_scanner');
```

Add flags to `remote_config` table per tenant or globally.

## License / Subscription

```dart
final status = await ref.read(licenseValidatorProvider).validate(
  tenantId: user.tenantId,
  subscriptionStatus: subscription.status,
);
```

Gate features in UI and repository layers based on `LicenseStatus`.
