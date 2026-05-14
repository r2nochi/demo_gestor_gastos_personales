import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/icons.dart';
import '../../models/category.dart';
import '../../providers/category_provider.dart';

class CategoryEditScreen extends StatefulWidget {
  final TxKind kind;
  final Category? editing;
  const CategoryEditScreen({super.key, required this.kind, this.editing});

  @override
  State<CategoryEditScreen> createState() => _CategoryEditScreenState();
}

class _CategoryEditScreenState extends State<CategoryEditScreen> {
  final _nameCtrl = TextEditingController();
  late int _iconCode;
  late int _colorValue;

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    if (e != null) {
      _nameCtrl.text = e.name;
      _iconCode = e.iconCode;
      _colorValue = e.colorValue;
    } else {
      _iconCode = kCategoryIcons.first.icon.codePoint;
      _colorValue = kCategoryColors.first;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isNew = widget.editing == null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: scheme.primary,
        foregroundColor: Colors.white,
        title: Text(isNew ? 'Nueva categoría' : 'Editar categoría'),
        actions: [
          if (!isNew && !widget.editing!.isBuiltIn)
            IconButton(
              icon: const Icon(Icons.delete_rounded),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 96, height: 96,
                decoration: BoxDecoration(
                  color: Color(_colorValue),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  IconData(_iconCode, fontFamily: 'MaterialIcons'),
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameCtrl,
              maxLength: 24,
              decoration: const InputDecoration(labelText: 'Nombre'),
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
                for (final ic in kCategoryIcons)
                  GestureDetector(
                    onTap: () => setState(() => _iconCode = ic.icon.codePoint),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 52, height: 52,
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un nombre')),
      );
      return;
    }
    final p = context.read<CategoryProvider>();
    if (widget.editing == null) {
      final created = Category(
        name: name,
        iconCode: _iconCode,
        colorValue: _colorValue,
        kind: widget.kind,
        sortOrder: 999,
      );
      await p.add(created);
      if (mounted) {
        await p.load();
        final inserted = p.byKind(widget.kind).firstWhere(
              (c) => c.name == name && c.iconCode == _iconCode,
              orElse: () => created,
            );
        if (mounted) Navigator.of(context).pop(inserted);
      }
    } else {
      await p.update(widget.editing!.copyWith(
        name: name,
        iconCode: _iconCode,
        colorValue: _colorValue,
      ));
      if (mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _confirmDelete() async {
    if (widget.editing?.id == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar categoría'),
        content: const Text(
          'Las transacciones asociadas perderán su categoría. '
          'Esta acción no se puede deshacer.',
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
    await context.read<CategoryProvider>().delete(widget.editing!.id!);
    if (mounted) Navigator.of(context).pop();
  }
}
