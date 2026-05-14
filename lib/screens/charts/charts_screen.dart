import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/formatters.dart';
import '../../models/category.dart';
import '../../models/transaction.dart';
import '../../providers/account_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/transaction_provider.dart';

enum _Grain { day, week, month }

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({super.key});

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  _Grain _grain = _Grain.month;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tx = context.watch<TransactionProvider>();
    final accs = context.watch<AccountProvider>();
    final cats = context.watch<CategoryProvider>();
    final settings = context.watch<SettingsProvider>();
    final all = tx.all.where((t) => t.accountId == accs.selectedId).toList();

    final buckets = _bucket(all, _grain);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: scheme.primary,
        foregroundColor: Colors.white,
        title: const Text('Gráficos'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<_Grain>(
              segments: const [
                ButtonSegment(value: _Grain.day, label: Text('Día')),
                ButtonSegment(value: _Grain.week, label: Text('Semana')),
                ButtonSegment(value: _Grain.month, label: Text('Mes')),
              ],
              selected: {_grain},
              onSelectionChanged: (s) => setState(() => _grain = s.first),
              showSelectedIcon: false,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ingresos vs Gastos',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 220,
                      child: _BarComparison(buckets: buckets),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _legend(const Color(0xFF10B981), 'Ingresos'),
                        const SizedBox(width: 16),
                        _legend(const Color(0xFFEF4444), 'Gastos'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Balance acumulado',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: _BalanceLine(buckets: buckets),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _TopCategoriesCard(
              all: all,
              currency: settings.currency,
              categories: cats.all,
            ),
          ],
        ),
      ),
    );
  }

  Widget _legend(Color c, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      );

  List<_Bucket> _bucket(List<Txn> txns, _Grain g) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    const count = 7;
    final buckets = <_Bucket>[];
    for (var i = count - 1; i >= 0; i--) {
      late DateTime start, end;
      late String label;
      switch (g) {
        case _Grain.day:
          start = today.subtract(Duration(days: i));
          end = start.add(const Duration(days: 1));
          label = formatDateShort(start);
          break;
        case _Grain.week:
          final wstart = today.subtract(Duration(days: today.weekday - 1 + i * 7));
          start = wstart;
          end = wstart.add(const Duration(days: 7));
          label = formatDateShort(wstart);
          break;
        case _Grain.month:
          final m = DateTime(today.year, today.month - i, 1);
          start = m;
          end = DateTime(m.year, m.month + 1, 1);
          final mm = formatMonthYear(m).split(' ').first;
          label = mm.length >= 3 ? mm.substring(0, 3) : mm;
          break;
      }
      double inc = 0, exp = 0;
      for (final t in txns) {
        if (!t.date.isBefore(start) && t.date.isBefore(end)) {
          if (t.kind == TxKind.income) {
            inc += t.amount;
          } else {
            exp += t.amount;
          }
        }
      }
      buckets.add(_Bucket(label, inc, exp));
    }
    return buckets;
  }
}

class _Bucket {
  final String label;
  final double income;
  final double expense;
  const _Bucket(this.label, this.income, this.expense);
}

class _BarComparison extends StatelessWidget {
  final List<_Bucket> buckets;
  const _BarComparison({required this.buckets});

  @override
  Widget build(BuildContext context) {
    if (buckets.isEmpty) return const SizedBox.shrink();
    final maxY = buckets.fold<double>(
      0,
      (m, b) => [m, b.income, b.expense].reduce((a, b) => a > b ? a : b),
    );
    final yMax = maxY <= 0 ? 1.0 : maxY * 1.2;

    return BarChart(BarChartData(
      maxY: yMax,
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 26,
            getTitlesWidget: (v, _) {
              final i = v.toInt();
              if (i < 0 || i >= buckets.length) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  buckets[i].label,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                ),
              );
            },
          ),
        ),
      ),
      barGroups: [
        for (var i = 0; i < buckets.length; i++)
          BarChartGroupData(
            x: i,
            barsSpace: 4,
            barRods: [
              BarChartRodData(
                toY: buckets[i].income,
                color: const Color(0xFF10B981),
                width: 9,
                borderRadius: BorderRadius.circular(3),
              ),
              BarChartRodData(
                toY: buckets[i].expense,
                color: const Color(0xFFEF4444),
                width: 9,
                borderRadius: BorderRadius.circular(3),
              ),
            ],
          ),
      ],
    ));
  }
}

class _BalanceLine extends StatelessWidget {
  final List<_Bucket> buckets;
  const _BalanceLine({required this.buckets});

  @override
  Widget build(BuildContext context) {
    if (buckets.isEmpty) return const SizedBox.shrink();
    double acc = 0;
    final spots = <FlSpot>[];
    for (var i = 0; i < buckets.length; i++) {
      acc += buckets[i].income - buckets[i].expense;
      spots.add(FlSpot(i.toDouble(), acc));
    }
    final minY = spots.fold<double>(0, (m, s) => s.y < m ? s.y : m);
    final maxY = spots.fold<double>(0, (m, s) => s.y > m ? s.y : m);
    final pad = (maxY - minY).abs() * 0.2 + 1;

    return LineChart(LineChartData(
      minY: minY - pad,
      maxY: maxY + pad,
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 26,
            getTitlesWidget: (v, _) {
              final i = v.toInt();
              if (i < 0 || i >= buckets.length) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  buckets[i].label,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                ),
              );
            },
          ),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.3,
          color: Theme.of(context).colorScheme.primary,
          barWidth: 3,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
          ),
        ),
      ],
    ));
  }
}

class _TopCategoriesCard extends StatelessWidget {
  final List<Txn> all;
  final String currency;
  final List<Category> categories;
  const _TopCategoriesCard({
    required this.all,
    required this.currency,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final byCat = <int, double>{};
    for (final t in all) {
      if (t.kind == TxKind.expense) {
        byCat.update(t.categoryId, (v) => v + t.amount, ifAbsent: () => t.amount);
      }
    }
    final entries = byCat.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = entries.take(5).toList();
    final total = byCat.values.fold<double>(0, (a, b) => a + b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Top categorías (gastos)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            if (top.isEmpty)
              Text(
                'Aún no hay gastos para mostrar.',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              )
            else
              for (final e in top)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: () {
                    final cat = categories.firstWhere(
                      (c) => c.id == e.key,
                      orElse: () => Category(
                        name: 'Sin categoría',
                        iconCode: Icons.help_outline_rounded.codePoint,
                        colorValue: 0xFF9CA3AF,
                        kind: TxKind.expense,
                      ),
                    );
                    final pct = total > 0 ? (e.value / total * 100).round() : 0;
                    return Row(
                      children: [
                        Container(
                          width: 12, height: 12,
                          decoration: BoxDecoration(color: cat.color, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            cat.name,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Text('$pct%',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            )),
                        const SizedBox(width: 10),
                        Text(
                          formatMoney(e.value, code: currency),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                      ],
                    );
                  }(),
                ),
          ],
        ),
      ),
    );
  }
}
