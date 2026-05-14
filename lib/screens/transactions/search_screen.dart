import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/formatters.dart';
import '../../models/category.dart';
import '../../models/transaction.dart';
import '../../providers/category_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/category_icon.dart';
import '../add_transaction/add_transaction_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final tx = context.watch<TransactionProvider>();
    final cats = context.watch<CategoryProvider>();
    final settings = context.watch<SettingsProvider>();

    final q = _query.trim().toLowerCase();
    final results = q.isEmpty
        ? <Txn>[]
        : tx.all.where((t) {
            final cat = cats.byId(t.categoryId);
            final inCat = cat?.name.toLowerCase().contains(q) ?? false;
            final inNote = (t.note ?? '').toLowerCase().contains(q);
            final inAmount = t.amount.toStringAsFixed(2).contains(q);
            return inCat || inNote || inAmount;
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          onChanged: (v) => setState(() => _query = v),
          decoration: const InputDecoration(
            hintText: 'Buscar por categoría, nota o monto…',
            border: InputBorder.none,
            filled: false,
            contentPadding: EdgeInsets.zero,
          ),
          style: const TextStyle(fontSize: 16),
        ),
      ),
      body: results.isEmpty
          ? Center(
              child: Text(
                q.isEmpty ? 'Empieza a escribir para buscar.' : 'Sin resultados.',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            )
          : ListView.separated(
              itemCount: results.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 64),
              itemBuilder: (_, i) {
                final t = results[i];
                final c = cats.byId(t.categoryId) ??
                    Category(
                      name: 'Sin categoría',
                      iconCode: Icons.help_outline_rounded.codePoint,
                      colorValue: 0xFF9CA3AF,
                      kind: t.kind,
                    );
                final color = t.kind == TxKind.income
                    ? const Color(0xFF10B981)
                    : const Color(0xFFEF4444);
                final sign = t.kind == TxKind.income ? '+' : '−';
                return ListTile(
                  leading: CategoryIcon(icon: c.icon, color: c.color),
                  title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    '${formatDayMonth(t.date)} · ${t.note ?? ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    '$sign${formatMoney(t.amount, code: settings.currency)}',
                    style: TextStyle(fontWeight: FontWeight.w700, color: color),
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AddTransactionScreen(editing: t),
                      fullscreenDialog: true,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
