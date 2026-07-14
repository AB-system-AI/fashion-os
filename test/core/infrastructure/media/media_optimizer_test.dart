import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'package:fashion_pos_enterprise/core/infrastructure/media/domain/media_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/optimization/media_optimizer.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/processing/image_processor.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/network/network_state.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';

void main() {
  group('MediaOptimizer', () {
    late MediaOptimizer optimizer;
    late Uint8List sample;

    setUp(() {
      optimizer = MediaOptimizer(imageProcessor: ImageProcessor());
      final image = img.Image(width: 800, height: 600);
      sample = Uint8List.fromList(img.encodePng(image));
    });

    test('compresses on poor network', () {
      final result = optimizer.optimizeForUpload(
        bytes: sample,
        profile: UploadQualityProfile.standard,
        network: const NetworkState(
          isOnline: true,
          connectionType: NetworkConnectionType.mobile,
          quality: NetworkQuality.poor,
        ),
      );
      expect(result.isSuccess, isTrue);
      final processed = (result as Success).data;
      expect(processed.bytes.length, lessThan(sample.length));
    });
  });
}
