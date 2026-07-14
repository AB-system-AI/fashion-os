import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/logging/app_logger.dart';

class AdminRemoteDataSource {
  AdminRemoteDataSource({SupabaseClient? client}) : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<void> push({
    required String table,
    required SyncOperation operation,
    required Map<String, dynamic> payload,
  }) async {
    final query = _client.from(table);
    switch (operation) {
      case SyncOperation.create:
        await query.insert(payload);
      case SyncOperation.update:
      case SyncOperation.restore:
        await query.upsert(payload);
      case SyncOperation.delete:
        await query.update({'deleted_at': DateTime.now().toUtc().toIso8601String()}).eq('id', payload['id']);
    }
    AppLogger.debug('Admin remote push: $table ${operation.value} ${payload['id']}');
  }

  Future<List<Map<String, dynamic>>> pullDelta({
    required String table,
    required String tenantId,
    required DateTime since,
  }) async {
    final rows = await _client.from(table).select().eq('tenant_id', tenantId).gte('updated_at', since.toIso8601String());
    return List<Map<String, dynamic>>.from(rows as List);
  }
}
