# POS Workflows

## Standard sale

1. Open cash session
2. Create draft sale (`POSService.createDraft`)
3. Add lines (search, barcode, quick sale)
4. Optional: customer, coupon, discount
5. Payment (`CheckoutService.completeSale`)
6. Stock issued via `StockMovementService.issueStock`
7. Receipt printed; loyalty/wallet hooks via customer services

## Suspend / resume

`POSService.suspendSale` parks cart as `suspended_sale`; resume restores draft.

## Return

Lookup by receipt/barcode/customer → `ReturnValidationService` → stock restore on complete.

## Exchange

Return portion + new sale; `ExchangeValidationService` computes price difference.

## Layaway

`LayawayService.createLayaway` with deposit % and installment schedule.
