import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// A small trend line — used for both the heart-rate and SpO2 charts,
/// same shape, different data and color.
class HealthLineChart extends StatelessWidget {
  const HealthLineChart({super.key, required this.title, required this.values, required this.color});

  final String title;
  final List<double> values;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return const SizedBox.shrink();

    final spots = [for (var i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i])];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: color,
                  barWidth: 3,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: true, color: color.withValues(alpha: 0.12)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
