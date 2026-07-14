import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:qr/qr.dart';

import 'package:fashion_pos_enterprise/core/business/domain/entities/rule_models.dart';
import 'package:fashion_pos_enterprise/core/business/engines/barcode_engine.dart';
import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/domain/media_enums.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';

/// Generates QR and barcode raster images as media-ready byte payloads.
class MediaBarcodeGenerator {
  MediaBarcodeGenerator({BarcodeEngine? barcodeEngine}) : _barcodeEngine = barcodeEngine ?? BarcodeEngine();

  final BarcodeEngine _barcodeEngine;

  Result<({Uint8List bytes, String mimeType, MediaCategory category})> generateQrImage({
    required String data,
    int size = 256,
  }) {
    if (data.isEmpty) {
      return const Error(ValidationFailure(message: 'QR data cannot be empty', code: 'invalid_qr'));
    }

    final qrCode = QrCode.fromData(data: data, errorCorrectLevel: QrErrorCorrectLevel.M);
    final qrImage = QrImage(qrCode);
    final image = img.Image(width: size, height: size);
    final moduleSize = size ~/ qrImage.moduleCount;

    for (var x = 0; x < qrImage.moduleCount; x++) {
      for (var y = 0; y < qrImage.moduleCount; y++) {
        final isDark = qrImage.isDark(y, x);
        final color = isDark ? img.ColorRgb8(0, 0, 0) : img.ColorRgb8(255, 255, 255);
        img.fillRect(
          image,
          x1: x * moduleSize,
          y1: y * moduleSize,
          x2: (x + 1) * moduleSize,
          y2: (y + 1) * moduleSize,
          color: color,
        );
      }
    }

    return Success((bytes: Uint8List.fromList(img.encodePng(image)), mimeType: 'image/png', category: MediaCategory.qr));
  }

  Future<Result<({Uint8List bytes, String mimeType, MediaCategory category})>> generateBarcodeImage({
    required BarcodeFormat format,
    required String value,
  }) async {
    final payload = _barcodeEngine.generate(format: format, value: value);
    if (payload.isFailure) return Error(payload.failureOrNull!);

    final data = (payload as Success<BarcodePayload>).data;
    final text = data.displayValue;
    final image = img.Image(width: 400, height: 120);
    img.fill(image, color: img.ColorRgb8(255, 255, 255));
    img.drawString(image, text, font: img.arial24, x: 20, y: 40);

    return Success((
      bytes: Uint8List.fromList(img.encodePng(image)),
      mimeType: 'image/png',
      category: MediaCategory.barcode,
    ));
  }
}
