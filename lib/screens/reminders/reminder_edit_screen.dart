import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/formatters.dart';
import '../../models/reminder.dart';
import '../../providers/reminder_provider.dart';

class ReminderEditScreen extends StatefulWidget {
  final Reminder? editing;
  const ReminderEditScreen({super.key, this.editing});

  @override
  State<ReminderEditScreen> createState() => _ReminderEditScreenState();
}

class _ReminderEditScreenState extends State<ReminderEditScreen> {
  final _titleCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();
  DateTime _date = DateTime.now().add(const Duration(hours: 1));
  bool _active = true;

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    if (e != null) {
      _titleCtrl.text = e.title;
      _msgCtrl.text = e.message ?? '';
      _date = e.dateTime;
      _active = e.active;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: scheme.primary,
        foregroundColor: Colors.white,
        title: Text(widget.editing == null ? 'Nuevo recordatorio' : 'Editar recordatorio'),
        actions: [
          if (widget.editing != null)
            IconButton(icon: const Icon(Icons.delete_rounded), onPressed: _confirmDelete),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleCtrl,
              maxLength: 48,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: _msgCtrl,
              maxLines: 3,
              maxLength: 256,
              decoration: const InputDecoration(labelText: 'Mensaje (opcional)'),
            ),
            const SizedBox(height: 16),
            const Text('Fecha', style: TextStyle(fontWeight: FontWeight.w700)),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_month_rounded),
              title: Text(formatDate(_date)),
              onTap: _pickDate,
            ),
            const Text('Hora', style: TextStyle(fontWeight: FontWeight.w700)),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.access_time_rounded),
              title: Text(formatHourMinute(_date)),
              onTap: _pickTime,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _active,
              onChanged: (v) => setState(() => _active = v),
              title: const Text('Activo'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _save,
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
            child: const Text('Guardar'),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _date = DateTime(picked.year, picked.month, picked.day, _date.hour, _date.minute));
    }
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_date),
    );
    if (t != null) {
      setState(() => _date = DateTime(_date.year, _date.month, _date.day, t.hour, t.minute));
    }
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Ingresa un título')));
      return;
    }
    final p = context.read<ReminderProvider>();
    if (widget.editing == null) {
      await p.add(Reminder(
        title: _titleCtrl.text.trim(),
        message: _msgCtrl.text.trim().isEmpty ? null : _msgCtrl.text.trim(),
        dateTime: _date,
        active: _active,
      ));
    } else {
      await p.update(widget.editing!.copyWith(
        title: _titleCtrl.text.trim(),
        message: _msgCtrl.text.trim().isEmpty ? null : _msgCtrl.text.trim(),
        dateTime: _date,
        active: _active,
      ));
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _confirmDelete() async {
    if (widget.editing?.id == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar recordatorio'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await context.read<ReminderProvider>().delete(widget.editing!.id!);
    if (mounted) Navigator.of(context).pop();
  }
}
