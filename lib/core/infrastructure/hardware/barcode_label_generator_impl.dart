import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:qr/qr.dart';

import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/business/engines/barcode_engine.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/hardware/barcode_abstraction.dart';

/// Infrastructure barcode label image/PDF generator.
class BarcodeLabelGeneratorImpl implements BarcodeGenerator {
  BarcodeLabelGeneratorImpl({BarcodeEngine? barcodeEngine}) : _barcode = barcodeEngine ?? BarcodeEngine();

  final BarcodeEngine _barcode;

  @override
  Future<List<int>> generateImage(BarcodeLabelRequest request) async {
    final format = _parseFormat(request.format);
    final payload = _barcode.generate(format: format, value: request.value);
    if (payload.isFailure) {
      throw StateError(payload.failureOrNull?.message ?? 'Barcode generation failed');
    }

    if (format == BarcodeFormat.qr) {
      return _generateQrPng(request.value);
    }

    final data = payload.dataOrNull!;
    final image = img.Image(width: 400, height: 160);
    img.fill(image, color: img.ColorRgb8(255, 255, 255));
    img.drawString(image, data.displayValue, font: img.arial24, x: 20, y: 20);
    if (request.productName.isNotEmpty) {
      img.drawString(image, request.productName, font: img.arial14, x: 20, y: 70);
    }
    if (request.sku != null) {
      img.drawString(image, 'SKU: ${request.sku}', font: img.arial14, x: 20, y: 95);
    }
    if (request.price != null) {
      img.drawString(image, '\$${request.price!.toStringAsFixed(2)}', font: img.arial14, x: 20, y: 120);
    }
    return img.encodePng(image);
  }

  @override
  Future<List<int>> generatePdfLabels(List<BarcodeLabelRequest> requests) async {
    final buffer = StringBuffer()
      ..writeln('%PDF-1.4')
      ..writeln('1 0 obj<</Type/Catalog/Pages 2 0 R>>endobj')
      ..writeln('2 0 obj<</Type/Pages/Kids[3 0 R]/Count 1>>endobj')
      ..writeln('3 0 obj<</Type/Page/Parent 2 0 R/MediaBox[0 0 612 792]/Contents 4 0 R>>endobj');

    final lines = <String>[];
    for (final request in requests) {
      for (var i = 0; i < request.copies; i++) {
        lines.add('${request.productName} | ${request.sku ?? ''} | ${request.value} | ${request.price ?? ''}');
      }
    }
    final content = lines.join('\\n');
    buffer
      ..writeln('4 0 obj<</Length ${content.length + 40}>>stream')
      ..writeln('BT /F1 10 Tf 40 750 Td ($content) Tj ET')
      ..writeln('endstream endobj')
      ..writeln('xref')
      ..writeln('0 5')
      ..writeln('trailer<</Size 5/Root 1 0 R>>')
      ..writeln('startxref')
      ..writeln('%%EOF');
    return Uint8List.fromList(buffer.toString().codeUnits);
  }

  BarcodeFormat _parseFormat(String format) => switch (format.toLowerCase()) {
        'ean13' => BarcodeFormat.ean13,
        'qr' => BarcodeFormat.qr,
        _ => BarcodeFormat.code128,
      };

  List<int> _generateQrPng(String data) {
    final qrCode = QrCode.fromData(data: data, errorCorrectLevel: QrErrorCorrectLevel.M);
    final qrImage = QrImage(qrCode);
    const size = 200;
    final image = img.Image(width: size, height: size);
    final moduleSize = size ~/ qrImage.moduleCount;
    for (var x = 0; x < qrImage.moduleCount; x++) {
      for (var y = 0; y < qrImage.moduleCount; y++) {
        final color = qrImage.isDark(y, x) ? img.ColorRgb8(0, 0, 0) : img.ColorRgb8(255, 255, 255);
        img.fillRect(image, x1: x * moduleSize, y1: y * moduleSize, x2: (x + 1) * moduleSize, y2: (y + 1) * moduleSize, color: color);
      }
    }
    return img.encodePng(image);
  }
}
