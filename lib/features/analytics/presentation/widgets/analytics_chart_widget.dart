import 'package:flutter/material.dart';

import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/features/analytics/domain/enums/analytics_enums.dart';
import 'package:fashion_pos_enterprise/features/analytics/domain/value_objects/analytics_value_objects.dart';

class AnalyticsChartWidget extends StatelessWidget {
  const AnalyticsChartWidget({
    required this.title,
    required this.series,
    this.chartType = ChartType.bar,
    super.key,
  });

  final String title;
  final List<ChartSeries> series;
  final ChartType chartType;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            SizedBox(height: 160, child: _buildChart(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    final points = series.isEmpty ? const <TrendPoint>[] : series.first.points;
    if (points.isEmpty) {
      return Center(child: Text('No data', style: Theme.of(context).textTheme.bodyMedium));
    }
    return switch (chartType) {
      ChartType.pie || ChartType.donut => _pie(points),
      ChartType.gauge => _gauge(points),
      ChartType.line || ChartType.area || ChartType.sparkline => _line(points, filled: chartType == ChartType.area),
      ChartType.funnel || ChartType.waterfall => _bar(points, stacked: false),
      ChartType.stackedBar => _bar(points, stacked: true),
      ChartType.heatmap => _heatmap(points),
      _ => _bar(points, stacked: false),
    };
  }

  Widget _bar(List<TrendPoint> points, {required bool stacked}) {
    final max = points.map((p) => p.value).fold<double>(0, (a, b) => a > b ? a : b);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final p in points)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: max <= 0 ? 4 : (p.value / max) * 120,
                    decoration: BoxDecoration(
                      color: stacked ? Colors.blue.shade300 : Colors.blue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _line(List<TrendPoint> points, {required bool filled}) {
    return CustomPaint(
      painter: _LineChartPainter(points: points, filled: filled),
      child: const SizedBox.expand(),
    );
  }

  Widget _pie(List<TrendPoint> points) {
    final total = points.fold<double>(0, (s, p) => s + p.value);
    return Row(
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: CustomPaint(painter: _PieChartPainter(points: points, total: total)),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < points.length && i < 4; i++)
                Text('${points[i].period.day}/${points[i].period.month}: ${points[i].value.toStringAsFixed(0)}'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _gauge(List<TrendPoint> points) {
    final value = points.last.value.clamp(0, 100);
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 140,
          height: 80,
          child: CustomPaint(painter: _GaugePainter(value: value)),
        ),
        Text('${value.toStringAsFixed(0)}%'),
      ],
    );
  }

  Widget _heatmap(List<TrendPoint> points) {
    final max = points.map((p) => p.value).fold<double>(1, (a, b) => a > b ? a : b);
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (final p in points)
          Container(
            width: 24,
            height: 24,
            color: Color.lerp(Colors.blue.shade50, Colors.blue.shade900, p.value / max),
          ),
      ],
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({required this.points, required this.filled});

  final List<TrendPoint> points;
  final bool filled;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final max = points.map((p) => p.value).fold<double>(0, (a, b) => a > b ? a : b);
    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final x = size.width * (i / (points.length - 1));
      final y = size.height - (max <= 0 ? 0 : (points[i].value / max) * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke;
    if (filled) {
      final fill = Path.from(path)..lineTo(size.width, size.height)..lineTo(0, size.height)..close();
      canvas.drawPath(fill, paint..color = Colors.blue.withValues(alpha: 0.2));
      canvas.drawPath(path, Paint()..color = Colors.blue..strokeWidth = 2..style = PaintingStyle.stroke);
    } else {
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) => oldDelegate.points != points;
}

class _PieChartPainter extends CustomPainter {
  _PieChartPainter({required this.points, required this.total});

  final List<TrendPoint> points;
  final double total;

  @override
  void paint(Canvas canvas, Size size) {
    if (total <= 0) return;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    var start = -3.14159 / 2;
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.red];
    for (var i = 0; i < points.length; i++) {
      final sweep = (points[i].value / total) * 3.14159 * 2;
      canvas.drawArc(rect, start, sweep, true, Paint()..color = colors[i % colors.length]);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) => false;
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({required this.value});

  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height * 2);
    canvas.drawArc(rect, 3.14159, 3.14159, false, Paint()..color = Colors.grey.shade300..strokeWidth = 12..style = PaintingStyle.stroke);
    canvas.drawArc(
      rect,
      3.14159,
      3.14159 * (value / 100),
      false,
      Paint()..color = Colors.blue..strokeWidth = 12..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) => oldDelegate.value != value;
}
