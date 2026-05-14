class Account {
  final int? id;
  final String name;
  final int colorValue;
  final int iconCode;
  final double initialBalance;
  final String currencyCode;

  const Account({
    this.id,
    required this.name,
    required this.colorValue,
    required this.iconCode,
    this.initialBalance = 0,
    this.currencyCode = 'PEN',
  });

  Account copyWith({
    int? id,
    String? name,
    int? colorValue,
    int? iconCode,
    double? initialBalance,
    String? currencyCode,
  }) =>
      Account(
        id: id ?? this.id,
        name: name ?? this.name,
        colorValue: colorValue ?? this.colorValue,
        iconCode: iconCode ?? this.iconCode,
        initialBalance: initialBalance ?? this.initialBalance,
        currencyCode: currencyCode ?? this.currencyCode,
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'color_value': colorValue,
        'icon_code': iconCode,
        'initial_balance': initialBalance,
        'currency_code': currencyCode,
      };

  factory Account.fromMap(Map<String, Object?> m) => Account(
        id: m['id'] as int?,
        name: m['name'] as String,
        colorValue: m['color_value'] as int,
        iconCode: m['icon_code'] as int,
        initialBalance: (m['initial_balance'] as num?)?.toDouble() ?? 0,
        currencyCode: (m['currency_code'] as String?) ?? 'PEN',
      );
}
