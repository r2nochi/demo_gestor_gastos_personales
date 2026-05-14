import 'category.dart';

class Txn {
  final int? id;
  final double amount;
  final TxKind kind;
  final int categoryId;
  final int accountId;
  final DateTime date;
  final String? note;
  final String? tags;
  final String? photoPath;
  final DateTime createdAt;

  const Txn({
    this.id,
    required this.amount,
    required this.kind,
    required this.categoryId,
    required this.accountId,
    required this.date,
    this.note,
    this.tags,
    this.photoPath,
    required this.createdAt,
  });

  Txn copyWith({
    int? id,
    double? amount,
    TxKind? kind,
    int? categoryId,
    int? accountId,
    DateTime? date,
    String? note,
    String? tags,
    String? photoPath,
    DateTime? createdAt,
  }) =>
      Txn(
        id: id ?? this.id,
        amount: amount ?? this.amount,
        kind: kind ?? this.kind,
        categoryId: categoryId ?? this.categoryId,
        accountId: accountId ?? this.accountId,
        date: date ?? this.date,
        note: note ?? this.note,
        tags: tags ?? this.tags,
        photoPath: photoPath ?? this.photoPath,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'amount': amount,
        'kind': kind.name,
        'category_id': categoryId,
        'account_id': accountId,
        'date': date.toIso8601String(),
        'note': note,
        'tags': tags,
        'photo_path': photoPath,
        'created_at': createdAt.toIso8601String(),
      };

  factory Txn.fromMap(Map<String, Object?> m) => Txn(
        id: m['id'] as int?,
        amount: (m['amount'] as num).toDouble(),
        kind: (m['kind'] as String) == 'income' ? TxKind.income : TxKind.expense,
        categoryId: m['category_id'] as int,
        accountId: m['account_id'] as int,
        date: DateTime.parse(m['date'] as String),
        note: m['note'] as String?,
        tags: m['tags'] as String?,
        photoPath: m['photo_path'] as String?,
        createdAt: DateTime.parse(m['created_at'] as String),
      );
}
