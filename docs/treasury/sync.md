# Treasury Sync

`TreasurySyncProcessor` is a generic processor with typedef aliases per entity.

## Registered processors (12)

| Entity | Remote table |
|--------|--------------|
| `cash_box` | `cash_boxes` |
| `bank` | `banks` |
| `bank_account` | `bank_accounts` |
| `petty_cash` | `petty_cash_funds` |
| `transfer` | `treasury_transfers` |
| `cheque` | `cheques` |
| `cheque_book` | `cheque_books` |
| `payment_voucher` | `payment_vouchers` |
| `receipt_voucher` | `receipt_vouchers` |
| `expense_request` | `expense_requests` |
| `cash_forecast` | `cash_forecasts` |
| `bank_reconciliation` | `bank_reconciliations` |
| `treasury_settings` | `treasury_settings` |

Registration occurs in `treasuryModuleInitializerProvider`.
