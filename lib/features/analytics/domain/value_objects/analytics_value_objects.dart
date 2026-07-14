import 'package:equatable/equatable.dart';

class MetricValue extends Equatable {
  const MetricValue({required this.label, required this.value, this.unit, this.delta, this.deltaPercent});

  final String label;
  final double value;
  final String? unit;
  final double? delta;
  final double? deltaPercent;

  @override
  List<Object?> get props => [label, value, unit, delta, deltaPercent];
}

class TrendPoint extends Equatable {
  const TrendPoint({required this.period, required this.value});

  final DateTime period;
  final double value;

  @override
  List<Object?> get props => [period, value];
}

class ChartSeries extends Equatable {
  const ChartSeries({required this.name, required this.points, this.chartType = 'line'});

  final String name;
  final List<TrendPoint> points;
  final String chartType;

  @override
  List<Object?> get props => [name, points, chartType];
}

class DateRangeFilter extends Equatable {
  const DateRangeFilter({required this.from, required this.to, this.storeId, this.warehouseId, this.employeeId});

  final DateTime from;
  final DateTime to;
  final String? storeId;
  final String? warehouseId;
  final String? employeeId;

  @override
  List<Object?> get props => [from, to, storeId, warehouseId, employeeId];
}

class ReportFilter extends Equatable {
  const ReportFilter({
    this.dateRange,
    this.groupBy,
    this.sortBy,
    this.storeId,
    this.warehouseId,
    this.supplierId,
    this.customerId,
    this.employeeId,
  });

  final DateRangeFilter? dateRange;
  final String? groupBy;
  final String? sortBy;
  final String? storeId;
  final String? warehouseId;
  final String? supplierId;
  final String? customerId;
  final String? employeeId;

  Map<String, dynamic> toJson() => {
        if (dateRange != null) 'from': dateRange!.from.toIso8601String(),
        if (dateRange != null) 'to': dateRange!.to.toIso8601String(),
        if (groupBy != null) 'group_by': groupBy,
        if (sortBy != null) 'sort_by': sortBy,
        if (storeId != null) 'store_id': storeId,
        if (warehouseId != null) 'warehouse_id': warehouseId,
        if (supplierId != null) 'supplier_id': supplierId,
        if (customerId != null) 'customer_id': customerId,
        if (employeeId != null) 'employee_id': employeeId,
      };
}
