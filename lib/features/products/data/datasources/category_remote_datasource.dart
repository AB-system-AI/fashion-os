import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/logging/app_logger.dart';

/// Remote category API.
class CategoryRemoteDataSource {
  CategoryRemoteDataSource({SupabaseClient? client}) : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<void> push({
    required SyncOperation operation,
    required Map<String, dynamic> payload,
    required String tenantId,
  }) async {
    final enriched = {...payload, 'tenant_id': tenantId, 'updated_at': DateTime.now().toUtc().toIso8601String()};
    final table = _client.from('categories');
    switch (operation) {
      case SyncOperation.create:
        await table.insert(enriched);
      case SyncOperation.update:
      case SyncOperation.restore:
        await table.upsert(enriched);
      case SyncOperation.delete:
        await table.update({'deleted_at': DateTime.now().toUtc().toIso8601String()}).eq('id', payload['id']);
    }
    AppLogger.debug('Category remote push: ${operation.value} ${payload['id']}');
  }

  Future<List<Map<String, dynamic>>> pullDelta({required String tenantId, required DateTime since}) async {
    final rows = await _client
        .from('categories')
        .select()
        .eq('tenant_id', tenantId)
        .gte('updated_at', since.toIso8601String());
    return List<Map<String, dynamic>>.from(rows as List);
  }
}
