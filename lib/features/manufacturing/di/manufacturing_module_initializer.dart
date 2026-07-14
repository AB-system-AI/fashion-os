import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/di/enterprise_providers.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/presentation/providers/manufacturing_providers.dart';

final manufacturingModuleInitializerProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final sync = ref.read(syncCoordinatorProvider);
    sync.registerProcessor(ref.read(bomSyncProcessorProvider));
    sync.registerProcessor(ref.read(bomLineSyncProcessorProvider));
    sync.registerProcessor(ref.read(bomVersionSyncProcessorProvider));
    sync.registerProcessor(ref.read(productionSyncProcessorProvider));
    sync.registerProcessor(ref.read(workOrderSyncProcessorProvider));
    sync.registerProcessor(ref.read(materialIssueSyncProcessorProvider));
    sync.registerProcessor(ref.read(productionOutputSyncProcessorProvider));
    sync.registerProcessor(ref.read(qualityInspectionSyncProcessorProvider));
    sync.registerProcessor(ref.read(capacityPlanSyncProcessorProvider));
    ref.read(manufacturingIntegrationServiceProvider).register();
  };
});
