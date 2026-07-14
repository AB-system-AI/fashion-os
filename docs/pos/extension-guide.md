# POS Extension Guide

## Add a payment method

1. Seed `payment_methods` row
2. Extend `PaymentMethodKind` enum if needed
3. UI payment picker reads methods from sync/local cache

## Add printer adapter

Implement `PrinterAdapter` in `lib/core/infrastructure/hardware/` and register in `hardware_providers.dart`.

## Add promotion type

Extend `CouponType` and `SalesEngine.calculateCouponDiscount`; wire `PromotionApplicationService`.

## Custom receipt template

Insert `receipt_templates` row; pass `ReceiptTemplate` into `ReceiptRequest`.

## New sync entity

1. Add entity implementing `SyncableEntity`
2. Repository in `pos_repository_impl.dart`
3. Register `PosSyncProcessor` in `pos_module_initializer.dart`
