import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/conflict_resolver.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/entity_sync_processor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ConflictResolver', () {
    late ConflictResolver resolver;

    setUp(() {
      resolver = ConflictResolver(defaultStrategy: ConflictResolutionStrategy.serverWins);
    });

    test('serverWins returns server payload', () {
      const conflict = SyncConflict(
        entityType: 'product',
        entityId: 'p1',
        clientPayload: {'name': 'Client'},
        serverPayload: {'name': 'Server'},
        clientVersion: 1,
        serverVersion: 2,
      );
      final result = resolver.resolve(conflict);
      expect(result.resolvedPayload['name'], 'Server');
      expect(result.requiresManualReview, false);
    });

    test('lastWriteWins picks newer updated_at', () {
      resolver = ConflictResolver(defaultStrategy: ConflictResolutionStrategy.lastWriteWins);
      final conflict = SyncConflict(
        entityType: 'product',
        entityId: 'p1',
        clientPayload: {
          'name': 'Client',
          'updated_at': DateTime.utc(2026, 1, 1).toIso8601String(),
        },
        serverPayload: {
          'name': 'Server',
          'updated_at': DateTime.utc(2026, 6, 1).toIso8601String(),
        },
        clientVersion: 1,
        serverVersion: 2,
      );
      final result = resolver.resolve(conflict);
      expect(result.resolvedPayload['name'], 'Server');
    });

    test('manualMerge requires review', () {
      resolver = ConflictResolver(defaultStrategy: ConflictResolutionStrategy.manualMerge);
      const conflict = SyncConflict(
        entityType: 'product',
        entityId: 'p1',
        clientPayload: {'name': 'Client'},
        serverPayload: {'name': 'Server'},
        clientVersion: 1,
        serverVersion: 2,
      );
      final result = resolver.resolve(conflict);
      expect(result.requiresManualReview, true);
    });
  });
}
