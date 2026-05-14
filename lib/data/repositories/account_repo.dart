import '../../models/account.dart';
import '../database.dart';

class AccountRepository {
  Future<List<Account>> all() async {
    final db = await AppDatabase.instance.db;
    final rows = await db.query('accounts', orderBy: 'id ASC');
    return rows.map(Account.fromMap).toList();
  }

  Future<Account?> byId(int id) async {
    final db = await AppDatabase.instance.db;
    final rows = await db.query('accounts', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return Account.fromMap(rows.first);
  }

  Future<int> insert(Account a) async {
    final db = await AppDatabase.instance.db;
    return db.insert('accounts', a.toMap());
  }

  Future<int> update(Account a) async {
    final db = await AppDatabase.instance.db;
    return db.update('accounts', a.toMap(), where: 'id = ?', whereArgs: [a.id]);
  }

  Future<int> delete(int id) async {
    final db = await AppDatabase.instance.db;
    return db.delete('accounts', where: 'id = ?', whereArgs: [id]);
  }
}
