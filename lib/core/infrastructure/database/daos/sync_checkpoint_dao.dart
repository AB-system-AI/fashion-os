import 'package:drift/drift.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/database/tables.dart';

part of 'app_database.dart';

@DriftAccessor(tables: [SyncCheckpoints])
class SyncCheckpointDao extends DatabaseAccessor<AppDatabase> with _$SyncCheckpointDaoMixin {
  SyncCheckpointDao(super.db);

  Future<SyncCheckpoint?> getCheckpoint({
    required String deviceId,
    required String entityType,
  }) {
    return (select(syncCheckpoints)
          ..where((t) => t.deviceId.equals(deviceId))
          ..where((t) => t.entityType.equals(entityType))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<void> upsertCheckpoint(SyncCheckpointsCompanion checkpoint) {
    return into(syncCheckpoints).insert(checkpoint, mode: InsertMode.insertOrReplace);
  }

  Future<List<SyncCheckpoint>> getAllForDevice(String deviceId) {
    return (select(syncCheckpoints)..where((t) => t.deviceId.equals(deviceId))).get();
  }
}
