import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/media/document/document_engine.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/domain/media_enums.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';

void main() {
  group('DocumentEngine', () {
    late DocumentEngine engine;

    setUp(() {
      engine = DocumentEngine();
    });

    test('detects CSV document', () {
      final bytes = Uint8List.fromList('name,price\nshirt,10'.codeUnits);
      final result = engine.process(bytes: bytes, filename: 'catalog.csv');
      expect((result as Success).data.documentType, DocumentType.csv);
    });

    test('creates backup archive', () {
      final result = engine.createBackupArchive({
        'meta.json': Uint8List.fromList('{}'.codeUnits),
        'data.csv': Uint8List.fromList('a,b'.codeUnits),
      });
      expect(result.isSuccess, isTrue);
      expect((result as Success<Uint8List>).data.length, greaterThan(0));
    });

    test('rejects empty backup', () {
      expect(engine.createBackupArchive({}).isFailure, isTrue);
    });
  });
}
