# Product Catalog — Barcode Labels

Barcode label generation and printing use the **hardware abstraction layer** — no direct printer SDK calls.

## Architecture

```
BarcodeLabelPage (UI)
  → BarcodeLabelPrintService (domain)
    → BarcodeEngine (value generation / validation)
    → PrinterHubImpl (discovery, connect, print)
      → PdfPrinterAdapter (preview / PDF output)
      → BarcodeLabelGeneratorImpl (PNG / PDF labels)
    → AuditService (barcode_generate, barcode_print)
```

## Layouts

| Layout | Description |
|--------|-------------|
| `standard` | Product name, SKU, barcode, price |
| `compact` | Reduced label (same generator, compact styling) |
| `qr` | QR code format via `BarcodeFormat.qr` |

## Formats

- Code 128 (default)
- EAN-13
- QR Code

## Features

- **Preview** — PNG image rendered in UI (`previewLabel`)
- **Print** — PDF batch via `printLabelBatch` (supports all variants)
- **Batch printing** — one label per variant when enabled
- **Copies** — configurable copies per label
- **Offline** — generation works offline (local `BarcodeEngine` + `BarcodeLabelGeneratorImpl`)

## Route

`/products/:id/labels`

## Audit events

| Event | `metadata.change_type` |
|-------|------------------------|
| Preview / generate | `barcode_generate` |
| Print | `barcode_print` |

## Extending printers

Add a new `PrinterAdapter` implementation and register it in `printerHubProvider`. Features continue to call `PrinterHubImpl` only.
