import 'dart:typed_data';

import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/domain/media_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/domain/media_models.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/processing/image_processor.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/security/media_security_service.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/network/network_state.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';

/// Automatic compression, resize, and format selection based on network quality.
class MediaOptimizer {
  MediaOptimizer({required ImageProcessor imageProcessor}) : _imageProcessor = imageProcessor;

  final ImageProcessor _imageProcessor;

  Result<ProcessedImage> optimizeForUpload({
    required Uint8List bytes,
    required UploadQualityProfile profile,
    required NetworkState network,
    bool generateThumbnail = false,
  }) {
    if (_isDocument(bytes)) {
      return Success(
        ProcessedImage(
          bytes: bytes,
          mimeType: _detectDocumentMime(bytes),
          width: 0,
          height: 0,
        ),
      );
    }

    final format = _selectFormat(network, profile);
    final dimensions = _selectDimensions(profile, network);
    final quality = _selectQuality(profile, network);

    final operations = <ImageOperation>[
      ImageOperation.autoOrient,
      ImageOperation.resize,
      ImageOperation.compress,
      if (generateThumbnail) ImageOperation.thumbnail,
    ];

    return _imageProcessor.process(
      ImageProcessRequest(
        bytes: bytes,
        operations: operations,
        maxWidth: dimensions.$1,
        maxHeight: dimensions.$2,
        outputFormat: format,
        quality: quality,
      ),
    );
  }

  (int?, int?) _selectDimensions(UploadQualityProfile profile, NetworkState network) {
    if (profile == UploadQualityProfile.original && network.quality.index >= 2) {
      return (null, null);
    }
    return switch (profile) {
      UploadQualityProfile.low => (800, 800),
      UploadQualityProfile.standard => (1280, 1280),
      UploadQualityProfile.high => (1920, 1920),
      UploadQualityProfile.original => (2560, 2560),
    };
  }

  int _selectQuality(UploadQualityProfile profile, NetworkState network) {
    if (!network.isOnline || network.quality.index <= 1) {
      return switch (profile) {
        UploadQualityProfile.low => 60,
        UploadQualityProfile.standard => 70,
        _ => 75,
      };
    }
    return switch (profile) {
      UploadQualityProfile.low => 70,
      UploadQualityProfile.standard => 82,
      UploadQualityProfile.high => 90,
      UploadQualityProfile.original => 95,
    };
  }

  ImageFormat _selectFormat(NetworkState network, UploadQualityProfile profile) {
    if (profile == UploadQualityProfile.original) return ImageFormat.png;
    if (!network.isOnline) return ImageFormat.jpeg;
    return ImageFormat.webp;
  }

  bool _isDocument(Uint8List bytes) {
    if (bytes.length < 4) return false;
    if (bytes[0] == 0x25 && bytes[1] == 0x50) return true;
    if (bytes[0] == 0x50 && bytes[1] == 0x4B) return true;
    final header = String.fromCharCodes(bytes.take(20));
    return header.contains(',') || header.trim().startsWith('{');
  }

  String _detectDocumentMime(Uint8List bytes) {
    if (bytes.length >= 4 && bytes[0] == 0x25 && bytes[1] == 0x50) return 'application/pdf';
    if (bytes.length >= 4 && bytes[0] == 0x50 && bytes[1] == 0x4B) {
      return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    }
    final header = String.fromCharCodes(bytes.take(20));
    if (header.contains(',')) return 'text/csv';
    return 'application/octet-stream';
  }
}
