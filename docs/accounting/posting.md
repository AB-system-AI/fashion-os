# Journal Posting

## Double-entry rules

`AccountingEngine.validateJournalLines` enforces:

- At least two lines
- No negative amounts
- Each line has debit **or** credit (not both)
- Total debits equal total credits (±0.01)

## Posting flow

1. `PostingService.postJournal` checks `journal.post` permission.
2. Validates lines via `AccountingEngine`.
3. Idempotent by `referenceType` + `referenceId` (skips if already posted).
4. Assigns `JE-` document number when empty.
5. Persists journal entry (status `posted`).
6. Builds ledger transactions and updates account balances.
7. Publishes `JournalPostedEvent`.
8. Writes audit log.

All steps run inside repository transactions; each mutation enqueues sync.

## Auto journals

`PostingService.createAutoJournal` is used by `AccountingIntegrationService` with a system user carrying `journal.post`. Sources include:

| Source | Journal source enum |
|--------|---------------------|
| POS sale | `sale` |
| Cash session variance | `cashSession` |
| Purchase receipt | `purchase` |
| Manual | `manual` |

## System accounts

| Code | Purpose |
|------|---------|
| 1000 | Cash |
| 1100 | Accounts Receivable |
| 1200 | Inventory |
| 2000 | Accounts Payable |
| 2100 | Tax Payable |
| 2200 | Loyalty Liability |
| 2210 | Wallet Liability |
| 4000 | Sales Revenue |
| 5000 | COGS |
| 5900 | Cash Over/Short |

Seeded by `AccountingIntegrationService.ensureDefaultChart`.

## Reversals

Journal reversal (`journal.reverse` permission) is planned as a dedicated service method that creates offsetting entries linked via `reversedEntryId`.
