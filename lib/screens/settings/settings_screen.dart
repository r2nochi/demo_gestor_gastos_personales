import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../data/database.dart';
import '../../providers/account_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/recurring_provider.dart';
import '../../providers/reminder_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../services/backup_service.dart';
import 'pin_setup_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: scheme.primary,
        foregroundColor: Colors.white,
        title: const Text('Ajustes'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 120),
        children: [
          _section(context, 'Perfil'),
          ListTile(
            leading: const Icon(Icons.person_rounded),
            title: const Text('Nombre'),
            subtitle: Text(settings.userName),
            onTap: () => _editName(context, settings.userName),
          ),
          const Divider(height: 1),
          _section(context, 'Apariencia'),
          ListTile(
            leading: const Icon(Icons.brightness_6_rounded),
            title: const Text('Tema'),
            subtitle: Text(_themeLabel(settings.themeMode)),
            onTap: () => _pickTheme(context, settings),
          ),
          const Divider(height: 1),
          _section(context, 'Moneda'),
          ListTile(
            leading: const Icon(Icons.payments_rounded),
            title: const Text('Moneda principal'),
            subtitle: Text(
              kSupportedCurrencies[settings.currency] ?? settings.currency,
            ),
            onTap: () => _pickCurrency(context, settings),
          ),
          const Divider(height: 1),
          _section(context, 'Seguridad'),
          SwitchListTile(
            secondary: const Icon(Icons.lock_rounded),
            title: const Text('PIN al abrir la app'),
            subtitle: Text(
              settings.pin == null ? 'Desactivado' : 'Activo (4 dígitos)',
            ),
            value: settings.pin != null,
            onChanged: (v) async {
              if (v) {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PinSetupScreen()),
                );
              } else {
                await context.read<SettingsProvider>().setPin(null);
              }
            },
          ),
          const Divider(height: 1),
          _section(context, 'Datos'),
          ListTile(
            leading: const Icon(Icons.upload_rounded),
            title: const Text('Exportar respaldo (JSON)'),
            subtitle: const Text('Comparte un archivo con todos tus datos'),
            onTap: () => _exportJson(context),
          ),
          ListTile(
            leading: const Icon(Icons.table_chart_rounded),
            title: const Text('Exportar a CSV'),
            subtitle: const Text('Para abrir en Excel o Hojas de cálculo'),
            onTap: () => _exportCsv(context),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever_rounded),
            title: const Text('Borrar todos los datos'),
            subtitle: const Text('Restablece la app a su estado inicial'),
            iconColor: const Color(0xFFEF4444),
            textColor: const Color(0xFFEF4444),
            onTap: () => _wipe(context),
          ),
          const Divider(height: 1),
          _section(context, 'Acerca de'),
          const ListTile(
            leading: Icon(Icons.info_outline_rounded),
            title: Text('Saldo'),
            subtitle: Text('Versión 1.0.0\nTu dinero, claro como el agua.'),
          ),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  String _themeLabel(ThemeMode m) => switch (m) {
        ThemeMode.light => 'Claro',
        ThemeMode.dark => 'Oscuro',
        _ => 'Automático (sistema)',
      };

  Future<void> _editName(BuildContext context, String current) async {
    final ctrl = TextEditingController(text: current);
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tu nombre'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLength: 24,
          decoration: const InputDecoration(hintText: '¿Cómo te llamamos?'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(ctrl.text.trim()),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      await context.read<SettingsProvider>().setUserName(result);
    }
  }

  Future<void> _pickTheme(BuildContext context, SettingsProvider s) async {
    final m = await showDialog<ThemeMode>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Tema'),
        children: [
          for (final entry in const [
            (ThemeMode.system, 'Automático'),
            (ThemeMode.light, 'Claro'),
            (ThemeMode.dark, 'Oscuro'),
          ])
            RadioListTile<ThemeMode>(
              groupValue: s.themeMode,
              value: entry.$1,
              title: Text(entry.$2),
              onChanged: (v) => Navigator.of(context).pop(v),
            ),
        ],
      ),
    );
    if (m != null) await s.setThemeMode(m);
  }

  Future<void> _pickCurrency(BuildContext context, SettingsProvider s) async {
    final code = await showDialog<String>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Moneda'),
        children: [
          for (final entry in kSupportedCurrencies.entries)
            RadioListTile<String>(
              groupValue: s.currency,
              value: entry.key,
              title: Text(entry.value),
              onChanged: (v) => Navigator.of(context).pop(v),
            ),
        ],
      ),
    );
    if (code != null) await s.setCurrency(code);
  }

  Future<void> _exportJson(BuildContext context) async {
    try {
      final file = await BackupService.instance.exportJson();
      await BackupService.instance.share(file, subject: 'Respaldo Saldo');
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error al exportar: $e')));
    }
  }

  Future<void> _exportCsv(BuildContext context) async {
    try {
      final file = await BackupService.instance.exportCsv();
      await BackupService.instance.share(file, subject: 'Saldo CSV');
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error al exportar: $e')));
    }
  }

  Future<void> _wipe(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Borrar todos los datos?'),
        content: const Text(
          'Esta acción no se puede deshacer.\n'
          'Se eliminarán transacciones, cuentas, categorías personalizadas, '
          'pagos habituales y recordatorios.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Borrar todo'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await AppDatabase.instance.wipe();
    if (!context.mounted) return;
    await context.read<CategoryProvider>().load();
    await context.read<AccountProvider>().load();
    await context.read<TransactionProvider>().load();
    try {
      await context.read<RecurringProvider>().load();
    } catch (_) {}
    try {
      await context.read<ReminderProvider>().load();
    } catch (_) {}
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Datos borrados.')));
  }
}

