import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../../core/formatters.dart';
import '../../models/category.dart';
import '../../models/transaction.dart';
import '../../providers/account_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/category_icon.dart';
import '../../widgets/period_selector.dart';
import '../add_transaction/add_transaction_screen.dart';
import 'search_screen.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tx = context.watch<TransactionProvider>();
    final cats = context.watch<CategoryProvider>();
    final accs = context.watch<AccountProvider>();
    final settings = context.watch<SettingsProvider>();

    final list = tx.currentAll(accountId: accs.selectedId);
    list.sort((a, b) => b.date.compareTo(a.date));

    final byDay = <DateTime, List<Txn>>{};
    for (final t in list) {
      final day = DateTime(t.date.year, t.date.month, t.date.day);
      byDay.putIfAbsent(day, () => []).add(t);
    }
    final days = byDay.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: scheme.primary,
        foregroundColor: Colors.white,
        title: const Text('Movimientos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          PeriodSelector(
            current: tx.period,
            onChanged: (m) {
              if (m == PeriodMode.custom) {
                _pickCustom(context);
              } else {
                tx.setPeriod(m);
              }
            },
          ),
          _RangeBar(),
          _Totals(currency: settings.currency),
          Expanded(
            child: list.isEmpty
                ? _Empty()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                    itemCount: days.length,
                    itemBuilder: (_, i) {
                      final day = days[i];
                      final entries = byDay[day]!;
                      return _DaySection(
                        day: day,
                        entries: entries,
                        categories: cats.all,
                        currency: settings.currency,
                      );
                    },
                  ),
          ),
        ],
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
    if (picked != null) tx.setCustomRange(picked.start, picked.end);
  }
}

class _RangeBar extends StatelessWidget {
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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

class _Totals extends StatelessWidget {
  final String currency;
  const _Totals({required this.currency});

  @override
  Widget build(BuildContext context) {
    final tx = context.watch<TransactionProvider>();
    final accs = context.watch<AccountProvider>();
    final income = tx.totalIncome(accountId: accs.selectedId);
    final expense = tx.totalExpense(accountId: accs.selectedId);
    final balance = income - expense;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: _stat(context, 'Ingresos', income, const Color(0xFF10B981)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _stat(context, 'Gastos', expense, const Color(0xFFEF4444)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _stat(
              context,
              'Balance',
              balance,
              balance >= 0
                  ? Theme.of(context).colorScheme.primary
                  : const Color(0xFFEF4444),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(BuildContext context, String label, double v, Color c) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(
            formatMoney(v, code: currency),
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _DaySection extends StatelessWidget {
  final DateTime day;
  final List<Txn> entries;
  final List<Category> categories;
  final String currency;
  const _DaySection({
    required this.day,
    required this.entries,
    required this.categories,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final daySum = entries.fold<double>(
      0,
      (s, t) => s + (t.kind == TxKind.income ? t.amount : -t.amount),
    );
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              children: [
                Text(
                  _dayLabel(day),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Text(
                  formatMoney(daySum, code: currency),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: daySum >= 0
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ),
          Card(
            child: Column(
              children: [
                for (var i = 0; i < entries.length; i++) ...[
                  _Item(
                    txn: entries[i],
                    category: categories.firstWhere(
                      (c) => c.id == entries[i].categoryId,
                      orElse: () => Category(
                        name: 'Sin categoría',
                        iconCode: Icons.help_outline_rounded.codePoint,
                        colorValue: 0xFF9CA3AF,
                        kind: entries[i].kind,
                      ),
                    ),
                    currency: currency,
                  ),
                  if (i < entries.length - 1)
                    const Divider(height: 1, indent: 64),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _dayLabel(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(d).inDays;
    if (diff == 0) return 'HOY · ${formatDayMonth(d).toUpperCase()}';
    if (diff == 1) return 'AYER · ${formatDayMonth(d).toUpperCase()}';
    return '${formatWeekday(d).toUpperCase()} · ${formatDayMonth(d).toUpperCase()}';
  }
}

class _Item extends StatelessWidget {
  final Txn txn;
  final Category category;
  final String currency;
  const _Item({
    required this.txn,
    required this.category,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final color = txn.kind == TxKind.income
        ? const Color(0xFF10B981)
        : const Color(0xFFEF4444);
    final sign = txn.kind == TxKind.income ? '+' : '−';

    return Slidable(
      key: ValueKey(txn.id),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.5,
        children: [
          SlidableAction(
            onPressed: (_) => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AddTransactionScreen(editing: txn),
                fullscreenDialog: true,
              ),
            ),
            icon: Icons.edit_rounded,
            label: 'Editar',
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
          ),
          SlidableAction(
            onPressed: (_) => _confirmDelete(context),
            icon: Icons.delete_rounded,
            label: 'Eliminar',
            backgroundColor: const Color(0xFFEF4444),
            foregroundColor: Colors.white,
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AddTransactionScreen(editing: txn),
            fullscreenDialog: true,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              CategoryIcon(icon: category.icon, color: category.color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    if (txn.note != null && txn.note!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          txn.note!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$sign${formatMoney(txn.amount, code: currency)}',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar transacción'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok == true && txn.id != null) {
      await context.read<TransactionProvider>().delete(txn.id!);
    }
  }
}

class _Empty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: 96,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Sin movimientos',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Toca el botón + para registrar el primero.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
