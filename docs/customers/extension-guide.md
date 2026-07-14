# Customers Extension Guide

## Add CRM activity type

1. Add to `CustomerActivityType` enum
2. Add method on `CustomerHistoryService`
3. Audit + repository create

## Wire loyalty to sale completion

Call `LoyaltyService.earnFromSale` from sale completion handler with `saleAmount`.

## Add customer group defaults

Seed groups via `CustomerGroupService.create` on tenant bootstrap (Regular, Silver, Gold, VIP, Wholesale).
