# Customers, Loyalty & CRM (Phase 7)

Offline-first CRM module with customer management, groups, loyalty, wallet, credit, and analytics.

## Routes

| Screen | Path |
|--------|------|
| CRM Dashboard | `/customers` |
| Customer List | `/customers/list` |
| Customer Detail | `/customers/:id` |
| New Customer | `/customers/new` |
| Loyalty | `/customers/loyalty` |
| Wallet | `/customers/wallet` |
| Credit | `/customers/credit` |
| Reports | `/customers/reports` |

## Entity types (sync)

| Entity | `entity_type` | Remote table |
|--------|---------------|--------------|
| Customer | `customer` | `customers` |
| CustomerGroup | `customer_group` | `customer_groups` |
| CustomerLoyaltyAccount | `customer_loyalty_account` | `customer_loyalty_accounts` |
| LoyaltyPointTransaction | `loyalty_point_transaction` | `loyalty_point_transactions` |
| CustomerWallet | `customer_wallet` | `customer_wallets` |
| CustomerCreditAccount | `customer_credit` | `customer_credit_accounts` |
| CustomerActivity | `customer_activity` | `customer_activities` |

## Permissions

- `customer.view`, `customer.create`, `customer.update`, `customer.delete`
- `loyalty.manage`, `wallet.manage`, `credit.manage`
