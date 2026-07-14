import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/di/enterprise_providers.dart';
import 'package:fashion_pos_enterprise/features/system/presentation/providers/system_providers.dart';

final systemModuleInitializerProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final sync = ref.read(syncCoordinatorProvider);
    sync.registerProcessor(ref.read(featureFlagSyncProcessorProvider));
    sync.registerProcessor(ref.read(systemAuditSyncProcessorProvider));
    sync.registerProcessor(ref.read(roleDefinitionSyncProcessorProvider));
    sync.registerProcessor(ref.read(permissionAssignmentSyncProcessorProvider));
    sync.registerProcessor(ref.read(systemHealthSyncProcessorProvider));
    sync.registerProcessor(ref.read(errorLogSyncProcessorProvider));
    sync.registerProcessor(ref.read(backgroundJobSyncProcessorProvider));
    sync.registerProcessor(ref.read(syncMonitorSyncProcessorProvider));
    sync.registerProcessor(ref.read(storageMonitorSyncProcessorProvider));
    sync.registerProcessor(ref.read(licenseRecordSyncProcessorProvider));
    sync.registerProcessor(ref.read(subscriptionRecordSyncProcessorProvider));
    sync.registerProcessor(ref.read(environmentSettingSyncProcessorProvider));
    sync.registerProcessor(ref.read(securitySessionSyncProcessorProvider));
    sync.registerProcessor(ref.read(deviceRegistrationSyncProcessorProvider));
    sync.registerProcessor(ref.read(loginHistorySyncProcessorProvider));
    sync.registerProcessor(ref.read(maintenanceModeSyncProcessorProvider));
    sync.registerProcessor(ref.read(systemConfigurationSyncProcessorProvider));
    sync.registerProcessor(ref.read(releaseNoteSyncProcessorProvider));
    sync.registerProcessor(ref.read(migrationHistorySyncProcessorProvider));
  };
});
