class Reminder {
  final int? id;
  final String title;
  final String? message;
  final DateTime dateTime;
  final bool active;

  const Reminder({
    this.id,
    required this.title,
    this.message,
    required this.dateTime,
    this.active = true,
  });

  Reminder copyWith({
    int? id,
    String? title,
    String? message,
    DateTime? dateTime,
    bool? active,
  }) =>
      Reminder(
        id: id ?? this.id,
        title: title ?? this.title,
        message: message ?? this.message,
        dateTime: dateTime ?? this.dateTime,
        active: active ?? this.active,
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'title': title,
        'message': message,
        'date_time': dateTime.toIso8601String(),
        'active': active ? 1 : 0,
      };

  factory Reminder.fromMap(Map<String, Object?> m) => Reminder(
        id: m['id'] as int?,
        title: m['title'] as String,
        message: m['message'] as String?,
        dateTime: DateTime.parse(m['date_time'] as String),
        active: (m['active'] as int?) == 1,
      );
}
