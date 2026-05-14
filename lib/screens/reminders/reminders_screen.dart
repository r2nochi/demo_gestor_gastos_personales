import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/formatters.dart';
import '../../providers/reminder_provider.dart';
import 'reminder_edit_screen.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final p = context.watch<ReminderProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: scheme.primary,
        foregroundColor: Colors.white,
        title: const Text('Recordatorios'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ReminderEditScreen()),
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
                final past = r.dateTime.isBefore(DateTime.now());
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: past
                            ? Theme.of(context).colorScheme.outlineVariant
                            : const Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_active_rounded,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(r.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(
                      '${formatDate(r.dateTime)} · ${formatHourMinute(r.dateTime)}'
                      '${r.message != null && r.message!.isNotEmpty ? '\n${r.message}' : ''}',
                    ),
                    isThreeLine: r.message != null && r.message!.isNotEmpty,
                    trailing: Switch.adaptive(
                      value: r.active,
                      onChanged: (v) => context
                          .read<ReminderProvider>()
                          .update(r.copyWith(active: v)),
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ReminderEditScreen(editing: r),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
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
            Icon(Icons.notifications_off_rounded,
                size: 96, color: Theme.of(context).colorScheme.outlineVariant),
            const SizedBox(height: 16),
            Text('Sin recordatorios', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(
              'Programa avisos para no olvidarte de pagar.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
