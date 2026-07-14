import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/di/enterprise_providers.dart';
import 'package:fashion_pos_enterprise/features/treasury/presentation/providers/treasury_providers.dart';

final treasuryModuleInitializerProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final sync = ref.read(syncCoordinatorProvider);
    sync.registerProcessor(ref.read(cashBoxSyncProcessorProvider));
    sync.registerProcessor(ref.read(bankSyncProcessorProvider));
    sync.registerProcessor(ref.read(bankAccountSyncProcessorProvider));
    sync.registerProcessor(ref.read(pettyCashSyncProcessorProvider));
    sync.registerProcessor(ref.read(transferSyncProcessorProvider));
    sync.registerProcessor(ref.read(chequeSyncProcessorProvider));
    sync.registerProcessor(ref.read(chequeBookSyncProcessorProvider));
    sync.registerProcessor(ref.read(paymentVoucherSyncProcessorProvider));
    sync.registerProcessor(ref.read(receiptVoucherSyncProcessorProvider));
    sync.registerProcessor(ref.read(expenseRequestSyncProcessorProvider));
    sync.registerProcessor(ref.read(cashForecastSyncProcessorProvider));
    sync.registerProcessor(ref.read(bankReconciliationSyncProcessorProvider));
    sync.registerProcessor(ref.read(treasurySettingsSyncProcessorProvider));
    ref.read(treasuryIntegrationServiceProvider).register();
  };
});
