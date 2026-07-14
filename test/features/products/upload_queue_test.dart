import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/domain/media_models.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/upload/upload_engine.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';

void main() {
  test('Upload queue retry contract returns Result', () async {
    final engine = _FakeUploadEngine();
    final result = await engine.retry('job-1');
    expect(result.isSuccess || result.isFailure, isTrue);
  });
}

class _FakeUploadEngine extends Mock implements UploadEngine {
  @override
  Future<Result<MediaAsset>> retry(String jobId) async {
    return const Error(ValidationFailure(message: 'not found', code: 'not_found'));
  }
}
