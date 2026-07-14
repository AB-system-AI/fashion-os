import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/di/enterprise_providers.dart';
import 'package:fashion_pos_enterprise/features/assets/presentation/providers/assets_providers.dart';

final assetsModuleInitializerProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final sync = ref.read(syncCoordinatorProvider);
    sync.registerProcessor(ref.read(assetSyncProcessorProvider));
    sync.registerProcessor(ref.read(assetCategorySyncProcessorProvider));
    sync.registerProcessor(ref.read(assetLocationSyncProcessorProvider));
    sync.registerProcessor(ref.read(assetDepreciationSyncProcessorProvider));
    sync.registerProcessor(ref.read(assetTransferSyncProcessorProvider));
    sync.registerProcessor(ref.read(assetDisposalSyncProcessorProvider));
    sync.registerProcessor(ref.read(maintenanceRequestSyncProcessorProvider));
    sync.registerProcessor(ref.read(maintenanceScheduleSyncProcessorProvider));
    sync.registerProcessor(ref.read(maintenanceTaskSyncProcessorProvider));
    sync.registerProcessor(ref.read(maintenanceCostSyncProcessorProvider));
    sync.registerProcessor(ref.read(serviceContractSyncProcessorProvider));
    sync.registerProcessor(ref.read(warrantySyncProcessorProvider));
    sync.registerProcessor(ref.read(assetAuditSyncProcessorProvider));
    sync.registerProcessor(ref.read(assetSettingsSyncProcessorProvider));
    ref.read(assetIntegrationServiceProvider).register();
  };
});
