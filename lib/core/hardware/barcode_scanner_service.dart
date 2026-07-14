import 'dart:async';

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

enum BarcodeScanSource { camera, usbScanner, bluetoothScanner, manualEntry }

/// Adapter for hardware/software barcode input channels.
abstract class BarcodeScannerAdapter {
  BarcodeScanSource get source;

  Future<void> start();

  Future<void> stop();

  Stream<BarcodeScanResult> get scanStream;
}

/// Barcode generation request for label printing.
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

/// Coordinates camera, USB HID, Bluetooth, and manual barcode entry.
class BarcodeScannerService {
  BarcodeScannerService({required List<BarcodeScannerAdapter> adapters})
      : _adapters = adapters;

  final List<BarcodeScannerAdapter> _adapters;
  final _outputController = StreamController<BarcodeScanResult>.broadcast();
  final List<StreamSubscription<BarcodeScanResult>> _subscriptions = [];

  Stream<BarcodeScanResult> get scanStream => _outputController.stream;

  Future<void> startAll() async {
    for (final adapter in _adapters) {
      await adapter.start();
      _subscriptions.add(
        adapter.scanStream.listen(_outputController.add),
      );
    }
  }

  Future<void> stopAll() async {
    for (final sub in _subscriptions) {
      await sub.cancel();
    }
    _subscriptions.clear();
    for (final adapter in _adapters) {
      await adapter.stop();
    }
  }

  BarcodeScanResult manualEntry(String value) {
    final result = BarcodeScanResult(
      value: value.trim(),
      source: BarcodeScanSource.manualEntry,
      scannedAt: DateTime.now().toUtc(),
    );
    _outputController.add(result);
    return result;
  }

  Future<void> dispose() async {
    await stopAll();
    await _outputController.close();
  }
}
