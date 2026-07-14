import 'dart:typed_data';

import 'package:image/image.dart' as img;

import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/domain/media_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/domain/media_models.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';

/// Raster image processing: resize, compress, crop, rotate, format conversion.
class ImageProcessor {
  Result<ProcessedImage> process(ImageProcessRequest request) {
    if (_isSvg(request.bytes)) {
      return Success(
        ProcessedImage(
          bytes: request.bytes,
          mimeType: 'image/svg+xml',
          width: 0,
          height: 0,
        ),
      );
    }

    final decoded = img.decodeImage(request.bytes);
    if (decoded == null) {
      return const Error(ValidationFailure(message: 'Unsupported image format', code: 'invalid_image'));
    }

    var image = decoded;
    if (request.operations.contains(ImageOperation.autoOrient)) {
      image = img.bakeOrientation(image);
    }
    if (request.rotationDegrees != 0 || request.operations.contains(ImageOperation.rotate)) {
      image = img.copyRotate(image, angle: request.rotationDegrees.toDouble());
    }
    if (request.cropRect != null || request.operations.contains(ImageOperation.crop)) {
      final rect = request.cropRect;
      if (rect != null) {
        image = img.copyCrop(
          image,
          x: rect.x,
          y: rect.y,
          width: rect.width,
          height: rect.height,
        );
      }
    }
    if (request.maxWidth != null ||
        request.maxHeight != null ||
        request.operations.contains(ImageOperation.resize) ||
        request.operations.contains(ImageOperation.compress)) {
      image = img.copyResize(
        image,
        width: request.maxWidth,
        height: request.maxHeight,
        maintainAspect: true,
      );
    }

    final encodeResult = _encode(image, request.outputFormat, request.quality);
    if (encodeResult.isFailure) return Error(encodeResult.failureOrNull!);

    Uint8List? thumbBytes;
    String? thumbMime;
    if (request.operations.contains(ImageOperation.thumbnail)) {
      final thumb = img.copyResize(image, width: request.thumbnailSize, height: request.thumbnailSize);
      final thumbEncoded = _encode(thumb, ImageFormat.webp, 75);
      if (thumbEncoded.isSuccess) {
        thumbBytes = (thumbEncoded as Success<({Uint8List bytes, String mime})>).data.bytes;
        thumbMime = (thumbEncoded as Success<({Uint8List bytes, String mime})>).data.mime;
      }
    }

    final encoded = (encodeResult as Success<({Uint8List bytes, String mime})>).data;
    return Success(
      ProcessedImage(
        bytes: encoded.bytes,
        mimeType: encoded.mime,
        width: image.width,
        height: image.height,
        thumbnailBytes: thumbBytes,
        thumbnailMimeType: thumbMime,
      ),
    );
  }

  Result<({Uint8List bytes, String mime})> _encode(img.Image image, ImageFormat format, int quality) {
    return switch (format) {
      ImageFormat.jpeg => Success((bytes: Uint8List.fromList(img.encodeJpg(image, quality: quality)), mime: 'image/jpeg')),
      ImageFormat.png => Success((bytes: Uint8List.fromList(img.encodePng(image)), mime: 'image/png')),
      ImageFormat.webp => Success((bytes: Uint8List.fromList(img.encodeWebP(image, quality: quality)), mime: 'image/webp')),
      ImageFormat.svg => const Error(ValidationFailure(message: 'Cannot encode raster to SVG', code: 'invalid_format')),
      ImageFormat.avif => const Error(ValidationFailure(message: 'AVIF not yet supported', code: 'format_unsupported')),
    };
  }

  bool _isSvg(Uint8List bytes) {
    if (bytes.length < 5) return false;
    final header = String.fromCharCodes(bytes.take(100)).toLowerCase();
    return header.contains('<svg');
  }
}
