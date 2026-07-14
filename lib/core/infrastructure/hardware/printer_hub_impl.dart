import 'dart:async';

import 'package:fashion_pos_enterprise/core/infrastructure/hardware/barcode_abstraction.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/hardware/pdf_printer_adapter.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/hardware/printer_abstraction.dart';

/// Coordinates printer adapters — features must use this, not SDKs directly.
class PrinterHubImpl implements PrinterHub {
  PrinterHubImpl({
    required List<PrinterAdapter> adapters,
    BarcodeGenerator? labelGenerator,
  })  : _adapters = {for (final a in adapters) a.connectionType: a},
        _labelGenerator = labelGenerator;

  final Map<PrinterConnectionType, PrinterAdapter> _adapters;
  final BarcodeGenerator? _labelGenerator;
  PrinterAdapter? _active;
  final _statusController = StreamController<PrinterStatus>.broadcast();

  PdfPrinterAdapter? get pdfAdapter =>
      _adapters[PrinterConnectionType.pdf] is PdfPrinterAdapter
          ? _adapters[PrinterConnectionType.pdf] as PdfPrinterAdapter
          : null;

  @override
  Future<List<PrinterDevice>> discoverAll() async {
    final devices = <PrinterDevice>[];
    for (final adapter in _adapters.values) {
      devices.addAll(await adapter.discover());
    }
    return devices;
  }

  @override
  Future<void> connect(PrinterDevice device) async {
    final adapter = _adapters[device.connectionType];
    if (adapter == null) throw UnsupportedError('No adapter for ${device.connectionType}');
    await adapter.connect(device);
    _active = adapter;
    _statusController.add(PrinterStatus.ready);
  }

  @override
  Future<void> printReceipt(ReceiptDocument document) async {
    final adapter = _active;
    if (adapter == null) throw StateError('No printer connected');
    await adapter.printReceipt(document);
  }

  Future<void> printLabel({
    required String barcode,
    required String label,
    int copies = 1,
  }) async {
    final adapter = _active;
    if (adapter == null) throw StateError('No printer connected');
    await adapter.printLabel(barcode: barcode, label: label, copies: copies);
  }

  Future<List<int>> previewLabelImage(BarcodeLabelRequest request) async {
    final generator = _labelGenerator;
    if (generator == null) throw StateError('Label generator not configured');
    return generator.generateImage(request);
  }

  Future<List<int>> printLabelBatch(List<BarcodeLabelRequest> requests) async {
    final generator = _labelGenerator;
    if (generator == null) throw StateError('Label generator not configured');
    final pdf = await generator.generatePdfLabels(requests);
    final adapter = _active ?? _adapters[PrinterConnectionType.pdf];
    if (adapter != null) {
      await adapter.printPdf(pdf);
    }
    return pdf;
  }

  @override
  Stream<PrinterStatus> get statusStream => _statusController.stream;
}
