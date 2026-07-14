/// Barcode scan result from any input source.
class BarcodeScanResult {
  const BarcodeScanResult({
    required this.value,
    required this.source,
    this.format,
    this.scannedAt,
  });

  final String value;
  final BarcodeScanSource source;
  final String? format;
  final DateTime? scannedAt;
}

enum BarcodeScanSource {
  camera,
  usbScanner,
  bluetoothScanner,
  manualEntry,
  nfc,
}

/// Adapter for hardware/software barcode input channels.
abstract class BarcodeScannerAdapter {
  BarcodeScanSource get source;

  Future<void> start();

  Future<void> stop();

  Stream<BarcodeScanResult> get scanStream;
}

/// Barcode label generation request.
class BarcodeLabelRequest {
  const BarcodeLabelRequest({
    required this.value,
    required this.productName,
    this.format = 'code128',
    this.price,
    this.sku,
    this.copies = 1,
  });

  final String value;
  final String productName;
  final String format;
  final double? price;
  final String? sku;
  final int copies;
}

/// Barcode generator contract for label printing.
abstract class BarcodeGenerator {
  Future<List<int>> generateImage(BarcodeLabelRequest request);
  Future<List<int>> generatePdfLabels(List<BarcodeLabelRequest> requests);
}

/// Coordinates scanner adapters — no hardware implementation in infrastructure.
abstract class BarcodeScannerHub {
  Stream<BarcodeScanResult> get scanStream;

  Future<void> startAll();

  Future<void> stopAll();

  BarcodeScanResult manualEntry(String value);

  Future<void> dispose();
}
