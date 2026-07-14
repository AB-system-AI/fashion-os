import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/business/engines/barcode_engine.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BarcodeEngine', () {
    late BarcodeEngine engine;

    setUp(() {
      engine = BarcodeEngine();
    });

    test('generates valid EAN-13 with check digit', () {
      final result = engine.generate(format: BarcodeFormat.ean13, value: '590123412345');
      final payload = (result as Success).data;
      expect(payload.value, hasLength(13));
      expect(payload.checkDigit, isNotNull);

      final valid = engine.validateEan13(payload.value);
      expect((valid as Success<bool>).data, isTrue);
    });

    test('generates Code128 payload', () {
      final result = engine.generate(format: BarcodeFormat.code128, value: 'SKU-001');
      expect((result as Success).data.encodedData, isNotEmpty);
    });

    test('generates custom SKU with prefix', () {
      final result = engine.generate(
        format: BarcodeFormat.customSku,
        value: '001',
        skuPrefix: 'FSH',
      );
      expect((result as Success).data.value, 'FSH-001');
    });

    test('rejects empty QR value', () {
      final result = engine.generate(format: BarcodeFormat.qr, value: '');
      expect(result.isFailure, isTrue);
    });
  });
}
