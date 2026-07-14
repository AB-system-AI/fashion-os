# Cash Management

Cash boxes track store-level cash balances with inflow/outflow movements.

## Entities

- `CashBox` — physical cash register or safe
- `CashMovement` — individual receipt or disbursement
- `PettyCash` — small fund with custodian and limit

## Permissions

- `cash.manage` — create boxes and record movements
- `treasury.view` — read-only dashboard access

## Engine rules

`TreasuryEngine.validateTransfer` and liquidity calculations aggregate cash box balances for KPIs.
