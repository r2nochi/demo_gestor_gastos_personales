import 'category.dart';

enum Frequency { daily, weekly, monthly, yearly }

class Recurring {
  final int? id;
  final String name;
  final double amount;
  final TxKind kind;
  final int categoryId;
  final int accountId;
  final Frequency frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? lastRun;
  final bool active;

  const Recurring({
    this.id,
    required this.name,
    required this.amount,
    required this.kind,
    required this.categoryId,
    required this.accountId,
    required this.frequency,
    required this.startDate,
    this.endDate,
    this.lastRun,
    this.active = true,
  });

  Recurring copyWith({
    int? id,
    String? name,
    double? amount,
    TxKind? kind,
    int? categoryId,
    int? accountId,
    Frequency? frequency,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? lastRun,
    bool? active,
  }) =>
      Recurring(
        id: id ?? this.id,
        name: name ?? this.name,
        amount: amount ?? this.amount,
        kind: kind ?? this.kind,
        categoryId: categoryId ?? this.categoryId,
        accountId: accountId ?? this.accountId,
        frequency: frequency ?? this.frequency,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        lastRun: lastRun ?? this.lastRun,
        active: active ?? this.active,
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'amount': amount,
        'kind': kind.name,
        'category_id': categoryId,
        'account_id': accountId,
        'frequency': frequency.name,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
        'last_run': lastRun?.toIso8601String(),
        'active': active ? 1 : 0,
      };

  factory Recurring.fromMap(Map<String, Object?> m) => Recurring(
        id: m['id'] as int?,
        name: m['name'] as String,
        amount: (m['amount'] as num).toDouble(),
        kind: (m['kind'] as String) == 'income' ? TxKind.income : TxKind.expense,
        categoryId: m['category_id'] as int,
        accountId: m['account_id'] as int,
        frequency: Frequency.values.firstWhere((e) => e.name == m['frequency']),
        startDate: DateTime.parse(m['start_date'] as String),
        endDate: m['end_date'] != null ? DateTime.parse(m['end_date'] as String) : null,
        lastRun: m['last_run'] != null ? DateTime.parse(m['last_run'] as String) : null,
        active: (m['active'] as int?) == 1,
      );
}
