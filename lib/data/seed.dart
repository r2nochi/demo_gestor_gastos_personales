import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

Future<void> seedDefaultData(Database db) async {
  // default account
  await db.insert('accounts', {
    'name': 'Principal',
    'color_value': 0xFF5B4FE6,
    'icon_code': Icons.account_balance_wallet_rounded.codePoint,
    'initial_balance': 0.0,
    'currency_code': 'PEN',
  });

  final expenseCats = <Map<String, Object?>>[
    {'name': 'Comer fuera', 'icon': Icons.lunch_dining_rounded, 'color': 0xFF3B82F6},
    {'name': 'Transporte', 'icon': Icons.directions_bus_rounded, 'color': 0xFF2563EB},
    {'name': 'Salud', 'icon': Icons.favorite_rounded, 'color': 0xFFEF4444},
    {'name': 'Ocio', 'icon': Icons.sports_esports_rounded, 'color': 0xFF10B981},
    {'name': 'Alimentación', 'icon': Icons.local_grocery_store_rounded, 'color': 0xFF22C55E},
    {'name': 'Familia', 'icon': Icons.family_restroom_rounded, 'color': 0xFFF59E0B},
    {'name': 'Casa', 'icon': Icons.home_rounded, 'color': 0xFFF97316},
    {'name': 'Educación', 'icon': Icons.school_rounded, 'color': 0xFF3B82F6},
    {'name': 'Regalos', 'icon': Icons.card_giftcard_rounded, 'color': 0xFFEC4899},
    {'name': 'Ropa', 'icon': Icons.checkroom_rounded, 'color': 0xFFEF4444},
    {'name': 'Finanzas', 'icon': Icons.account_balance_rounded, 'color': 0xFF2563EB},
    {'name': 'Mascotas', 'icon': Icons.pets_rounded, 'color': 0xFFF59E0B},
    {'name': 'Otros', 'icon': Icons.help_outline_rounded, 'color': 0xFF6B7280},
  ];

  final incomeCats = <Map<String, Object?>>[
    {'name': 'Salario', 'icon': Icons.paid_rounded, 'color': 0xFF3B82F6},
    {'name': 'Regalo', 'icon': Icons.card_giftcard_rounded, 'color': 0xFFEC4899},
    {'name': 'Interés', 'icon': Icons.savings_rounded, 'color': 0xFF10B981},
    {'name': 'Inversiones', 'icon': Icons.trending_up_rounded, 'color': 0xFF22C55E},
    {'name': 'Alquiler', 'icon': Icons.home_work_rounded, 'color': 0xFFF97316},
    {'name': 'Otros', 'icon': Icons.help_outline_rounded, 'color': 0xFF6B7280},
  ];

  int order = 0;
  for (final c in expenseCats) {
    await db.insert('categories', {
      'name': c['name'],
      'icon_code': (c['icon'] as IconData).codePoint,
      'color_value': c['color'],
      'kind': 'expense',
      'sort_order': order++,
      'is_built_in': 1,
    });
  }
  order = 0;
  for (final c in incomeCats) {
    await db.insert('categories', {
      'name': c['name'],
      'icon_code': (c['icon'] as IconData).codePoint,
      'color_value': c['color'],
      'kind': 'income',
      'sort_order': order++,
      'is_built_in': 1,
    });
  }
}
