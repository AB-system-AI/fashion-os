import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';

/// Reusable business rule validators — no UI or repository dependencies.
class BusinessValidators {
  Result<void> validateDuplicateBarcode({
    required String barcode,
    required Set<String> existingBarcodes,
  }) {
    if (barcode.trim().isEmpty) {
      return const Error(ValidationFailure(message: 'Barcode cannot be empty', code: 'duplicate_barcode'));
    }
    if (existingBarcodes.contains(barcode)) {
      return Error(ValidationFailure(message: 'Barcode already exists: $barcode', code: 'duplicate_barcode'));
    }
    return const Success(null);
  }

  Result<void> validateDuplicateSku({
    required String sku,
    required Set<String> existingSkus,
  }) {
    if (sku.trim().isEmpty) {
      return const Error(ValidationFailure(message: 'SKU cannot be empty', code: 'duplicate_sku'));
    }
    if (existingSkus.contains(sku)) {
      return Error(ValidationFailure(message: 'SKU already exists: $sku', code: 'duplicate_sku'));
    }
    return const Success(null);
  }

  Result<void> validatePrice(double price) {
    if (price < 0) {
      return const Error(ValidationFailure(message: 'Price cannot be negative', code: 'invalid_price'));
    }
    return const Success(null);
  }

  Result<void> validateStock(double quantity) {
    if (quantity < 0) {
      return const Error(ValidationFailure(message: 'Stock cannot be negative', code: 'negative_stock'));
    }
    return const Success(null);
  }

  Result<void> validateEmployee({required bool isActive}) {
    if (!isActive) {
      return const Error(ValidationFailure(message: 'Employee is inactive', code: 'inactive_employee'));
    }
    return const Success(null);
  }

  Result<void> validateCustomer({required bool isBlocked}) {
    if (isBlocked) {
      return const Error(ValidationFailure(message: 'Customer is blocked', code: 'blocked_customer'));
    }
    return const Success(null);
  }

  Result<void> validateDiscount({required double percent}) {
    if (percent <= 0 || percent > 100) {
      return const Error(ValidationFailure(message: 'Discount must be between 0 and 100', code: 'invalid_discount'));
    }
    return const Success(null);
  }

  Result<void> validateCoupon({required bool isValid}) {
    if (!isValid) {
      return const Error(ValidationFailure(message: 'Invalid or expired coupon', code: 'invalid_coupon'));
    }
    return const Success(null);
  }

  Result<void> validateTaxRate(double rate) {
    if (rate < 0 || rate > 100) {
      return const Error(ValidationFailure(message: 'Tax rate must be between 0 and 100', code: 'invalid_tax'));
    }
    return const Success(null);
  }

  Result<void> validatePayment({required double amount, required double due}) {
    if (amount <= 0) {
      return const Error(ValidationFailure(message: 'Payment amount must be positive', code: 'invalid_payment'));
    }
    if (amount > due + 0.01) {
      return const Error(ValidationFailure(message: 'Payment exceeds amount due', code: 'invalid_payment'));
    }
    return const Success(null);
  }
}
