# Table Catalog

All tables live in schema `public`. Primary key is `id` (UUID) unless noted.

**Total tables:** 70 (68 tenant-scoped + 2 platform-global)

## Tenant & Organization

| Table | Primary key | Scope | Description |
|-------|-------------|-------|-------------|
| `tenants` | `id` | tenant | Root SaaS tenant (organization) record with billing profile, locale, and lifecycle status. |
| `subscription_plans` | `id` | platform | Global SaaS plan catalog (limits, pricing, feature flags); not tenant-scoped. |
| `tenant_subscriptions` | `id` | tenant | Active or historical subscription binding a tenant to a plan and billing period. |
| `stores` | `id` | tenant | Retail store location belonging to a tenant; default currency and receipt settings. |
| `warehouses` | `id` | tenant | Stock location (store-linked or central) used for inventory quantities. |
| `numbering_sequences` | `id` | tenant | Per-tenant/store document counters (sales, POs, returns) with atomic next value. |
| `settings` | `id` | tenant | Key-value tenant or store-scoped configuration (JSON values). |

## Identity & Access

| Table | Primary key | Scope | Description |
|-------|-------------|-------|-------------|
| `profiles` | `id` | tenant | Auth-linked user profile extending auth.users with display and contact fields. |
| `permissions` | `id` | platform | Global permission catalog (module.action codes) for RBAC. |
| `roles` | `id` | tenant | Tenant-defined roles grouping permissions for employees. |
| `role_permissions` | `id` | tenant | Many-to-many link between roles and permissions. |
| `employees` | `id` | tenant | Tenant workforce member linked to a profile and optional employee code. |
| `employee_store_assignments` | `id` | tenant | Which stores an employee may access for POS and operations. |
| `employee_roles` | `id` | tenant | Role grants per employee with optional store scope and grant metadata. |

## Catalog

| Table | Primary key | Scope | Description |
|-------|-------------|-------|-------------|
| `brands` | `id` | tenant | Product brand master data per tenant. |
| `categories` | `id` | tenant | Hierarchical merchandise categories with materialized path support. |
| `colors` | `id` | tenant | Color attribute lookup for variants. |
| `sizes` | `id` | tenant | Size attribute lookup for variants. |
| `products` | `id` | tenant | Sellable product header (style/SKU family) with brand and category. |
| `product_variants` | `id` | tenant | Concrete SKU (size/color) with price, cost, and barcode reference. |
| `product_variant_barcodes` | `id` | tenant | Additional barcodes per variant (EAN/UPC/custom). |
| `product_images` | `id` | tenant | Ordered image metadata for products/variants (storage paths). |
| `taxes` | `id` | tenant | Tax rate definitions applicable per tenant/jurisdiction. |
| `product_taxes` | `id` | tenant | Product-to-tax assignment rules. |

## Inventory

| Table | Primary key | Scope | Description |
|-------|-------------|-------|-------------|
| `inventory_items` | `id` | tenant | On-hand quantity per variant and warehouse with reserved qty. |
| `inventory_movements` | `id` | tenant | Immutable stock ledger entries (sale, adjustment, transfer, receipt). |
| `stock_adjustments` | `id` | tenant | Stock count/correction header with reason and store context. |
| `stock_adjustment_lines` | `id` | tenant | Line-level quantity deltas for a stock adjustment. |
| `inventory_transfers` | `id` | tenant | Inter-warehouse transfer document header. |
| `inventory_transfer_lines` | `id` | tenant | Transfer lines with shipped/received quantities. |

## Purchases

| Table | Primary key | Scope | Description |
|-------|-------------|-------|-------------|
| `suppliers` | `id` | tenant | Vendor master for purchasing. |
| `purchase_orders` | `id` | tenant | Open or completed PO header to a supplier for a store. |
| `purchase_order_lines` | `id` | tenant | Ordered variant quantities and costs on a PO. |
| `purchase_receipts` | `id` | tenant | Goods-received document against PO(s). |
| `purchase_receipt_lines` | `id` | tenant | Received quantities per variant on a receipt. |

## Customers & Loyalty

| Table | Primary key | Scope | Description |
|-------|-------------|-------|-------------|
| `customers` | `id` | tenant | CRM customer record with contact and marketing preferences. |
| `customer_addresses` | `id` | tenant | Shipping/billing addresses for customers. |
| `loyalty_programs` | `id` | tenant | Tenant loyalty program definition and earn rules. |
| `loyalty_tiers` | `id` | tenant | Tier thresholds and benefits within a program. |
| `customer_loyalty_accounts` | `id` | tenant | Customer enrollment and current points balance. |
| `loyalty_point_transactions` | `id` | tenant | Point earn/redeem/adjust ledger. |

## Sales & POS

| Table | Primary key | Scope | Description |
|-------|-------------|-------|-------------|
| `payment_methods` | `id` | tenant | Tenant payment types (cash, card, wallet) with configuration. |
| `pos_registers` | `id` | tenant | Physical/logical POS register bound to a store. |
| `cash_sessions` | `id` | tenant | Cash drawer session (open/close) per register with balances. |
| `cash_session_movements` | `id` | tenant | Cash in/out movements during a session. |
| `discounts` | `id` | tenant | Manual or automatic discount rules. |
| `coupons` | `id` | tenant | Coupon codes linked to discount rules with usage limits. |
| `sale_orders` | `id` | tenant | POS sale / order header with totals, status, and store. |
| `sale_order_lines` | `id` | tenant | Sold line items with pricing, tax snapshot, and variant. |
| `sale_order_line_taxes` | `id` | tenant | Tax breakdown per sale line. |
| `sale_payments` | `id` | tenant | Payments captured against a sale order. |
| `coupon_redemptions` | `id` | tenant | Audit of coupon usage on a sale. |

## Returns & Exchanges

| Table | Primary key | Scope | Description |
|-------|-------------|-------|-------------|
| `sale_returns` | `id` | tenant | Return document referencing original sale. |
| `sale_return_lines` | `id` | tenant | Returned quantities and refund amounts per line. |
| `sale_return_payments` | `id` | tenant | Refund payment breakdown for a return. |
| `exchanges` | `id` | tenant | Exchange transaction linking return and new sale. |
| `exchange_lines` | `id` | tenant | Line mapping for exchange (returned vs issued SKU). |

## Financial

| Table | Primary key | Scope | Description |
|-------|-------------|-------|-------------|
| `expense_categories` | `id` | tenant | Chart of expense categories for store operations. |
| `expenses` | `id` | tenant | Operational expense entries with optional receipt attachment. |
| `daily_closings` | `id` | tenant | End-of-day Z-report / closing summary per store. |
| `daily_closing_payments` | `id` | tenant | Payment method totals aggregated in a daily closing. |

## System & Sync

| Table | Primary key | Scope | Description |
|-------|-------------|-------|-------------|
| `devices` | `id` | tenant | Registered client devices (POS, mobile) with fingerprints. |
| `receipt_templates` | `id` | tenant | Custom receipt HTML/PDF templates per store. |
| `notifications` | `id` | tenant | In-app notifications targeted to employees. |
| `audit_logs` | `id` | tenant | Append-only audit trail of sensitive mutations. |
| `file_attachments` | `id` | tenant | Generic file metadata pointing to storage objects. |
| `sync_devices` | `id` | tenant | Offline sync pairing between tenant device and sync state. |
| `sync_queue` | `id` | tenant | Outbound/inbound sync operations queue for offline POS. |
| `sync_conflicts` | `id` | tenant | Conflict records requiring manual or rule-based resolution. |
| `sync_checkpoints` | `id` | tenant | Per-device replication watermark for incremental sync. |


