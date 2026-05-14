import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/formatters.dart';
import '../../models/category.dart';
import '../../models/recurring.dart';
import '../../providers/account_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/recurring_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/category_icon.dart';

class RecurringEditScreen extends StatefulWidget {
  final Recurring? editing;
  const RecurringEditScreen({super.key, this.editing});

  @override
  State<RecurringEditScreen> createState() => _RecurringEditScreenState();
}

class _RecurringEditScreenState extends State<RecurringEditScreen> {
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  TxKind _kind = TxKind.expense;
  int? _categoryId;
  int? _accountId;
  Frequency _freq = Frequency.monthly;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _active = true;

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    if (e != null) {
      _nameCtrl.text = e.name;
      _amountCtrl.text = e.amount.toStringAsFixed(
        e.amount.truncateToDouble() == e.amount ? 0 : 2,
      );
      _kind = e.kind;
      _categoryId = e.categoryId;
      _accountId = e.accountId;
      _freq = e.frequency;
      _startDate = e.startDate;
      _endDate = e.endDate;
      _active = e.active;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final cats = context.watch<CategoryProvider>().byKind(_kind);
    final accs = context.watch<AccountProvider>();
    final settings = context.watch<SettingsProvider>();
    _accountId ??= accs.selectedId;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: scheme.primary,
        foregroundColor: Colors.white,
        title: Text(widget.editing == null ? 'Nuevo pago habitual' : 'Editar pago'),
        actions: [
          if (widget.editing != null)
            IconButton(
              icon: const Icon(Icons.delete_rounded),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<TxKind>(
              segments: const [
                ButtonSegment(value: TxKind.expense, label: Text('Gasto')),
                ButtonSegment(value: TxKind.income, label: Text('Ingreso')),
              ],
              selected: {_kind},
              onSelectionChanged: (s) => setState(() {
                _kind = s.first;
                _categoryId = null;
              }),
              showSelectedIcon: false,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameCtrl,
              maxLength: 32,
              decoration: const InputDecoration(labelText: 'Nombre (ej. Netflix)'),
            ),
            TextField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: 'Monto',
                suffixText: settings.currency,
              ),
            ),
            const SizedBox(height: 16),
            _label('Cuenta'),
            DropdownButton<int>(
              value: _accountId,
              isExpanded: true,
              items: accs.all
                  .map((a) => DropdownMenuItem(
                        value: a.id,
                        child: Text(a.name),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _accountId = v),
            ),
            const SizedBox(height: 16),
            _label('Categoría'),
            const SizedBox(height: 8),
            _CategoryPicker(
              categories: cats,
              selectedId: _categoryId,
              onSelected: (id) => setState(() => _categoryId = id),
            ),
            const SizedBox(height: 16),
            _label('Frecuencia'),
            DropdownButton<Frequency>(
              value: _freq,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: Frequency.daily, child: Text('Diario')),
                DropdownMenuItem(value: Frequency.weekly, child: Text('Semanal')),
                DropdownMenuItem(value: Frequency.monthly, child: Text('Mensual')),
                DropdownMenuItem(value: Frequency.yearly, child: Text('Anual')),
              ],
              onChanged: (v) => setState(() => _freq = v ?? Frequency.monthly),
            ),
            const SizedBox(height: 16),
            _label('Inicio'),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(formatDate(_startDate)),
              trailing: const Icon(Icons.calendar_month_rounded),
              onTap: () async {
                final now = DateTime.now();
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _startDate,
                  firstDate: DateTime(now.year - 5),
                  lastDate: DateTime(now.year + 5),
                );
                if (picked != null) setState(() => _startDate = picked);
              },
            ),
            _label('Fin (opcional)'),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(_endDate == null ? 'Sin fecha de fin' : formatDate(_endDate!)),
              trailing: _endDate == null
                  ? const Icon(Icons.calendar_month_rounded)
                  : IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () => setState(() => _endDate = null),
                    ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _endDate ?? _startDate,
                  firstDate: _startDate,
                  lastDate: DateTime(_startDate.year + 10),
                );
                if (picked != null) setState(() => _endDate = picked);
              },
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

  Widget _label(String s) => Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 4),
        child: Text(
          s,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );

  Future<void> _save() async {
    final amount = double.tryParse(_amountCtrl.text);
    if (_nameCtrl.text.trim().isEmpty) return _err('Ingresa un nombre');
    if (amount == null || amount <= 0) return _err('Ingresa un monto válido');
    if (_categoryId == null) return _err('Selecciona una categoría');
    if (_accountId == null) return _err('Selecciona una cuenta');

    final p = context.read<RecurringProvider>();
    if (widget.editing == null) {
      await p.add(Recurring(
        name: _nameCtrl.text.trim(),
        amount: amount,
        kind: _kind,
        categoryId: _categoryId!,
        accountId: _accountId!,
        frequency: _freq,
        startDate: _startDate,
        endDate: _endDate,
        active: _active,
      ));
    } else {
      await p.update(widget.editing!.copyWith(
        name: _nameCtrl.text.trim(),
        amount: amount,
        kind: _kind,
        categoryId: _categoryId!,
        accountId: _accountId!,
        frequency: _freq,
        startDate: _startDate,
        endDate: _endDate,
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
        title: const Text('Eliminar pago'),
        content: const Text('Las transacciones ya creadas no se borrarán.'),
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
    await context.read<RecurringProvider>().delete(widget.editing!.id!);
    if (mounted) Navigator.of(context).pop();
  }

  void _err(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
}

class _CategoryPicker extends StatelessWidget {
  final List<Category> categories;
  final int? selectedId;
  final ValueChanged<int> onSelected;
  const _CategoryPicker({
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final c = categories[i];
          final sel = c.id == selectedId;
          return GestureDetector(
            onTap: () => onSelected(c.id!),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: sel
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: CategoryIcon(icon: c.icon, color: c.color, size: 48, iconSize: 24),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: 64,
                  child: Text(
                    c.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
