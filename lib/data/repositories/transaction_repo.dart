import '../../models/category.dart';
import '../../models/transaction.dart';
import '../database.dart';

class TxnRepository {
  Future<List<Txn>> inRange(DateTime start, DateTime end, {TxKind? kind, int? accountId}) async {
    final db = await AppDatabase.instance.db;
    final where = <String>['date >= ?', 'date < ?'];
    final args = <Object?>[start.toIso8601String(), end.toIso8601String()];
    if (kind != null) {
      where.add('kind = ?');
      args.add(kind.name);
    }
    if (accountId != null) {
      where.add('account_id = ?');
      args.add(accountId);
    }
    final rows = await db.query(
      'transactions',
      where: where.join(' AND '),
      whereArgs: args,
      orderBy: 'date DESC, id DESC',
    );
    return rows.map(Txn.fromMap).toList();
  }

  Future<List<Txn>> all({int? accountId}) async {
    final db = await AppDatabase.instance.db;
    final rows = await db.query(
      'transactions',
      where: accountId != null ? 'account_id = ?' : null,
      whereArgs: accountId != null ? [accountId] : null,
      orderBy: 'date DESC, id DESC',
    );
    return rows.map(Txn.fromMap).toList();
  }

  Future<int> insert(Txn t) async {
    final db = await AppDatabase.instance.db;
    return db.insert('transactions', t.toMap());
  }

  Future<int> update(Txn t) async {
    final db = await AppDatabase.instance.db;
    return db.update('transactions', t.toMap(), where: 'id = ?', whereArgs: [t.id]);
  }

  Future<int> delete(int id) async {
    final db = await AppDatabase.instance.db;
    return db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<double> balanceTotal({int? accountId}) async {
    final db = await AppDatabase.instance.db;
    final where = accountId != null ? 'WHERE account_id = ?' : '';
    final args = accountId != null ? [accountId] : <Object?>[];
    final res = await db.rawQuery('''
      SELECT
        COALESCE(SUM(CASE WHEN kind='income' THEN amount ELSE -amount END), 0) AS balance
      FROM transactions
      $where
    ''', args);
    return ((res.first['balance'] as num?) ?? 0).toDouble();
  }
}
