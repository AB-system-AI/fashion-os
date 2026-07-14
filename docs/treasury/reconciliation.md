# Bank Reconciliation

Reconciliation matches book balances against bank statements.

## Entities

- `BankReconciliation` — statement date, book vs statement balance, variance

## Engine

`TreasuryEngine.reconcile` compares balances and line items within tolerance.

## Permissions

- `reconciliation.manage` — start and close reconciliations

## Integration

`TreasuryIntegrationService` listens for `reconciliation.completed` events for analytics audit trails.
