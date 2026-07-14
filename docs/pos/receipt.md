# Receipts

## Formats

Thermal, A4, PDF, and digital (QR URL placeholder) via `ReceiptEngine` + `ReceiptService`.

## Flow

1. Sale completed
2. `ReceiptService.generateAndPrint` builds `ReceiptRequest`
3. Content stored in `receipt_history` (sync entity `receipt`)
4. `PrinterHub.printReceipt` dispatches to adapters (PDF default)

## Reprint

Requires `receipt.reprint`; increments `reprint_count` and audits.

## Gift receipts

Separate `gift_receipts` table — prices hidden, optional message.
