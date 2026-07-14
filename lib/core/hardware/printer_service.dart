/// Receipt content for thermal printer output.
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

enum PrinterConnectionType { bluetooth, usb, wifi }

enum PrinterStatus { disconnected, connecting, ready, printing, error }

/// Adapter interface for thermal receipt printers.
abstract class ThermalPrinterAdapter {
  PrinterConnectionType get connectionType;

  Future<List<PrinterDevice>> discover();

  Future<void> connect(PrinterDevice device);

  Future<void> disconnect();

  Future<void> printReceipt(ReceiptDocument document);

  Future<void> printBarcodeLabel({
    required String barcode,
    required String label,
    int copies = 1,
  });

  Stream<PrinterStatus> get statusStream;
}

class PrinterDevice {
  const PrinterDevice({
    required this.id,
    required this.name,
    required this.connectionType,
    this.address,
  });

  final String id;
  final String name;
  final PrinterConnectionType connectionType;
  final String? address;
}

/// Coordinates printer adapters (Bluetooth, USB, WiFi).
class PrinterService {
  PrinterService({required List<ThermalPrinterAdapter> adapters})
      : _adapters = {for (final a in adapters) a.connectionType: a};

  final Map<PrinterConnectionType, ThermalPrinterAdapter> _adapters;
  ThermalPrinterAdapter? _active;

  List<PrinterConnectionType> get supportedTypes => _adapters.keys.toList();

  ThermalPrinterAdapter? adapterFor(PrinterConnectionType type) => _adapters[type];

  Future<List<PrinterDevice>> discoverAll() async {
    final devices = <PrinterDevice>[];
    for (final adapter in _adapters.values) {
      devices.addAll(await adapter.discover());
    }
    return devices;
  }

  Future<void> connect(PrinterDevice device) async {
    final adapter = _adapters[device.connectionType];
    if (adapter == null) {
      throw UnsupportedError('No adapter for ${device.connectionType}');
    }
    await adapter.connect(device);
    _active = adapter;
  }

  Future<void> printReceipt(ReceiptDocument document) async {
    final adapter = _active;
    if (adapter == null) {
      throw StateError('No printer connected');
    }
    await adapter.printReceipt(document);
  }

  Stream<PrinterStatus> get statusStream =>
      _active?.statusStream ?? Stream.value(PrinterStatus.disconnected);
}
