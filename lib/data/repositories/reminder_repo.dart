import '../../models/reminder.dart';
import '../database.dart';

class ReminderRepository {
  Future<List<Reminder>> all() async {
    final db = await AppDatabase.instance.db;
    final rows = await db.query('reminders', orderBy: 'date_time ASC');
    return rows.map(Reminder.fromMap).toList();
  }

  Future<int> insert(Reminder r) async {
    final db = await AppDatabase.instance.db;
    return db.insert('reminders', r.toMap());
  }

  Future<int> update(Reminder r) async {
    final db = await AppDatabase.instance.db;
    return db.update('reminders', r.toMap(), where: 'id = ?', whereArgs: [r.id]);
  }

  Future<int> delete(int id) async {
    final db = await AppDatabase.instance.db;
    return db.delete('reminders', where: 'id = ?', whereArgs: [id]);
  }
}
