import 'package:flutter/material.dart';

class IconChoice {
  final String label;
  final IconData icon;
  const IconChoice(this.label, this.icon);
}

const kCategoryIcons = <IconChoice>[
  IconChoice('Comida', Icons.lunch_dining_rounded),
  IconChoice('Café', Icons.coffee_rounded),
  IconChoice('Bus', Icons.directions_bus_rounded),
  IconChoice('Auto', Icons.directions_car_rounded),
  IconChoice('Avión', Icons.flight_rounded),
  IconChoice('Tren', Icons.train_rounded),
  IconChoice('Combustible', Icons.local_gas_station_rounded),
  IconChoice('Salud', Icons.favorite_rounded),
  IconChoice('Farmacia', Icons.medication_rounded),
  IconChoice('Hospital', Icons.local_hospital_rounded),
  IconChoice('Ocio', Icons.sports_esports_rounded),
  IconChoice('Cine', Icons.movie_rounded),
  IconChoice('Música', Icons.music_note_rounded),
  IconChoice('Mercado', Icons.local_grocery_store_rounded),
  IconChoice('Familia', Icons.family_restroom_rounded),
  IconChoice('Niños', Icons.child_care_rounded),
  IconChoice('Casa', Icons.home_rounded),
  IconChoice('Servicios', Icons.lightbulb_rounded),
  IconChoice('Internet', Icons.wifi_rounded),
  IconChoice('Teléfono', Icons.phone_iphone_rounded),
  IconChoice('Educación', Icons.school_rounded),
  IconChoice('Libros', Icons.menu_book_rounded),
  IconChoice('Regalo', Icons.card_giftcard_rounded),
  IconChoice('Ropa', Icons.checkroom_rounded),
  IconChoice('Belleza', Icons.spa_rounded),
  IconChoice('Gimnasio', Icons.fitness_center_rounded),
  IconChoice('Deportes', Icons.sports_soccer_rounded),
  IconChoice('Finanzas', Icons.account_balance_rounded),
  IconChoice('Inversión', Icons.trending_up_rounded),
  IconChoice('Ahorro', Icons.savings_rounded),
  IconChoice('Mascotas', Icons.pets_rounded),
  IconChoice('Trabajo', Icons.work_rounded),
  IconChoice('Salario', Icons.paid_rounded),
  IconChoice('Bonus', Icons.workspace_premium_rounded),
  IconChoice('Alquiler', Icons.home_work_rounded),
  IconChoice('Viajes', Icons.luggage_rounded),
  IconChoice('Compras', Icons.shopping_bag_rounded),
  IconChoice('Restaurante', Icons.restaurant_rounded),
  IconChoice('Bar', Icons.local_bar_rounded),
  IconChoice('Otros', Icons.help_outline_rounded),
];

const kCategoryColors = <int>[
  0xFFEF4444, 0xFFF97316, 0xFFF59E0B, 0xFFEAB308,
  0xFF84CC16, 0xFF22C55E, 0xFF10B981, 0xFF14B8A6,
  0xFF06B6D4, 0xFF0EA5E9, 0xFF3B82F6, 0xFF6366F1,
  0xFF8B5CF6, 0xFFA855F7, 0xFFD946EF, 0xFFEC4899,
  0xFFF43F5E, 0xFF78716C, 0xFF6B7280, 0xFF374151,
];
