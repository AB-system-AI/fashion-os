/// Receipt content for thermal/PDF printer output.
class ReceiptDocument {
  const ReceiptDocument({
    required this.lines,
    this.logoBytes,
    this.qrCodeData,
    this.barcodeData,
    this.taxLines = const [],
    this.headerText,
    this.footerText,
  });

  final List<ReceiptLine> lines;
  final List<int>? logoBytes;
  final String? qrCodeData;
  final String? barcodeData;
  final List<ReceiptLine> taxLines;
  final String? headerText;
  final String? footerText;
}

class ReceiptLine {
  const ReceiptLine({
    required this.text,
    this.bold = false,
    this.align = ReceiptAlign.left,
    this.size = ReceiptTextSize.normal,
  });

  final String text;
  final bool bold;
  final ReceiptAlign align;
  final ReceiptTextSize size;
}

enum ReceiptAlign { left, center, right }

enum ReceiptTextSize { small, normal, large }

enum PrinterConnectionType { bluetooth, usb, wifi, pdf }

enum PrinterCategory { thermal, receipt, label }

enum PrinterStatus { disconnected, connecting, ready, printing, error }

class PrinterDevice {
  const PrinterDevice({
    required this.id,
    required this.name,
    required this.connectionType,
    required this.category,
    this.address,
  });

  final String id;
  final String name;
  final PrinterConnectionType connectionType;
  final PrinterCategory category;
  final String? address;
}

/// Thermal/receipt/label printer adapter — interfaces only.
abstract class PrinterAdapter {
  PrinterConnectionType get connectionType;
  PrinterCategory get category;

  Future<List<PrinterDevice>> discover();

  Future<void> connect(PrinterDevice device);

  Future<void> disconnect();

  Future<void> printReceipt(ReceiptDocument document);

  Future<void> printPdf(List<int> pdfBytes);

  Future<void> printLabel({
    required String barcode,
    required String label,
    int copies = 1,
  });

  Stream<PrinterStatus> get statusStream;
}

/// Coordinates printer adapters across Bluetooth, USB, WiFi, and PDF.
abstract class PrinterHub {
  Future<List<PrinterDevice>> discoverAll();

  Future<void> connect(PrinterDevice device);

  Future<void> printReceipt(ReceiptDocument document);

  Stream<PrinterStatus> get statusStream;
}
