enum DashboardType {
  executive,
  sales,
  inventory,
  purchasing,
  crm,
  accounting,
  hr,
  manufacturing;

  String get value => name;

  static DashboardType fromValue(String? v) =>
      DashboardType.values.firstWhere((e) => e.name == v, orElse: () => DashboardType.executive);
}

enum ChartType {
  line,
  area,
  pie,
  donut,
  bar,
  stackedBar,
  heatmap,
  gauge,
  funnel,
  waterfall,
  sparkline;

  String get value => name;

  static ChartType fromValue(String? v) =>
      ChartType.values.firstWhere((e) => e.name == v, orElse: () => ChartType.bar);
}

enum ReportStatus {
  draft,
  published,
  archived;

  String get value => name;

  static ReportStatus fromValue(String? v) =>
      ReportStatus.values.firstWhere((e) => e.name == v, orElse: () => ReportStatus.draft);
}

enum ExportFormatType {
  pdf,
  excel,
  csv;

  String get value => name;

  static ExportFormatType fromValue(String? v) =>
      ExportFormatType.values.firstWhere((e) => e.name == v, orElse: () => ExportFormatType.csv);
}

enum ScheduleFrequency {
  daily,
  weekly,
  monthly,
  quarterly,
  yearly,
  manual;

  String get value => name;

  static ScheduleFrequency fromValue(String? v) =>
      ScheduleFrequency.values.firstWhere((e) => e.name == v, orElse: () => ScheduleFrequency.manual);
}

enum KpiCategory {
  sales,
  inventory,
  purchasing,
  crm,
  hr,
  manufacturing,
  accounting;

  String get value => name;

  static KpiCategory fromValue(String? v) =>
      KpiCategory.values.firstWhere((e) => e.name == v, orElse: () => KpiCategory.sales);
}

enum ReportExecutionStatus {
  pending,
  running,
  completed,
  failed;

  String get value => name;

  static ReportExecutionStatus fromValue(String? v) =>
      ReportExecutionStatus.values.firstWhere((e) => e.name == v, orElse: () => ReportExecutionStatus.pending);
}
