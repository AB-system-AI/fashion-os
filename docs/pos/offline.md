# POS Offline

Sales never fail due to connectivity. Every mutation:

1. Writes to local `syncable_records` inside a transaction
2. Enqueues `SyncQueue` item
3. Marks record `isDirty` / `pending`

## Cached offline data

Products, prices, taxes, customers, coupons, and promotions are available via local syncable storage and search indexes.

## Retry

`PosSyncProcessor` push/pull runs through the global sync coordinator with automatic retry.

## Receipts

Receipt content is stored locally in `receipt_history` payload; thermal/PDF print works offline via `PrinterHub` (PDF adapter ships by default).
