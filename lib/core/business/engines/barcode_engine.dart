import 'package:fashion_pos_enterprise/core/business/domain/entities/rule_models.dart';
import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';

/// Generates EAN-13, Code128, QR payloads, and custom SKU barcodes.
class BarcodeEngine {
  Result<BarcodePayload> generate({
    required BarcodeFormat format,
    required String value,
    String? skuPrefix,
  }) {
    return switch (format) {
      BarcodeFormat.ean13 => _generateEan13(value),
      BarcodeFormat.code128 => _generateCode128(value),
      BarcodeFormat.qr => _generateQr(value),
      BarcodeFormat.customSku => _generateCustomSku(value, skuPrefix),
    };
  }

  Result<BarcodePayload> _generateEan13(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 12) {
      return const Error(ValidationFailure(message: 'EAN-13 base must be at most 12 digits', code: 'invalid_barcode'));
    }
    final padded = digits.padLeft(12, '0');
    final checkDigit = _ean13CheckDigit(padded);
    final full = '$padded$checkDigit';

    return Success(
      BarcodePayload(
        format: BarcodeFormat.ean13,
        value: full,
        displayValue: full,
        checkDigit: checkDigit.toString(),
        encodedData: full,
      ),
    );
  }

  Result<BarcodePayload> _generateCode128(String value) {
    if (value.isEmpty) {
      return const Error(ValidationFailure(message: 'Code128 value cannot be empty', code: 'invalid_barcode'));
    }
    final encoded = _code128Encode(value);
    return Success(
      BarcodePayload(
        format: BarcodeFormat.code128,
        value: value,
        displayValue: value,
        encodedData: encoded,
      ),
    );
  }

  Result<BarcodePayload> _generateQr(String value) {
    if (value.isEmpty) {
      return const Error(ValidationFailure(message: 'QR value cannot be empty', code: 'invalid_barcode'));
    }
    return Success(
      BarcodePayload(
        format: BarcodeFormat.qr,
        value: value,
        displayValue: value,
        encodedData: value,
      ),
    );
  }

  Result<BarcodePayload> _generateCustomSku(String value, String? prefix) {
    final sku = prefix != null ? '$prefix-$value' : value;
    if (sku.isEmpty) {
      return const Error(ValidationFailure(message: 'SKU cannot be empty', code: 'invalid_barcode'));
    }
    return Success(
      BarcodePayload(
        format: BarcodeFormat.customSku,
        value: sku,
        displayValue: sku,
        encodedData: sku,
      ),
    );
  }

  int _ean13CheckDigit(String twelveDigits) {
    var sum = 0;
    for (var i = 0; i < 12; i++) {
      final digit = int.parse(twelveDigits[i]);
      sum += i.isEven ? digit : digit * 3;
    }
    final mod = sum % 10;
    return mod == 0 ? 0 : 10 - mod;
  }

  String _code128Encode(String input) {
    const startB = 104;
    var checksum = startB;
    final codes = <int>[startB];

    for (var i = 0; i < input.length; i++) {
      final code = input.codeUnitAt(i) - 32;
      codes.add(code);
      checksum += code * (i + 1);
    }

    codes.add(checksum % 103);
    codes.add(106);
    return codes.map((c) => String.fromCharCode(c + 32)).join();
  }

  Result<bool> validateEan13(String barcode) {
    final digits = barcode.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 13) {
      return const Error(ValidationFailure(message: 'EAN-13 must be 13 digits', code: 'invalid_barcode'));
    }
    final expected = _ean13CheckDigit(digits.substring(0, 12));
    final actual = int.parse(digits[12]);
    return Success(expected == actual);
  }
}
