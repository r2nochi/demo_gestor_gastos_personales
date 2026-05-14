import '../../models/recurring.dart';
import '../database.dart';

class RecurringRepository {
  Future<List<Recurring>> all() async {
    final db = await AppDatabase.instance.db;
    final rows = await db.query('recurring', orderBy: 'id DESC');
    return rows.map(Recurring.fromMap).toList();
  }

  Future<int> insert(Recurring r) async {
    final db = await AppDatabase.instance.db;
    return db.insert('recurring', r.toMap());
  }

  Future<int> update(Recurring r) async {
    final db = await AppDatabase.instance.db;
    return db.update('recurring', r.toMap(), where: 'id = ?', whereArgs: [r.id]);
  }

  Future<int> delete(int id) async {
    final db = await AppDatabase.instance.db;
    return db.delete('recurring', where: 'id = ?', whereArgs: [id]);
  }
}
