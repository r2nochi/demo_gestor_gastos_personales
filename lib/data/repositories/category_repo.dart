import '../../models/category.dart';
import '../database.dart';

class CategoryRepository {
  Future<List<Category>> all() async {
    final db = await AppDatabase.instance.db;
    final rows = await db.query('categories', orderBy: 'sort_order ASC, id ASC');
    return rows.map(Category.fromMap).toList();
  }

  Future<List<Category>> byKind(TxKind kind) async {
    final db = await AppDatabase.instance.db;
    final rows = await db.query(
      'categories',
      where: 'kind = ?',
      whereArgs: [kind.name],
      orderBy: 'sort_order ASC, id ASC',
    );
    return rows.map(Category.fromMap).toList();
  }

  Future<Category?> byId(int id) async {
    final db = await AppDatabase.instance.db;
    final rows = await db.query('categories', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return Category.fromMap(rows.first);
  }

  Future<int> insert(Category c) async {
    final db = await AppDatabase.instance.db;
    return db.insert('categories', c.toMap());
  }

  Future<int> update(Category c) async {
    final db = await AppDatabase.instance.db;
    return db.update('categories', c.toMap(), where: 'id = ?', whereArgs: [c.id]);
  }

  Future<int> delete(int id) async {
    final db = await AppDatabase.instance.db;
    return db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }
}
