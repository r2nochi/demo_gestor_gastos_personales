import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/formatters.dart';
import '../../models/category.dart';
import '../../models/transaction.dart';
import '../../providers/account_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/category_icon.dart';
import '../categories/categories_screen.dart';

class AddTransactionScreen extends StatefulWidget {
  final Txn? editing;
  const AddTransactionScreen({super.key, this.editing});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  int? _categoryId;
  int? _accountId;
  DateTime _date = DateTime.now();
  TxKind _kind = TxKind.expense;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    final e = widget.editing;
    if (e != null) {
      _kind = e.kind;
      _tab.index = _kind == TxKind.expense ? 0 : 1;
      _amountCtrl.text = e.amount.toStringAsFixed(
        e.amount.truncateToDouble() == e.amount ? 0 : 2,
      );
      _noteCtrl.text = e.note ?? '';
      _categoryId = e.categoryId;
      _accountId = e.accountId;
      _date = e.date;
    }
    _tab.addListener(() {
      if (mounted) {
        setState(() {
          _kind = _tab.index == 0 ? TxKind.expense : TxKind.income;
          _categoryId = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final cats = context.watch<CategoryProvider>().byKind(_kind);
    final accProvider = context.watch<AccountProvider>();
    final settings = context.watch<SettingsProvider>();
    _accountId ??= accProvider.selectedId;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.primary,
        foregroundColor: Colors.white,
        title: Text(widget.editing == null ? 'Añadir transacción' : 'Editar transacción'),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
          tabs: const [Tab(text: 'GASTOS'), Tab(text: 'INGRESOS')],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        color: _kind == TxKind.expense
                            ? scheme.error
                            : const Color(0xFF10B981),
                      ),
                      decoration: const InputDecoration(
                        hintText: '0',
                        border: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      settings.currency,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 24),
              _label('Cuenta'),
              const SizedBox(height: 6),
              DropdownButton<int>(
                value: _accountId,
                isExpanded: true,
                underline: const SizedBox.shrink(),
                items: accProvider.all
                    .map((a) => DropdownMenuItem(
                          value: a.id,
                          child: Row(
                            children: [
                              Icon(
                                IconData(a.iconCode, fontFamily: 'MaterialIcons'),
                                color: Color(a.colorValue),
                              ),
                              const SizedBox(width: 8),
                              Text(a.name, style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _accountId = v),
              ),
              const SizedBox(height: 16),
              _label('Categoría'),
              const SizedBox(height: 12),
              _CategoryGrid(
                categories: cats,
                selectedId: _categoryId,
                onSelected: (id) => setState(() => _categoryId = id),
                onAdd: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CategoriesScreen(initialKind: _kind, picker: true),
                  ),
                ).then((picked) {
                  if (picked is Category && picked.id != null) {
                    setState(() => _categoryId = picked.id);
                  }
                }),
              ),
              const SizedBox(height: 24),
              _label('Fecha'),
              const SizedBox(height: 8),
              _DateChips(date: _date, onChanged: (d) => setState(() => _date = d)),
              const SizedBox(height: 24),
              _label('Comentario'),
              const SizedBox(height: 8),
              TextField(
                controller: _noteCtrl,
                maxLines: 3,
                maxLength: 4096,
                decoration: const InputDecoration(
                  hintText: 'Descripción opcional',
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _save,
            style: FilledButton.styleFrom(
              backgroundColor: scheme.primary,
              minimumSize: const Size.fromHeight(56),
            ),
            child: Text(widget.editing == null ? 'Añadir' : 'Guardar'),
          ),
        ),
      ),
    );
  }

  Widget _label(String s) => Text(
        s,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );

  Future<void> _save() async {
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0) {
      _err('Ingresa un monto válido');
      return;
    }
    if (_categoryId == null) {
      _err('Selecciona una categoría');
      return;
    }
    if (_accountId == null) {
      _err('Selecciona una cuenta');
      return;
    }
    final tx = context.read<TransactionProvider>();
    final editing = widget.editing;
    if (editing == null) {
      await tx.add(Txn(
        amount: amount,
        kind: _kind,
        categoryId: _categoryId!,
        accountId: _accountId!,
        date: _date,
        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
        createdAt: DateTime.now(),
      ));
    } else {
      await tx.update(editing.copyWith(
        amount: amount,
        kind: _kind,
        categoryId: _categoryId!,
        accountId: _accountId!,
        date: _date,
        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      ));
    }
    if (mounted) Navigator.of(context).pop();
  }

  void _err(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
}

class _CategoryGrid extends StatelessWidget {
  final List<Category> categories;
  final int? selectedId;
  final ValueChanged<int> onSelected;
  final VoidCallback onAdd;
  const _CategoryGrid({
    required this.categories,
    required this.selectedId,
    required this.onSelected,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final items = [...categories];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length + 1,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (_, i) {
        if (i == items.length) {
          return InkWell(
            onTap: onAdd,
            borderRadius: BorderRadius.circular(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 6),
                const Text('Más', style: TextStyle(fontSize: 12)),
              ],
            ),
          );
        }
        final c = items[i];
        final selected = c.id == selectedId;
        return InkWell(
          onTap: () => onSelected(c.id!),
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    width: 3,
                  ),
                ),
                padding: const EdgeInsets.all(2),
                child: CategoryIcon(
                  icon: c.icon,
                  color: c.color,
                  size: 52,
                  iconSize: 26,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                c.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DateChips extends StatelessWidget {
  final DateTime date;
  final ValueChanged<DateTime> onChanged;
  const _DateChips({required this.date, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final twoDays = today.subtract(const Duration(days: 2));
    final selected = DateTime(date.year, date.month, date.day);

    Widget chip(DateTime d, String label) {
      final isSel = d == selected;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(formatDateShort(d), style: const TextStyle(fontWeight: FontWeight.w700)),
              Text(label, style: const TextStyle(fontSize: 11)),
            ],
          ),
          selected: isSel,
          showCheckmark: false,
          onSelected: (_) => onChanged(d),
        ),
      );
    }

    return Row(
      children: [
        chip(today, 'hoy'),
        chip(yesterday, 'ayer'),
        chip(twoDays, 'hace dos días'),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.calendar_month_rounded),
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(now.year - 5),
              lastDate: DateTime(now.year + 1),
            );
            if (picked != null) onChanged(picked);
          },
        ),
      ],
    );
  }
}
