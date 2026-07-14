import 'package:fashion_pos_enterprise/core/business/validators/business_validators.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';

/// Aggregates all business validators into a single entry point.
class ValidationEngine {
  ValidationEngine({
    BusinessValidators? validators,
  }) : _validators = validators ?? BusinessValidators();

  final BusinessValidators _validators;

  Result<void> validateDuplicateBarcode({required String barcode, required Set<String> existingBarcodes}) {
    return _validators.validateDuplicateBarcode(barcode: barcode, existingBarcodes: existingBarcodes);
  }

  Result<void> validateDuplicateSku({required String sku, required Set<String> existingSkus}) {
    return _validators.validateDuplicateSku(sku: sku, existingSkus: existingSkus);
  }

  Result<void> validatePrice(double price) => _validators.validatePrice(price);

  Result<void> validateStock(double quantity) => _validators.validateStock(quantity);

  Result<void> validateEmployee({required bool isActive}) => _validators.validateEmployee(isActive: isActive);

  Result<void> validateCustomer({required bool isBlocked}) => _validators.validateCustomer(isBlocked: isBlocked);

  Result<void> validateDiscount({required double percent}) => _validators.validateDiscount(percent: percent);

  Result<void> validateCoupon({required bool isValid}) => _validators.validateCoupon(isValid: isValid);

  Result<void> validateTaxRate({required double rate}) => _validators.validateTaxRate(rate);

  Result<void> validatePayment({required double amount, required double due}) {
    return _validators.validatePayment(amount: amount, due: due);
  }

  Result<void> validateAll(List<Result<void>> results) {
    for (final result in results) {
      if (result.isFailure) return result;
    }
    return const Success(null);
  }
}
