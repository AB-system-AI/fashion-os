# Bill of Materials (BOM)

## Entities

- `BillOfMaterial` — header (finished product, quantity, type)
- `BomLine` — component lines with consumption method and scrap %
- `BomVersion` — effective-dated versions

## BOM types

`standard`, `phantom`, `engineering` (see `BomType` enum).

## Consumption methods

`manual`, `backflush`, `picklist` (see `ConsumptionMethod`).

## Engine: BOM explosion

`ManufacturingEngine.explodeBom` scales line quantities by order qty, applies scrap, and recursively explodes sub-BOMs when `subBomsByProduct` is provided.

## Service

`BomService` — create/update BOM, lines, versions; audits all mutations.

## Sync

- Entity: `bill_of_material` → `bills_of_materials`
- Entity: `bom_version` → `bom_versions`
- Lines stored as `bom_line` records locally

## Permissions

`bom.manage`, `manufacturing.view`
