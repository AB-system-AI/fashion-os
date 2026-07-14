import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/features/customers/data/sync/customer_sync_processor.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/entities/customer.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/entities/customer_wallet.dart';

void main() {
  test('customer sync entity type mapping', () {
    expect(Customer.entityTypeName, 'customer');
    expect(CustomerWallet.entityTypeName, 'customer_wallet');
    expect(CustomerSyncProcessor, isNotNull);
  });
}
