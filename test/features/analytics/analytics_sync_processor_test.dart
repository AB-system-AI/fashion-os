import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/features/analytics/data/datasources/analytics_remote_datasource.dart';
import 'package:fashion_pos_enterprise/features/analytics/data/sync/analytics_sync_processor.dart';
import 'package:fashion_pos_enterprise/features/analytics/domain/entities/dashboard.dart';
import 'package:fashion_pos_enterprise/features/analytics/domain/entities/report.dart';

void main() {
  test('analytics sync processors map entity types to remote tables', () {
    final remote = AnalyticsRemoteDataSource();
    final report = AnalyticsSyncProcessor(
      remote: remote,
      entityTypeName: ReportDefinition.entityTypeName,
      remoteTable: 'report_definitions',
    );
    final template = AnalyticsSyncProcessor(
      remote: remote,
      entityTypeName: ReportTemplate.entityTypeName,
      remoteTable: 'report_templates',
    );
    final layout = AnalyticsSyncProcessor(
      remote: remote,
      entityTypeName: DashboardLayout.entityTypeName,
      remoteTable: 'dashboard_layouts',
    );
    final kpi = AnalyticsSyncProcessor(
      remote: remote,
      entityTypeName: KpiSnapshot.entityTypeName,
      remoteTable: 'kpi_snapshots',
    );

    expect(report.entityType, 'report_definition');
    expect(template.entityType, 'report_template');
    expect(layout.entityType, 'dashboard_layout');
    expect(kpi.entityType, 'kpi_snapshot');
  });
}
