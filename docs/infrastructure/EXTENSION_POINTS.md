# Extension Points

## Entity Sync Processors

Implement `EntitySyncProcessor` per entity type and register with `SyncCoordinator`.

## Storage Adapters

Implement `StorageAdapter` for Supabase Storage, local filesystem, or future S3.

## Analytics Providers

Implement `AnalyticsProvider` and add to `AnalyticsHub` in `infrastructure_providers.dart`.

## Crash Reporting Providers

Implement `CrashReportingProvider` and add to `CrashReportingHub`.

## Hardware

- `BarcodeScannerAdapter` — camera, USB HID, Bluetooth, NFC
- `PrinterAdapter` — thermal, receipt, label, PDF

## Custom Conflict Resolvers

Pass `customResolver` to `ConflictResolver` for domain-specific merge logic.

## Background Tasks

Extend `BackgroundTaskScheduler` with upload workers for images and documents.
