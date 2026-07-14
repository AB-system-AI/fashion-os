import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/business/contracts/sequence_store.dart';
import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/business/engines/number_generator_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/treasury/treasury_engine.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/value_objects/treasury_value_objects.dart';

void main() {
  test('transfer validation passes with sufficient balance', () {
    final engine = TreasuryEngine();
    final result = engine.validateTransfer(
      input: const TransferInput(fromAccountId: 'cash', toAccountId: 'bank', amount: 100),
      fromBalance: 500,
    );
    expect(result.isValid, isTrue);
  });

  test('number generator produces payment voucher numbers', () async {
    final generator = NumberGeneratorEngine(InMemorySequenceStore());
    final number = await generator.next(type: DocumentNumberType.paymentVoucher, tenantId: 'tenant-1');
    expect(number.isSuccess, isTrue);
    expect(number.dataOrNull!.value.startsWith('PV-'), isTrue);
  });

  test('number generator produces transfer numbers', () async {
    final generator = NumberGeneratorEngine(InMemorySequenceStore());
    final number = await generator.next(type: DocumentNumberType.transfer, tenantId: 'tenant-1');
    expect(number.isSuccess, isTrue);
    expect(number.dataOrNull!.value.startsWith('TRF-'), isTrue);
  });
}
