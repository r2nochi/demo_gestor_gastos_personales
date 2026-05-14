import 'package:flutter/material.dart';

enum TxKind { expense, income }

class Category {
  final int? id;
  final String name;
  final int iconCode;
  final int colorValue;
  final TxKind kind;
  final int sortOrder;
  final bool isBuiltIn;

  const Category({
    this.id,
    required this.name,
    required this.iconCode,
    required this.colorValue,
    required this.kind,
    this.sortOrder = 0,
    this.isBuiltIn = false,
  });

  Color get color => Color(colorValue);
  IconData get icon => IconData(iconCode, fontFamily: 'MaterialIcons');

  Category copyWith({
    int? id,
    String? name,
    int? iconCode,
    int? colorValue,
    TxKind? kind,
    int? sortOrder,
    bool? isBuiltIn,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCode: iconCode ?? this.iconCode,
      colorValue: colorValue ?? this.colorValue,
      kind: kind ?? this.kind,
      sortOrder: sortOrder ?? this.sortOrder,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
    );
  }

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'icon_code': iconCode,
        'color_value': colorValue,
        'kind': kind.name,
        'sort_order': sortOrder,
        'is_built_in': isBuiltIn ? 1 : 0,
      };

  factory Category.fromMap(Map<String, Object?> m) => Category(
        id: m['id'] as int?,
        name: m['name'] as String,
        iconCode: m['icon_code'] as int,
        colorValue: m['color_value'] as int,
        kind: (m['kind'] as String) == 'income' ? TxKind.income : TxKind.expense,
        sortOrder: (m['sort_order'] as int?) ?? 0,
        isBuiltIn: (m['is_built_in'] as int?) == 1,
      );
}
