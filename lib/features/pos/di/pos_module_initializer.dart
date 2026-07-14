import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/di/enterprise_providers.dart';
import 'package:fashion_pos_enterprise/features/pos/presentation/providers/pos_providers.dart';

final posModuleInitializerProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final sync = ref.read(syncCoordinatorProvider);
    sync.registerProcessor(ref.read(salesSyncProcessorProvider));
    sync.registerProcessor(ref.read(paymentSyncProcessorProvider));
    sync.registerProcessor(ref.read(cashSessionSyncProcessorProvider));
    sync.registerProcessor(ref.read(receiptSyncProcessorProvider));
    sync.registerProcessor(ref.read(returnSyncProcessorProvider));
    sync.registerProcessor(ref.read(exchangeSyncProcessorProvider));
    sync.registerProcessor(ref.read(layawaySyncProcessorProvider));
    sync.registerProcessor(ref.read(couponSyncProcessorProvider));
    sync.registerProcessor(ref.read(suspendedSaleSyncProcessorProvider));
  };
});
