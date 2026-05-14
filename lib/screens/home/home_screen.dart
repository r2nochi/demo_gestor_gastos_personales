import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/formatters.dart';
import '../../models/category.dart';
import '../../models/transaction.dart';
import '../../providers/account_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/category_icon.dart';
import '../../widgets/donut_chart.dart';
import '../../widgets/period_selector.dart';
import '../accounts/account_picker.dart';
import '../more/drawer_menu.dart';
import '../transactions/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final txProvider = context.watch<TransactionProvider>();
    final cats = context.watch<CategoryProvider>();
    final acc = context.watch<AccountProvider>();
    final settings = context.watch<SettingsProvider>();

    final kind = _tab.index == 0 ? TxKind.expense : TxKind.income;
    final txns = txProvider.currentByKind(kind, accountId: acc.selectedId);

    return Scaffold(
      drawer: const DrawerMenu(),
      body: SafeArea(
        bottom: false,
        child: NestedScrollView(
          headerSliverBuilder: (_, __) => [
            SliverAppBar(
              pinned: true,
              expandedHeight: 200,
              backgroundColor: scheme.primary,
              foregroundColor: Colors.white,
              leading: Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search_rounded),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                titlePadding: const EdgeInsets.only(bottom: 56),
                title: GestureDetector(
                  onTap: () => showModalBottomSheet(
                    context: context,
                    builder: (_) => const AccountPicker(),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.account_balance_wallet_rounded, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            acc.selected?.name ?? 'Total',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down_rounded, size: 22),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatMoney(
                          txProvider.balanceAllTime(accountId: acc.selectedId),
                          code: settings.currency,
                        ),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              bottom: TabBar(
                controller: _tab,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
                tabs: const [
                  Tab(text: 'GASTOS'),
                  Tab(text: 'INGRESOS'),
                ],
              ),
            ),
          ],
          body: Container(
            color: scheme.surface,
            child: CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
                SliverToBoxAdapter(
                  child: PeriodSelector(
                    current: txProvider.period,
                    onChanged: (m) {
                      if (m == PeriodMode.custom) {
                        _pickCustom(context);
                      } else {
                        txProvider.setPeriod(m);
                      }
                    },
                  ),
                ),
                SliverToBoxAdapter(child: _RangeBar(period: txProvider.period)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _SummaryCard(
                      kind: kind,
                      txns: txns,
                      categories: cats.all,
                      currency: settings.currency,
                    ),
                  ),
                ),
                _CategoryBreakdown(
                  kind: kind,
                  txns: txns,
                  categories: cats.all,
                  currency: settings.currency,
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickCustom(BuildContext context) async {
    final tx = context.read<TransactionProvider>();
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange: DateTimeRange(
        start: now.subtract(const Duration(days: 7)),
        end: now,
      ),
    );
    if (picked != null) {
      tx.setCustomRange(picked.start, picked.end);
    }
  }
}

class _RangeBar extends StatelessWidget {
  final dynamic period;
  const _RangeBar({required this.period});

  @override
  Widget build(BuildContext context) {
    final tx = context.watch<TransactionProvider>();
    final r = tx.range;
    String label;
    switch (tx.period) {
      case PeriodMode.day:
        label = formatDate(r.start);
        break;
      case PeriodMode.week:
        label = '${formatDayMonth(r.start)} – ${formatDayMonth(r.end.subtract(const Duration(days: 1)))}';
        break;
      case PeriodMode.month:
        label = formatMonthYear(r.start);
        break;
      case PeriodMode.year:
        label = '${r.start.year}';
        break;
      case PeriodMode.custom:
        label = '${formatDateShort(r.start)} – ${formatDateShort(r.end.subtract(const Duration(days: 1)))}';
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: tx.period == PeriodMode.custom ? null : () => tx.shift(-1),
          ),
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: tx.period == PeriodMode.custom ? null : () => tx.shift(1),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final TxKind kind;
  final List<Txn> txns;
  final List<Category> categories;
  final String currency;
  const _SummaryCard({
    required this.kind,
    required this.txns,
    required this.categories,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final grouped = <int, double>{};
    for (final t in txns) {
      grouped.update(t.categoryId, (v) => v + t.amount, ifAbsent: () => t.amount);
    }
    final total = txns.fold<double>(0, (s, t) => s + t.amount);

    final data = grouped.entries.map((e) {
      final cat = categories.firstWhere(
        (c) => c.id == e.key,
        orElse: () => Category(
          name: '?',
          iconCode: Icons.help_outline_rounded.codePoint,
          colorValue: 0xFF9CA3AF,
          kind: kind,
        ),
      );
      return DonutDatum(cat.name, e.value, cat.color);
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DonutChart(
              data: data,
              total: total,
              currencyCode: currency,
              emptyText: kind == TxKind.expense
                  ? 'Sin gastos en este período'
                  : 'No hubo ingresos en este período',
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBreakdown extends StatelessWidget {
  final TxKind kind;
  final List<Txn> txns;
  final List<Category> categories;
  final String currency;
  const _CategoryBreakdown({
    required this.kind,
    required this.txns,
    required this.categories,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final grouped = <int, double>{};
    for (final t in txns) {
      grouped.update(t.categoryId, (v) => v + t.amount, ifAbsent: () => t.amount);
    }
    final entries = grouped.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold<double>(0, (s, e) => s + e.value);

    if (entries.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList.separated(
        itemCount: entries.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final e = entries[i];
          final cat = categories.firstWhere(
            (c) => c.id == e.key,
            orElse: () => Category(
              name: 'Sin categoría',
              iconCode: Icons.help_outline_rounded.codePoint,
              colorValue: 0xFF9CA3AF,
              kind: kind,
            ),
          );
          final pct = total > 0 ? (e.value / total * 100).round() : 0;

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CategoryIcon(icon: cat.icon, color: cat.color),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      cat.name,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Text(
                    '$pct %',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    formatMoney(e.value, code: currency),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
