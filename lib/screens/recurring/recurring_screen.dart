import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/formatters.dart';
import '../../models/category.dart';
import '../../models/recurring.dart';
import '../../providers/category_provider.dart';
import '../../providers/recurring_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/category_icon.dart';
import 'recurring_edit_screen.dart';

class RecurringScreen extends StatefulWidget {
  const RecurringScreen({super.key});

  @override
  State<RecurringScreen> createState() => _RecurringScreenState();
}

class _RecurringScreenState extends State<RecurringScreen> {
  bool _running = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final p = context.watch<RecurringProvider>();
    final cats = context.watch<CategoryProvider>();
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: scheme.primary,
        foregroundColor: Colors.white,
        title: const Text('Pagos habituales'),
        actions: [
          IconButton(
            tooltip: 'Procesar pendientes',
            icon: _running
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : const Icon(Icons.play_arrow_rounded),
            onPressed: _running ? null : _runDue,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const RecurringEditScreen()),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nuevo'),
      ),
      body: p.all.isEmpty
          ? _Empty()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              itemCount: p.all.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final r = p.all[i];
                final c = cats.byId(r.categoryId) ??
                    Category(
                      name: '?',
                      iconCode: Icons.help_outline_rounded.codePoint,
                      colorValue: 0xFF9CA3AF,
                      kind: r.kind,
                    );
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CategoryIcon(icon: c.icon, color: c.color),
                    title: Text(r.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(
                      '${_freqLabel(r.frequency)} · ${formatDayMonth(r.startDate)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${r.kind == TxKind.income ? '+' : '−'}${formatMoney(r.amount, code: settings.currency)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: r.kind == TxKind.income
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                          ),
                        ),
                        Switch.adaptive(
                          value: r.active,
                          onChanged: (v) => context
                              .read<RecurringProvider>()
                              .update(r.copyWith(active: v)),
                        ),
                      ],
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => RecurringEditScreen(editing: r),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _runDue() async {
    setState(() => _running = true);
    final created = await context.read<RecurringProvider>().runDue();
    if (mounted) {
      await context.read<TransactionProvider>().load();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(created == 0
            ? 'No había pagos pendientes.'
            : 'Se registraron $created pagos pendientes.'),
      ));
      setState(() => _running = false);
    }
  }

  String _freqLabel(Frequency f) => switch (f) {
        Frequency.daily => 'Diario',
        Frequency.weekly => 'Semanal',
        Frequency.monthly => 'Mensual',
        Frequency.yearly => 'Anual',
      };
}

class _Empty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.replay_circle_filled_rounded,
                size: 96, color: Theme.of(context).colorScheme.outlineVariant),
            const SizedBox(height: 16),
            Text('Sin pagos habituales',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(
              'Crea pagos que se repitan automáticamente:\nalquiler, suscripciones, ingresos fijos…',
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
