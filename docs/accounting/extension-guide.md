# Accounting Extension Guide

## Add a new auto-posting source

1. Define or reuse a `DomainEvent` in `business_events.dart`.
2. Publish the event from the originating module (POS, Purchasing, etc.).
3. Add a builder method on `AccountingEngine` (e.g. `walletJournalLines`).
4. Subscribe in `AccountingIntegrationService.register()`.
5. Call `PostingService.createAutoJournal` with a unique `referenceType` + `referenceId`.

## Add a new GL account

Extend `SystemAccounts` and `ensureDefaultChart` defaults. For tenant-specific accounts, use `AccountingRepository.create` via Chart of Accounts UI.

## Add a new report

1. Add calculation to `AccountingEngine` (pure functions).
2. Expose via a service method (`FinancialReportService` or new service).
3. Add route in `accounting_routes.dart` and tile on dashboard.
4. Gate with appropriate permission (`reports.financial` or `reports.tax`).

## Add a new sync entity

1. Add table to migration with RLS, version, sync columns.
2. Create entity with `entityTypeName` and `toPayload` / `fromPayload`.
3. Extend repository implementation.
4. Register processor in `accounting_providers.dart` and `accountingModuleInitializerProvider`.

## Add export format

Wire report data from `FinancialReportService` into the shared export layer (PDF/Excel/CSV). Keep formatting out of the engine.
