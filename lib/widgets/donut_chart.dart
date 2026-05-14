import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/formatters.dart';

class DonutDatum {
  final String label;
  final double value;
  final Color color;
  const DonutDatum(this.label, this.value, this.color);
}

class DonutChart extends StatelessWidget {
  final List<DonutDatum> data;
  final double total;
  final String currencyCode;
  final String? emptyText;
  const DonutChart({
    super.key,
    required this.data,
    required this.total,
    this.currencyCode = 'PEN',
    this.emptyText,
  });

  @override
  Widget build(BuildContext context) {
    final isEmpty = total <= 0 || data.isEmpty;
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              startDegreeOffset: -90,
              sectionsSpace: isEmpty ? 0 : 3,
              centerSpaceRadius: 92,
              sections: isEmpty
                  ? [
                      PieChartSectionData(
                        value: 1,
                        showTitle: false,
                        radius: 32,
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      )
                    ]
                  : data
                      .map((d) => PieChartSectionData(
                            value: d.value,
                            showTitle: false,
                            radius: 32,
                            color: d.color,
                          ))
                      .toList(),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    emptyText ?? 'Sin datos en este período',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                )
              else
                Text(
                  formatMoney(total, code: currencyCode),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
