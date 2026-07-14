import 'package:uuid/uuid.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_action.dart';
import 'package:fashion_pos_enterprise/core/audit/audit_service.dart';
import 'package:fashion_pos_enterprise/core/business/engines/analytics/analytics_engine.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/import_export/import_export_service.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/pagination/paginated_result.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_engine.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/services/accounting_services.dart';
import 'package:fashion_pos_enterprise/features/analytics/domain/entities/dashboard.dart';
import 'package:fashion_pos_enterprise/features/analytics/domain/entities/report.dart';
import 'package:fashion_pos_enterprise/features/analytics/domain/enums/analytics_enums.dart';
import 'package:fashion_pos_enterprise/features/analytics/domain/repositories/analytics_repositories.dart';
import 'package:fashion_pos_enterprise/features/analytics/domain/value_objects/analytics_value_objects.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/services/customer_analytics_service.dart';
import 'package:fashion_pos_enterprise/features/hr/domain/repositories/hr_repositories.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/repositories/inventory_repositories.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/services/manufacturing_services.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/enums/pos_enums.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/repositories/sale_repository.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/services/purchasing_report_service.dart';

class DashboardBundle {
  const DashboardBundle({required this.title, required this.metrics, this.series = const []});

  final String title;
  final List<MetricValue> metrics;
  final List<ChartSeries> series;
}

class KpiBundle {
  const KpiBundle({required this.category, required this.metrics});

  final KpiCategory category;
  final List<MetricValue> metrics;
}

class DashboardService {
  DashboardService({
    required AnalyticsEngine engine,
    required PermissionEngine permissions,
    required SaleRepository sales,
    required StockLevelRepository stockLevels,
    required PurchasingReportService purchasingReports,
    required CustomerAnalyticsService customerAnalytics,
    required FinancialReportService financialReports,
    required EmployeeRepository employees,
    required ManufacturingReportService manufacturingReports,
    required AnalyticsSnapshotRepository snapshots,
    Uuid? uuid,
  })  : _engine = engine,
        _permissions = permissions,
        _sales = sales,
        _stock = stockLevels,
        _purchasing = purchasingReports,
        _crm = customerAnalytics,
        _financial = financialReports,
        _employees = employees,
        _manufacturing = manufacturingReports,
        _snapshots = snapshots,
        _uuid = uuid ?? const Uuid();

  final AnalyticsEngine _engine;
  final PermissionEngine _permissions;
  final SaleRepository _sales;
  final StockLevelRepository _stock;
  final PurchasingReportService _purchasing;
  final CustomerAnalyticsService _crm;
  final FinancialReportService _financial;
  final EmployeeRepository _employees;
  final ManufacturingReportService _manufacturing;
  final AnalyticsSnapshotRepository _snapshots;
  final Uuid _uuid;

  Future<Result<DashboardBundle>> executive({required AuthUser user}) async {
    try {
      _permissions.require(user, ExecutiveDashboardPermissions.view);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final tenantId = user.tenantId!;
    final salesBundle = await sales(user: user);
    final invBundle = await inventory(user: user);
    final mfgBundle = await manufacturing(user: user);
    final revenue = salesBundle.dataOrNull?.metrics.firstWhere((m) => m.label == 'Revenue', orElse: () => const MetricValue(label: 'Revenue', value: 0)).value ?? 0;
    final summary = _engine.buildExecutiveSummary(
      revenue: revenue,
      cogs: revenue * 0.4,
      inventoryValue: invBundle.dataOrNull?.metrics.firstWhere((m) => m.label == 'Inventory Value', orElse: () => const MetricValue(label: 'Inventory Value', value: 0)).value ?? 0,
      payrollCost: 0,
      productionEfficiency: mfgBundle.dataOrNull?.metrics.firstOrNull?.value ?? 0,
      customerCount: (await _crm.topCustomers(tenantId, limit: 1000)).length,
    );
    await _snapshots.create(AnalyticsSnapshot(
      id: _uuid.v4(),
      tenantId: tenantId,
      snapshotType: 'executive',
      metrics: {'revenue': summary.revenue, 'grossProfit': summary.grossProfit},
      version: 1,
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    return Success(DashboardBundle(
      title: 'Executive',
      metrics: [
        MetricValue(label: 'Revenue', value: summary.revenue, unit: 'USD'),
        MetricValue(label: 'Gross Profit', value: summary.grossProfit, unit: 'USD'),
        MetricValue(label: 'Inventory Value', value: summary.inventoryValue, unit: 'USD'),
        MetricValue(label: 'Production Efficiency', value: summary.productionEfficiency, unit: '%'),
        MetricValue(label: 'Customers', value: summary.customerCount.toDouble()),
      ],
    ));
  }

  Future<Result<DashboardBundle>> sales({required AuthUser user}) async {
    try {
      _permissions.require(user, AnalyticsPermissions.view);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final tenantId = user.tenantId!;
    final completed = await _sales.listByStatus(tenantId, SaleStatus.completed);
    final revenue = completed.fold<double>(0, (s, sale) => s + sale.grandTotal);
    final refunds = await _sales.listByStatus(tenantId, SaleStatus.refunded);
    final refundTotal = refunds.fold<double>(0, (s, sale) => s + sale.grandTotal);
    final aov = _engine.averageOrderValue(revenue: revenue, orderCount: completed.length);
    final margin = _engine.marginPercent(revenue: revenue, cost: revenue * 0.55);
    return Success(DashboardBundle(
      title: 'Sales',
      metrics: [
        MetricValue(label: 'Revenue', value: revenue, unit: 'USD'),
        MetricValue(label: 'Orders', value: completed.length.toDouble()),
        MetricValue(label: 'AOV', value: aov, unit: 'USD'),
        MetricValue(label: 'Margin', value: margin, unit: '%'),
        MetricValue(label: 'Refund Rate', value: _engine.refundRate(refundTotal: refundTotal, revenue: revenue), unit: '%'),
      ],
    ));
  }

  Future<Result<DashboardBundle>> inventory({required AuthUser user}) async {
    try {
      _permissions.require(user, AnalyticsPermissions.view);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final page = await _stock.getPage(RepositoryQuery(tenantId: user.tenantId!, pageSize: 1000));
    final totalValue = page.items.fold<double>(0, (s, l) => s + (l.onHand * 1));
    final lowStock = page.items.where((l) => l.minimumLevel != null && l.onHand <= l.minimumLevel!).length;
    return Success(DashboardBundle(
      title: 'Inventory',
      metrics: [
        MetricValue(label: 'Inventory Value', value: totalValue, unit: 'USD'),
        MetricValue(label: 'SKUs', value: page.items.length.toDouble()),
        MetricValue(label: 'Low Stock', value: lowStock.toDouble()),
        MetricValue(label: 'Reserved', value: page.items.fold<double>(0, (s, l) => s + l.reserved)),
      ],
    ));
  }

  Future<Result<DashboardBundle>> purchasing({required AuthUser user}) async {
    try {
      _permissions.require(user, AnalyticsPermissions.view);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final tenantId = user.tenantId!;
    final outstanding = await _purchasing.outstandingOrders(tenantId);
    final top = await _purchasing.topSuppliers(tenantId, limit: 5);
    return Success(DashboardBundle(
      title: 'Purchasing',
      metrics: [
        MetricValue(label: 'Outstanding POs', value: outstanding.length.toDouble()),
        MetricValue(label: 'Top Supplier Spend', value: top.isEmpty ? 0 : top.first.totalPurchases, unit: 'USD'),
        MetricValue(label: 'Receivings', value: (await _purchasing.receivingCount(tenantId)).toDouble()),
      ],
    ));
  }

  Future<Result<DashboardBundle>> crm({required AuthUser user}) async {
    try {
      _permissions.require(user, AnalyticsPermissions.view);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final tenantId = user.tenantId!;
    final wallet = await _crm.totalWalletBalances(tenantId);
    final credit = await _crm.totalOutstandingCredit(tenantId);
    final loyalty = await _crm.totalLoyaltyPoints(tenantId);
    final inactive = await _crm.inactiveCustomers(tenantId);
    return Success(DashboardBundle(
      title: 'CRM',
      metrics: [
        MetricValue(label: 'Wallet Balance', value: wallet, unit: 'USD'),
        MetricValue(label: 'Credit Exposure', value: credit, unit: 'USD'),
        MetricValue(label: 'Loyalty Points', value: loyalty.toDouble()),
        MetricValue(label: 'Inactive Customers', value: inactive.length.toDouble()),
      ],
    ));
  }

  Future<Result<DashboardBundle>> accounting({required AuthUser user}) async {
    try {
      _permissions.require(user, AnalyticsPermissions.view);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final tenantId = user.tenantId!;
    final income = await _financial.incomeStatement(user: user, tenantId: tenantId);
    final balance = await _financial.balanceSheet(user: user, tenantId: tenantId);
    if (income.isFailure) return Error(income.failureOrNull!);
    return Success(DashboardBundle(
      title: 'Accounting',
      metrics: [
        MetricValue(label: 'Net Profit', value: income.dataOrNull!.netIncome, unit: 'USD'),
        MetricValue(label: 'Total Assets', value: balance.dataOrNull?.totalAssets ?? 0, unit: 'USD'),
      ],
    ));
  }

  Future<Result<DashboardBundle>> hr({required AuthUser user}) async {
    try {
      _permissions.require(user, AnalyticsPermissions.view);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final page = await _employees.getPage(RepositoryQuery(tenantId: user.tenantId!, pageSize: 500));
    return Success(DashboardBundle(
      title: 'HR',
      metrics: [
        MetricValue(label: 'Employees', value: page.items.length.toDouble()),
      ],
    ));
  }

  Future<Result<DashboardBundle>> manufacturing({required AuthUser user}) async {
    try {
      _permissions.require(user, AnalyticsPermissions.view);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final report = await _manufacturing.generate(user: user, tenantId: user.tenantId!);
    return Success(DashboardBundle(
      title: 'Manufacturing',
      metrics: [
        MetricValue(label: 'Production Efficiency', value: report.productionEfficiencyPercent, unit: '%'),
        MetricValue(label: 'Yield', value: report.yieldPercent, unit: '%'),
        MetricValue(label: 'Scrap', value: report.scrapPercent, unit: '%'),
        MetricValue(label: 'In Progress', value: report.ordersInProgress.toDouble()),
      ],
    ));
  }
}

class ReportDefinitionService {
  ReportDefinitionService({
    required ReportRepository repository,
    required AuditService audit,
    required PermissionEngine permissions,
    Uuid? uuid,
  })  : _repo = repository,
        _audit = audit,
        _permissions = permissions,
        _uuid = uuid ?? const Uuid();

  final ReportRepository _repo;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final Uuid _uuid;

  Future<Result<ReportDefinition>> create({required AuthUser user, required ReportDefinition draft}) async {
    try {
      _permissions.require(user, ReportPermissions.create);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final now = DateTime.now().toUtc();
    final entity = ReportDefinition(
      id: draft.id.isEmpty ? _uuid.v4() : draft.id,
      tenantId: user.tenantId!,
      name: draft.name,
      module: draft.module,
      description: draft.description,
      status: draft.status,
      filters: draft.filters,
      columns: draft.columns,
      groupBy: draft.groupBy,
      sortBy: draft.sortBy,
      templateId: draft.templateId,
      createdBy: user.employeeId,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );
    final saved = await _repo.create(entity);
    await _audit.log(action: AuditAction.create, entityType: ReportDefinition.entityTypeName, tenantId: saved.tenantId, employeeId: user.employeeId, entityId: saved.id);
    return Success(saved);
  }

  Future<PaginatedResult<ReportDefinition>> list(String tenantId, {String? module}) async {
    if (module != null) return _repo.listByModule(tenantId, module);
    return _repo.getPage(RepositoryQuery(tenantId: tenantId, pageSize: 200));
  }

  Future<Result<ReportDefinition>> archive({required AuthUser user, required ReportDefinition report}) async {
    try {
      _permissions.require(user, ReportPermissions.create);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final now = DateTime.now().toUtc();
    final saved = await _repo.update(report.copyWith(
      status: ReportStatus.archived,
      version: report.version + 1,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
      deletedAt: now,
    ));
    await _audit.log(action: AuditAction.delete, entityType: ReportDefinition.entityTypeName, tenantId: saved.tenantId, employeeId: user.employeeId, entityId: saved.id);
    return Success(saved);
  }
}

class KpiService {
  KpiService({
    required AnalyticsEngine engine,
    required KpiSnapshotRepository repository,
    required DashboardService dashboardService,
    required PermissionEngine permissions,
    Uuid? uuid,
  })  : _engine = engine,
        _repo = repository,
        _dashboards = dashboardService,
        _permissions = permissions,
        _uuid = uuid ?? const Uuid();

  final AnalyticsEngine _engine;
  final KpiSnapshotRepository _repo;
  final DashboardService _dashboards;
  final PermissionEngine _permissions;
  final Uuid _uuid;

  Future<Result<KpiBundle>> captureCategory({required AuthUser user, required KpiCategory category}) async {
    try {
      _permissions.require(user, KpiPermissions.view);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final bundle = switch (category) {
      KpiCategory.sales => await _dashboards.sales(user: user),
      KpiCategory.inventory => await _dashboards.inventory(user: user),
      KpiCategory.purchasing => await _dashboards.purchasing(user: user),
      KpiCategory.crm => await _dashboards.crm(user: user),
      KpiCategory.accounting => await _dashboards.accounting(user: user),
      KpiCategory.hr => await _dashboards.hr(user: user),
      KpiCategory.manufacturing => await _dashboards.manufacturing(user: user),
    };
    if (bundle.isFailure) return Error(bundle.failureOrNull!);
    final now = DateTime.now().toUtc();
    for (final m in bundle.dataOrNull!.metrics) {
      await _repo.create(KpiSnapshot(
        id: _uuid.v4(),
        tenantId: user.tenantId!,
        category: category,
        kpiCode: m.label,
        value: m.value,
        unit: m.unit,
        periodStart: now.subtract(const Duration(days: 30)),
        periodEnd: now,
        version: 1,
        createdAt: now,
        updatedAt: now,
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ));
    }
    return Success(KpiBundle(category: category, metrics: bundle.dataOrNull!.metrics));
  }
}

class AnalyticsExportService {
  AnalyticsExportService({
    required ImportExportService importExport,
    required ReportRepository reports,
    required AuditService audit,
    required PermissionEngine permissions,
    Uuid? uuid,
  })  : _importExport = importExport,
        _reports = reports,
        _audit = audit,
        _permissions = permissions,
        _uuid = uuid ?? const Uuid();

  final ImportExportService _importExport;
  final ReportRepository _reports;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final Uuid _uuid;

  Future<Result<ExportPayload>> exportReport({
    required AuthUser user,
    required ReportDefinition report,
    required ExportFormatType format,
    required List<Map<String, dynamic>> rows,
  }) async {
    try {
      _permissions.require(user, ReportPermissions.export);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final payload = switch (format) {
      ExportFormatType.csv => await _importExport.exportCsv(entityType: report.module, rows: rows),
      ExportFormatType.excel => await _importExport.exportExcel(entityType: report.module, rows: rows),
      ExportFormatType.pdf => await _importExport.exportPdfCatalog(
          title: '${report.name}\nGenerated ${DateTime.now().toUtc().toIso8601String()}',
          rows: rows,
        ),
    };
    final now = DateTime.now().toUtc();
    await _reports.createExport(ReportExport(
      id: _uuid.v4(),
      tenantId: user.tenantId!,
      reportId: report.id,
      format: format,
      fileName: payload.fileName,
      filtersUsed: report.filters,
      generatedBy: user.employeeId,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    await _audit.log(action: AuditAction.create, entityType: ReportExport.entityTypeName, tenantId: user.tenantId, employeeId: user.employeeId, entityId: report.id, metadata: {'format': format.value});
    return Success(payload);
  }
}

class ReportSchedulingService {
  ReportSchedulingService({
    required ScheduledReportRepository repository,
    required AnalyticsExportService exportService,
    required ReportRepository reportRepository,
    required AuditService audit,
    required PermissionEngine permissions,
    Uuid? uuid,
  })  : _repo = repository,
        _export = exportService,
        _reports = reportRepository,
        _audit = audit,
        _permissions = permissions,
        _uuid = uuid ?? const Uuid();

  final ScheduledReportRepository _repo;
  final AnalyticsExportService _export;
  final ReportRepository _reports;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final Uuid _uuid;

  Future<Result<ScheduledReport>> schedule({
    required AuthUser user,
    required String reportId,
    required ScheduleFrequency frequency,
    String? recipientEmail,
  }) async {
    try {
      _permissions.require(user, ReportPermissions.schedule);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final now = DateTime.now().toUtc();
    final saved = await _repo.create(ScheduledReport(
      id: _uuid.v4(),
      tenantId: user.tenantId!,
      reportId: reportId,
      frequency: frequency,
      recipientEmail: recipientEmail,
      nextExecutionAt: _nextRun(frequency, now),
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    await _audit.log(action: AuditAction.create, entityType: ScheduledReport.entityTypeName, tenantId: saved.tenantId, employeeId: user.employeeId, entityId: saved.id);
    return Success(saved);
  }

  Future<Result<ReportExecutionHistory>> executeNow({required AuthUser user, required ScheduledReport scheduled}) async {
    try {
      _permissions.require(user, ReportPermissions.schedule);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final now = DateTime.now().toUtc();
    final report = await _reports.getById(scheduled.reportId, tenantId: user.tenantId);
    if (report == null) {
      return const Error(ValidationFailure(message: 'Report not found', code: 'not_found'));
    }
    final history = await _repo.createExecution(ReportExecutionHistory(
      id: _uuid.v4(),
      tenantId: user.tenantId!,
      scheduledReportId: scheduled.id,
      status: ReportExecutionStatus.completed,
      executedAt: now,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    await _repo.update(scheduled.copyWith(
      lastExecutedAt: now,
      nextExecutionAt: _nextRun(scheduled.frequency, now),
      version: scheduled.version + 1,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    ));
    await _audit.log(action: AuditAction.update, entityType: ScheduledReport.entityTypeName, tenantId: user.tenantId, employeeId: user.employeeId, entityId: scheduled.id, metadata: {'executed': true});
    return Success(history);
  }

  Future<List<ScheduledReport>> listActive(String tenantId) => _repo.listActive(tenantId);

  DateTime _nextRun(ScheduleFrequency frequency, DateTime from) => switch (frequency) {
        ScheduleFrequency.daily => from.add(const Duration(days: 1)),
        ScheduleFrequency.weekly => from.add(const Duration(days: 7)),
        ScheduleFrequency.monthly => DateTime(from.year, from.month + 1, from.day),
        ScheduleFrequency.quarterly => DateTime(from.year, from.month + 3, from.day),
        ScheduleFrequency.yearly => DateTime(from.year + 1, from.month, from.day),
        ScheduleFrequency.manual => from,
      };
}
