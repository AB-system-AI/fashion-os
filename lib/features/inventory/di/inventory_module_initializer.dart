import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/di/enterprise_providers.dart';
import 'package:fashion_pos_enterprise/features/inventory/presentation/providers/inventory_providers.dart';

final inventoryModuleInitializerProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final sync = ref.read(syncCoordinatorProvider);
    sync.registerProcessor(ref.read(warehouseSyncProcessorProvider));
    sync.registerProcessor(ref.read(inventoryItemSyncProcessorProvider));
    sync.registerProcessor(ref.read(stockLevelSyncProcessorProvider));
    sync.registerProcessor(ref.read(stockMovementSyncProcessorProvider));
    sync.registerProcessor(ref.read(inventoryTransferSyncProcessorProvider));
    sync.registerProcessor(ref.read(stockCountSyncProcessorProvider));
  };
});
