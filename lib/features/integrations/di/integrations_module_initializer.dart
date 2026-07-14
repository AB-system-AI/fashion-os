import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/di/enterprise_providers.dart';
import 'package:fashion_pos_enterprise/features/integrations/presentation/providers/integrations_providers.dart';

final integrationsModuleInitializerProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final sync = ref.read(syncCoordinatorProvider);
    sync.registerProcessor(ref.read(integrationConnectorSyncProcessorProvider));
    sync.registerProcessor(ref.read(webhookSyncProcessorProvider));
    sync.registerProcessor(ref.read(apiKeySyncProcessorProvider));
    sync.registerProcessor(ref.read(integrationLogSyncProcessorProvider));
    sync.registerProcessor(ref.read(importJobSyncProcessorProvider));
    sync.registerProcessor(ref.read(exportJobSyncProcessorProvider));
    sync.registerProcessor(ref.read(oauthConnectionSyncProcessorProvider));
    sync.registerProcessor(ref.read(printerProfileSyncProcessorProvider));
    ref.read(integrationsCrossModuleServiceProvider).register();
  };
});
