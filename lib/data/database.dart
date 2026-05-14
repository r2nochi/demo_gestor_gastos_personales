import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'seed.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    final dir = await getDatabasesPath();
    final path = p.join(dir, 'saldo.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
    return _db!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        color_value INTEGER NOT NULL,
        icon_code INTEGER NOT NULL,
        initial_balance REAL NOT NULL DEFAULT 0,
        currency_code TEXT NOT NULL DEFAULT 'PEN'
      );
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon_code INTEGER NOT NULL,
        color_value INTEGER NOT NULL,
        kind TEXT NOT NULL,
        sort_order INTEGER NOT NULL DEFAULT 0,
        is_built_in INTEGER NOT NULL DEFAULT 0
      );
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        kind TEXT NOT NULL,
        category_id INTEGER NOT NULL,
        account_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        tags TEXT,
        photo_path TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories(id),
        FOREIGN KEY (account_id) REFERENCES accounts(id)
      );
    ''');
    await db.execute('CREATE INDEX idx_txn_date ON transactions(date);');
    await db.execute('CREATE INDEX idx_txn_category ON transactions(category_id);');
    await db.execute('CREATE INDEX idx_txn_kind ON transactions(kind);');

    await db.execute('''
      CREATE TABLE recurring (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        amount REAL NOT NULL,
        kind TEXT NOT NULL,
        category_id INTEGER NOT NULL,
        account_id INTEGER NOT NULL,
        frequency TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT,
        last_run TEXT,
        active INTEGER NOT NULL DEFAULT 1
      );
    ''');

    await db.execute('''
      CREATE TABLE reminders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        message TEXT,
        date_time TEXT NOT NULL,
        active INTEGER NOT NULL DEFAULT 1
      );
    ''');

    await seedDefaultData(db);
  }

  Future<void> wipe() async {
    final database = await db;
    await database.delete('transactions');
    await database.delete('recurring');
    await database.delete('reminders');
    await database.delete('categories');
    await database.delete('accounts');
    await seedDefaultData(database);
  }
}
