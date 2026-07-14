import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/features/system/data/datasources/system_remote_datasource.dart';
import 'package:fashion_pos_enterprise/features/system/data/sync/system_sync_processor.dart';
import 'package:fashion_pos_enterprise/features/system/domain/entities/feature_flag.dart';
import 'package:fashion_pos_enterprise/features/system/domain/entities/security.dart';

void main() {
  test('system sync processors map entity types to remote tables', () {
    final remote = SystemRemoteDataSource();
    expect(SystemSyncProcessor(remote: remote, entityTypeName: FeatureFlag.entityTypeName, remoteTable: 'feature_flags').entityType, 'feature_flag');
    expect(SystemSyncProcessor(remote: remote, entityTypeName: SecuritySession.entityTypeName, remoteTable: 'security_sessions').entityType, 'security_session');
  });
}
