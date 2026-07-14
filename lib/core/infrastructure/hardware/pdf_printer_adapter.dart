import 'dart:async';

import 'package:fashion_pos_enterprise/core/infrastructure/hardware/printer_abstraction.dart';

/// PDF preview printer — no hardware SDK, writes PDF bytes for preview/share.
class PdfPrinterAdapter implements PrinterAdapter {
  PdfPrinterAdapter();

  final _statusController = StreamController<PrinterStatus>.broadcast();
  List<int>? _lastPdfBytes;
  PrinterDevice? _connected;

  List<int>? get lastPdfBytes => _lastPdfBytes;

  @override
  PrinterConnectionType get connectionType => PrinterConnectionType.pdf;

  @override
  PrinterCategory get category => PrinterCategory.label;

  @override
  Future<List<PrinterDevice>> discover() async => [
        const PrinterDevice(
          id: 'pdf-preview',
          name: 'PDF Preview',
          connectionType: PrinterConnectionType.pdf,
          category: PrinterCategory.label,
        ),
      ];

  @override
  Future<void> connect(PrinterDevice device) async {
    _connected = device;
    _statusController.add(PrinterStatus.ready);
  }

  @override
  Future<void> disconnect() async {
    _connected = null;
    _statusController.add(PrinterStatus.disconnected);
  }

  @override
  Future<void> printReceipt(ReceiptDocument document) async {
    _statusController.add(PrinterStatus.printing);
    _lastPdfBytes = _buildReceiptPdf(document);
    _statusController.add(PrinterStatus.ready);
  }

  @override
  Future<void> printPdf(List<int> pdfBytes) async {
    _statusController.add(PrinterStatus.printing);
    _lastPdfBytes = pdfBytes;
    _statusController.add(PrinterStatus.ready);
  }

  @override
  Future<void> printLabel({
    required String barcode,
    required String label,
    int copies = 1,
  }) async {
    _statusController.add(PrinterStatus.printing);
    _lastPdfBytes = _buildLabelPdf(barcode: barcode, label: label, copies: copies);
    _statusController.add(PrinterStatus.ready);
  }

  @override
  Stream<PrinterStatus> get statusStream => _statusController.stream;

  List<int> _buildLabelPdf({required String barcode, required String label, int copies}) {
    final content = List.generate(copies, (_) => '$label | $barcode').join('\\n');
    return '%PDF-1.4\n1 0 obj<</Type/Catalog/Pages 2 0 R>>endobj\n2 0 obj<</Type/Pages/Kids[3 0 R]/Count 1>>endobj\n3 0 obj<</Type/Page/Parent 2 0 R/MediaBox[0 0 612 792]/Contents 4 0 R>>endobj\n4 0 obj<</Length ${content.length + 20}>>stream\nBT /F1 10 Tf 40 750 Td ($content) Tj ET\nendstream endobj\n%%EOF'
        .codeUnits;
  }

  List<int> _buildReceiptPdf(ReceiptDocument document) {
    final lines = document.lines.map((l) => l.text).join('\\n');
    return '%PDF-1.4\n...$lines...'.codeUnits;
  }
}
