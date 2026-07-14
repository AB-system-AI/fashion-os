import 'package:fashion_pos_enterprise/core/business/engines/validation_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ValidationEngine', () {
    late ValidationEngine engine;

    setUp(() {
      engine = ValidationEngine();
    });

    test('detects duplicate barcode', () {
      final result = engine.validateDuplicateBarcode(
        barcode: '1234567890123',
        existingBarcodes: {'1234567890123'},
      );
      expect(result.isFailure, isTrue);
    });

    test('accepts unique barcode', () {
      final result = engine.validateDuplicateBarcode(
        barcode: '9999999999999',
        existingBarcodes: {'1234567890123'},
      );
      expect(result.isSuccess, isTrue);
    });

    test('rejects negative stock', () {
      expect(engine.validateStock(-1).isFailure, isTrue);
      expect(engine.validateStock(0).isSuccess, isTrue);
    });

    test('rejects blocked customer', () {
      expect(engine.validateCustomer(isBlocked: true).isFailure, isTrue);
      expect(engine.validateCustomer(isBlocked: false).isSuccess, isTrue);
    });

    test('validateAll stops on first failure', () {
      final result = engine.validateAll([
        engine.validatePrice(10),
        engine.validateStock(-5),
        engine.validatePrice(20),
      ]);
      expect(result.isFailure, isTrue);
    });
  });
}
