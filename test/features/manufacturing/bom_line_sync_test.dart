import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/features/manufacturing/data/datasources/manufacturing_remote_datasource.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/data/sync/manufacturing_sync_processor.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/entities/bom.dart';

void main() {
  test('bom_line sync processor maps to bom_lines table', () {
    final remote = ManufacturingRemoteDataSource();
    final processor = ManufacturingSyncProcessor(
      remote: remote,
      entityTypeName: BomLine.entityTypeName,
      remoteTable: 'bom_lines',
    );
    expect(processor.entityType, 'bom_line');
  });
}
