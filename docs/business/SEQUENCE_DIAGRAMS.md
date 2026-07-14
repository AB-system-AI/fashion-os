# Business Engine — Sequence Diagrams

## Sale Calculation (BusinessEngineFacade)

```mermaid
sequenceDiagram
    participant UC as CheckoutUseCase
    participant F as BusinessEngineFacade
    participant P as PricingEngine
    participant PR as PromotionEngine
    participant D as DiscountEngine
    participant T as TaxEngine
    participant EB as DomainEventBus

    UC->>F: calculateSale(contexts, lines, taxGroup)
    loop each pricing context
        F->>P: resolvePrice(context)
        P-->>F: PricingResult
    end
    F->>PR: applyPromotions(lines, coupon, customer)
    PR->>EB: PromotionAppliedEvent (per discount)
    PR-->>F: List<AppliedDiscount>
    F->>D: sumDiscounts(discounts)
    D-->>F: discountTotal
    F->>T: calculate(netLines, taxGroup)
    T-->>F: TaxCalculationResult
    F-->>UC: SaleCalculationResult
```

## Product Creation Validation

```mermaid
sequenceDiagram
    participant UC as CreateProductUseCase
    participant V as ValidationEngine
    participant B as BarcodeEngine
    participant R as ProductRepository

    UC->>V: validateDuplicateBarcode(barcode, existing)
    V-->>UC: Result<void>
    UC->>V: validateDuplicateSku(sku, existing)
    V-->>UC: Result<void>
    UC->>V: validatePrice(price)
    V-->>UC: Result<void>
    UC->>B: generate(EAN-13, value)
    B-->>UC: BarcodePayload
    UC->>R: save(product)
    Note over R: Repository persists only — no business rules
```

## Loyalty Earn + Tier Upgrade

```mermaid
sequenceDiagram
    participant UC as CompleteSaleUseCase
    participant L as LoyaltyEngine
    participant EB as DomainEventBus
    participant N as NotificationEngine

    UC->>L: process(earn request)
    L->>L: calculate points with tier multiplier
    L->>L: evaluate auto tier change
    alt tier changed
        L->>EB: LoyaltyTierChangedEvent
        EB-->>N: subscriber notifies customer
    end
    L-->>UC: LoyaltyTransactionResult
```

## Inventory Reorder Rule

```mermaid
sequenceDiagram
    participant EB as DomainEventBus
    participant RE as RuleEngine
    participant IR as InventoryRulesEngine
    participant N as NotificationEngine

    EB->>RE: stock.changed event handler
    RE->>IR: evaluate(snapshot)
    IR-->>RE: InventoryRuleResult (alerts)
    RE->>RE: evaluate({available: 5})
    alt rule matched
        RE->>N: send(push, "Low Stock")
    end
```

## Workflow Approval (Return)

```mermaid
sequenceDiagram
    participant UC as ReturnUseCase
    participant W as WorkflowEngine
    participant A as AuthService

    UC->>W: start(return_approval, returnId)
    W-->>UC: WorkflowInstance (step 0)
    UC->>W: advance(instance, actorRole: cashier)
    W-->>UC: Error (forbidden)
    UC->>A: getCurrentRole()
    A-->>UC: manager
    UC->>W: advance(instance, actorRole: manager)
    W-->>UC: WorkflowInstance (step 2)
    UC->>W: advance(instance)
    W-->>UC: WorkflowInstance (completed)
```

## Number Generation

```mermaid
sequenceDiagram
    participant UC as CreateInvoiceUseCase
    participant NG as NumberGeneratorEngine
    participant SS as SequenceStore

    UC->>NG: next(invoice, tenantId, storeId)
    NG->>SS: nextSequence(tenantId, invoice)
    SS-->>NG: sequence (atomic)
    NG->>NG: format(prefix + date + padded)
    NG-->>UC: GeneratedNumber
```
