import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/di/enterprise_providers.dart';
import 'package:fashion_pos_enterprise/features/purchasing/presentation/providers/purchasing_providers.dart';

final purchasingModuleInitializerProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final sync = ref.read(syncCoordinatorProvider);
    sync.registerProcessor(ref.read(supplierSyncProcessorProvider));
    sync.registerProcessor(ref.read(purchaseOrderSyncProcessorProvider));
    sync.registerProcessor(ref.read(purchaseReceiptSyncProcessorProvider));
    sync.registerProcessor(ref.read(purchaseReturnSyncProcessorProvider));
    sync.registerProcessor(ref.read(supplierPaymentSyncProcessorProvider));
    sync.registerProcessor(ref.read(supplierStatementSyncProcessorProvider));
  };
});
