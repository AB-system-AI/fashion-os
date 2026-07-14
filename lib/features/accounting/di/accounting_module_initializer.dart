import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/di/enterprise_providers.dart';
import 'package:fashion_pos_enterprise/features/accounting/presentation/providers/accounting_providers.dart';

final accountingModuleInitializerProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final sync = ref.read(syncCoordinatorProvider);
    sync.registerProcessor(ref.read(accountingSyncProcessorProvider));
    sync.registerProcessor(ref.read(journalSyncProcessorProvider));
    sync.registerProcessor(ref.read(ledgerSyncProcessorProvider));
    sync.registerProcessor(ref.read(bankSyncProcessorProvider));
    sync.registerProcessor(ref.read(exchangeRateSyncProcessorProvider));
    sync.registerProcessor(ref.read(fiscalYearSyncProcessorProvider));
    ref.read(accountingIntegrationServiceProvider).register();
  };
});
