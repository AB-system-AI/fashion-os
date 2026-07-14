# Product Catalog Architecture

## Clean architecture map

```mermaid
flowchart TB
  UI[Presentation Pages] --> CTRL[Riverpod Controllers]
  CTRL --> SVC[ProductCatalogService]
  SVC --> REPO[ProductRepository]
  SVC --> VAL[ValidationEngine]
  SVC --> PRICE[PricingEngine]
  SVC --> BAR[BarcodeEngine]
  SVC --> NUM[NumberGeneratorEngine]
  SVC --> MED[MediaEngine]
  SVC --> AUD[AuditService]
  SVC --> PERM[PermissionEngine]
  SVC --> SEARCH[ProductSearchService]
  SVC --> BUS[DomainEventBus]
  REPO --> DRIFT[(Drift syncable_records)]
  REPO --> QUEUE[SyncQueueWriter]
  QUEUE --> SYNC[SyncCoordinator]
  SYNC --> PROC[ProductSyncProcessor]
  PROC --> REMOTE[Supabase products]
```

## Sequence: Create product

```mermaid
sequenceDiagram
  participant Page as ProductFormPage
  participant Svc as ProductCatalogService
  participant Perm as PermissionEngine
  participant Val as ValidationEngine
  participant Repo as ProductRepository
  participant Audit as AuditService
  participant Bus as DomainEventBus

  Page->>Svc: createProduct(user, draft)
  Svc->>Perm: require(product.create)
  Svc->>Val: validate price, SKU, barcode
  Svc->>Repo: create(product)
  Repo->>Repo: persist Drift + enqueue sync
  Svc->>Audit: log create
  Svc->>Bus: ProductUpdatedEvent
  Svc-->>Page: Success(product)
```

## Sequence: Offline sync

```mermaid
sequenceDiagram
  participant Repo as ProductRepository
  participant Queue as SyncQueueWriter
  participant Coord as SyncCoordinator
  participant Proc as ProductSyncProcessor
  participant API as ProductRemoteDataSource

  Repo->>Queue: enqueue(create/update/delete)
  Note over Repo,Queue: Works offline
  Coord->>Queue: drain when online
  Coord->>Proc: push(queueItem)
  Proc->>API: push to Supabase
```

## Design system integration

Phase 4 extends `lib/design_system/` with catalog-specific components (semantic buttons, product cards, search/filter inputs, dialogs, sheets, data table, state widgets). UI pages consume these exports via `design_system.dart` — no duplicate button or card implementations in the feature module.

## Permissions

| Code | Usage |
|------|-------|
| `product.read` | List and detail screens |
| `product.create` | New product form |
| `product.update` | Edit, restore, media |
| `product.delete` | Soft delete |
| `product.import` / `product.export` | Import page |
| `product.bulk` | Bulk archive |
| `category.*` / `brand.*` | Taxonomy screens |

## Audit events

`ProductCatalogService` logs create, update, delete, restore, import, export, and metadata for price/barcode/media changes through `AuditService`.
