import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/di/infrastructure_providers.dart';
import 'package:fashion_pos_enterprise/features/products/presentation/providers/product_providers.dart';

/// Registers product sync processors with the sync coordinator.
final productModuleInitializerProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final sync = ref.read(syncCoordinatorProvider);
    sync.registerProcessor(ref.read(productSyncProcessorProvider));
    sync.registerProcessor(ref.read(categorySyncProcessorProvider));
    sync.registerProcessor(ref.read(brandSyncProcessorProvider));
  };
});
