import 'package:flutter/material.dart';

import '../providers/transaction_provider.dart';

class PeriodSelector extends StatelessWidget {
  final PeriodMode current;
  final ValueChanged<PeriodMode> onChanged;
  const PeriodSelector({super.key, required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final items = const [
      (PeriodMode.day, 'Día'),
      (PeriodMode.week, 'Semana'),
      (PeriodMode.month, 'Mes'),
      (PeriodMode.year, 'Año'),
      (PeriodMode.custom, 'Período'),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (final it in items)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(it.$2),
                selected: current == it.$1,
                onSelected: (_) => onChanged(it.$1),
                showCheckmark: false,
                labelStyle: TextStyle(
                  fontWeight: current == it.$1 ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
