import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/category.dart';
import '../../providers/category_provider.dart';
import '../../widgets/category_icon.dart';
import 'category_edit_screen.dart';

class CategoriesScreen extends StatefulWidget {
  final TxKind? initialKind;
  final bool picker;
  const CategoriesScreen({super.key, this.initialKind, this.picker = false});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialKind == TxKind.income ? 1 : 0,
    );
    _tab.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final kind = _tab.index == 0 ? TxKind.expense : TxKind.income;
    final cats = context.watch<CategoryProvider>().byKind(kind);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.picker ? 'Elegir categoría' : 'Categorías'),
        backgroundColor: scheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tab,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700),
          unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
          tabs: const [Tab(text: 'GASTOS'), Tab(text: 'INGRESOS')],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => CategoryEditScreen(kind: kind)),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nueva categoría'),
      ),
      body: cats.isEmpty
          ? const Center(child: Text('Aún no hay categorías.'))
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              itemCount: cats.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (_, i) {
                final c = cats[i];
                return InkWell(
                  onTap: () {
                    if (widget.picker) {
                      Navigator.of(context).pop(c);
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CategoryEditScreen(kind: kind, editing: c),
                        ),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CategoryIcon(icon: c.icon, color: c.color, size: 56, iconSize: 28),
                      const SizedBox(height: 8),
                      Text(
                        c.name,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
