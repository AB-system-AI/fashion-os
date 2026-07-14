import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/di/enterprise_providers.dart';
import 'package:fashion_pos_enterprise/features/sales/presentation/providers/sales_providers.dart';

final salesModuleInitializerProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final sync = ref.read(syncCoordinatorProvider);
    sync.registerProcessor(ref.read(quotationSyncProcessorProvider));
    sync.registerProcessor(ref.read(quotationLineSyncProcessorProvider));
    sync.registerProcessor(ref.read(salesOrderSyncProcessorProvider));
    sync.registerProcessor(ref.read(salesOrderLineSyncProcessorProvider));
    sync.registerProcessor(ref.read(salesReservationSyncProcessorProvider));
    sync.registerProcessor(ref.read(backOrderSyncProcessorProvider));
    sync.registerProcessor(ref.read(shipmentSyncProcessorProvider));
    sync.registerProcessor(ref.read(shipmentLineSyncProcessorProvider));
    sync.registerProcessor(ref.read(deliverySyncProcessorProvider));
    sync.registerProcessor(ref.read(deliveryLineSyncProcessorProvider));
    sync.registerProcessor(ref.read(returnSyncProcessorProvider));
    sync.registerProcessor(ref.read(exchangeSyncProcessorProvider));
    sync.registerProcessor(ref.read(customerTimelineSyncProcessorProvider));
    sync.registerProcessor(ref.read(salesSettingsSyncProcessorProvider));
    ref.read(salesIntegrationServiceProvider).register();
  };
});
