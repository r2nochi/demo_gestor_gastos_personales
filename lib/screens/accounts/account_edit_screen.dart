import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/icons.dart';
import '../../models/account.dart';
import '../../providers/account_provider.dart';
import '../../providers/transaction_provider.dart';

class AccountEditScreen extends StatefulWidget {
  final Account? editing;
  const AccountEditScreen({super.key, this.editing});

  @override
  State<AccountEditScreen> createState() => _AccountEditScreenState();
}

class _AccountEditScreenState extends State<AccountEditScreen> {
  final _nameCtrl = TextEditingController();
  final _balanceCtrl = TextEditingController();
  late int _iconCode;
  late int _colorValue;

  static const _kAccountIcons = <IconChoice>[
    IconChoice('Billetera', Icons.account_balance_wallet_rounded),
    IconChoice('Banco', Icons.account_balance_rounded),
    IconChoice('Tarjeta', Icons.credit_card_rounded),
    IconChoice('Efectivo', Icons.payments_rounded),
    IconChoice('Ahorros', Icons.savings_rounded),
    IconChoice('Inversiones', Icons.trending_up_rounded),
    IconChoice('Hucha', Icons.attach_money_rounded),
    IconChoice('Móvil', Icons.phone_iphone_rounded),
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    if (e != null) {
      _nameCtrl.text = e.name;
      _balanceCtrl.text = e.initialBalance.toStringAsFixed(2);
      _iconCode = e.iconCode;
      _colorValue = e.colorValue;
    } else {
      _iconCode = Icons.account_balance_wallet_rounded.codePoint;
      _colorValue = kCategoryColors.first;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _balanceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editing == null ? 'Nueva cuenta' : 'Editar cuenta'),
        backgroundColor: scheme.primary,
        foregroundColor: Colors.white,
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
            Center(
              child: Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: Color(_colorValue),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  IconData(_iconCode, fontFamily: 'MaterialIcons'),
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameCtrl,
              maxLength: 32,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _balanceCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d{0,2}')),
              ],
              decoration: const InputDecoration(labelText: 'Saldo inicial'),
            ),
            const SizedBox(height: 24),
            const Text('Color', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10, runSpacing: 10,
              children: [
                for (final c in kCategoryColors)
                  GestureDetector(
                    onTap: () => setState(() => _colorValue = c),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: Color(c),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _colorValue == c ? scheme.onSurface : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Ícono', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10, runSpacing: 10,
              children: [
                for (final ic in _kAccountIcons)
                  GestureDetector(
                    onTap: () => setState(() => _iconCode = ic.icon.codePoint),
                    child: Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        color: _iconCode == ic.icon.codePoint
                            ? Color(_colorValue)
                            : scheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        ic.icon,
                        color: _iconCode == ic.icon.codePoint
                            ? Colors.white
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
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

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Ingresa un nombre')));
      return;
    }
    final bal = double.tryParse(_balanceCtrl.text) ?? 0;
    final p = context.read<AccountProvider>();
    if (widget.editing == null) {
      await p.add(Account(
        name: name,
        colorValue: _colorValue,
        iconCode: _iconCode,
        initialBalance: bal,
      ));
    } else {
      await p.update(widget.editing!.copyWith(
        name: name,
        colorValue: _colorValue,
        iconCode: _iconCode,
        initialBalance: bal,
      ));
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _confirmDelete() async {
    if (widget.editing?.id == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar cuenta'),
        content: const Text(
          'Las transacciones asociadas quedarán huérfanas. '
          'Recomendamos solo eliminar cuentas sin movimientos.',
        ),
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
    if (ok != true) return;
    await context.read<AccountProvider>().delete(widget.editing!.id!);
    await context.read<TransactionProvider>().load();
    if (mounted) Navigator.of(context).pop();
  }
}
