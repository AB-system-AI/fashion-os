import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/di/enterprise_providers.dart';
import 'package:fashion_pos_enterprise/features/admin/presentation/providers/admin_providers.dart';

final adminModuleInitializerProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final sync = ref.read(syncCoordinatorProvider);
    sync.registerProcessor(ref.read(companySyncProcessorProvider));
    sync.registerProcessor(ref.read(branchSyncProcessorProvider));
    sync.registerProcessor(ref.read(storeSyncProcessorProvider));
    sync.registerProcessor(ref.read(warehouseAdminSyncProcessorProvider));
    sync.registerProcessor(ref.read(departmentSyncProcessorProvider));
    sync.registerProcessor(ref.read(teamSyncProcessorProvider));
    sync.registerProcessor(ref.read(businessUnitSyncProcessorProvider));
    sync.registerProcessor(ref.read(costCenterAdminSyncProcessorProvider));
    sync.registerProcessor(ref.read(adminUserSyncProcessorProvider));
    sync.registerProcessor(ref.read(roleTemplateSyncProcessorProvider));
    sync.registerProcessor(ref.read(userGroupSyncProcessorProvider));
    sync.registerProcessor(ref.read(permissionAssignmentUISyncProcessorProvider));
    sync.registerProcessor(ref.read(tenantSettingsSyncProcessorProvider));
    sync.registerProcessor(ref.read(tenantBrandingSyncProcessorProvider));
    sync.registerProcessor(ref.read(enterpriseSettingsSyncProcessorProvider));
    sync.registerProcessor(ref.read(licenseRecordSyncProcessorProvider));
    sync.registerProcessor(ref.read(subscriptionPlanSyncProcessorProvider));
    sync.registerProcessor(ref.read(usageSnapshotSyncProcessorProvider));
    sync.registerProcessor(ref.read(storageUsageSyncProcessorProvider));
    sync.registerProcessor(ref.read(apiUsageSyncProcessorProvider));
  };
});
