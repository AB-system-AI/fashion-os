# Manufacturing Accounting

Journal auto-posting uses `JournalSource.manufacturing`.

## System accounts

| Code | Name |
|------|------|
| 1250 | Work In Process |
| 5910 | Manufacturing Variance |
| 5920 | Scrap Expense |
| 5930 | Manufacturing Overhead |

## Engine methods

- `materialIssueLines` — Dr WIP, Cr Inventory
- `materialReturnLines` — Dr Inventory, Cr WIP
- `wipStartLines` — Dr WIP, Cr Overhead
- `finishedGoodsReceiptLines` — Dr Inventory, Cr WIP
- `scrapLines` — Dr Scrap, Cr WIP
- `manufacturingVarianceLines` — favorable/unfavorable
- `productionCompletionLines` — labor + overhead to WIP
- `cogsPreparationLines` — Dr COGS, Cr Inventory

## Integration

Handled in `AccountingIntegrationService` — never duplicate posting logic in manufacturing services.
