# Loyalty Program

## Flow

```
Enroll → Earn (sale) → Auto tier upgrade → Redeem / Birthday / Campaign / Expire
```

## Engine integration

`LoyaltyService` wraps `LoyaltyEngine` and persists:

- `CustomerLoyaltyAccount` — balance, tier, lifetime points
- `LoyaltyPointTransaction` — immutable ledger
- `Customer.loyaltyPoints` / `loyaltyTier` — denormalized for fast lookup

## Tier ladder (default)

| Tier | Min lifetime points | Multiplier |
|------|---------------------|------------|
| standard | 0 | 1.0 |
| silver | 500 | 1.25 |
| gold | 2000 | 1.5 |
| vip | 5000 | 2.0 |

Tier changes publish `LoyaltyTierChangedEvent`.
