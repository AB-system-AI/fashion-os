import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/di/enterprise_providers.dart';
import 'package:fashion_pos_enterprise/features/customers/presentation/providers/customer_providers.dart';

final customersModuleInitializerProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final sync = ref.read(syncCoordinatorProvider);
    sync.registerProcessor(ref.read(customerSyncProcessorProvider));
    sync.registerProcessor(ref.read(customerGroupSyncProcessorProvider));
    sync.registerProcessor(ref.read(customerLoyaltyAccountSyncProcessorProvider));
    sync.registerProcessor(ref.read(loyaltyPointTransactionSyncProcessorProvider));
    sync.registerProcessor(ref.read(customerWalletSyncProcessorProvider));
    sync.registerProcessor(ref.read(customerCreditSyncProcessorProvider));
    sync.registerProcessor(ref.read(customerActivitySyncProcessorProvider));
  };
});
