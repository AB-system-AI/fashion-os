import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/logging/app_logger.dart';

/// Remote product API — isolated from presentation layer.
class ProductRemoteDataSource {
  ProductRemoteDataSource({SupabaseClient? client}) : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<void> push({
    required SyncOperation operation,
    required Map<String, dynamic> payload,
  }) async {
    final table = _client.from('products');
    switch (operation) {
      case SyncOperation.create:
        await table.insert(payload);
      case SyncOperation.update:
      case SyncOperation.restore:
        await table.upsert(payload);
      case SyncOperation.delete:
        await table.update({'deleted_at': DateTime.now().toUtc().toIso8601String()}).eq('id', payload['id']);
    }
    AppLogger.debug('Product remote push: ${operation.value} ${payload['id']}');
  }

  Future<List<Map<String, dynamic>>> pullDelta({required String tenantId, required DateTime since}) async {
    final rows = await _client
        .from('products')
        .select()
        .eq('tenant_id', tenantId)
        .gte('updated_at', since.toIso8601String());
    return List<Map<String, dynamic>>.from(rows as List);
  }
}
