import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'package:fashion_pos_enterprise/core/infrastructure/media/domain/media_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/processing/image_processor.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/domain/media_models.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';

void main() {
  group('ImageProcessor', () {
    late ImageProcessor processor;
    late Uint8List samplePng;

    setUp(() {
      processor = ImageProcessor();
      final image = img.Image(width: 200, height: 100, backgroundColor: img.ColorRgb8(255, 0, 0));
      samplePng = Uint8List.fromList(img.encodePng(image));
    });

    test('resizes image', () {
      final result = processor.process(
        ImageProcessRequest(
          bytes: samplePng,
          operations: const [ImageOperation.resize],
          maxWidth: 50,
          outputFormat: ImageFormat.webp,
        ),
      );
      expect(result.isSuccess, isTrue);
      final data = (result as Success<ProcessedImage>).data;
      expect(data.width, lessThanOrEqualTo(50));
      expect(data.mimeType, 'image/webp');
    });

    test('rejects AVIF encoding', () {
      final result = processor.process(
        ImageProcessRequest(bytes: samplePng, outputFormat: ImageFormat.avif),
      );
      expect(result.isFailure, isTrue);
    });
  });
}
