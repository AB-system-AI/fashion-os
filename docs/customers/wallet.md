# Customer Wallet

## Operations

| Operation | Type | Effect |
|-----------|------|--------|
| Deposit | `DEPOSIT` | Increase balance |
| Withdraw | `WITHDRAW` | Decrease balance |
| Refund | `REFUND` | Increase balance |
| Purchase payment | `PURCHASE_PAYMENT` | Decrease balance |
| Manual adjustment | `ADJUSTMENT` | +/- balance |

## Persistence

- `CustomerWallet` entity with embedded `transactions` ledger
- `Customer.walletBalance` denormalized field
- Every operation: audit log + sync queue

## Validation

Withdrawals and purchase payments reject when balance would go negative.
