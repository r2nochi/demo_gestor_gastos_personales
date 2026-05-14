import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';

import '../data/database.dart';

class BackupService {
  BackupService._();
  static final BackupService instance = BackupService._();

  Future<File> exportJson() async {
    final db = await AppDatabase.instance.db;
    final data = <String, Object?>{
      'version': 1,
      'exported_at': DateTime.now().toIso8601String(),
      'accounts': await db.query('accounts'),
      'categories': await db.query('categories'),
      'transactions': await db.query('transactions'),
      'recurring': await db.query('recurring'),
      'reminders': await db.query('reminders'),
    };
    final dir = await getTemporaryDirectory();
    final ts = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
    final f = File(p.join(dir.path, 'saldo-backup-$ts.json'));
    await f.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
    return f;
  }

  Future<File> exportCsv() async {
    final db = await AppDatabase.instance.db;
    final rows = await db.rawQuery('''
      SELECT
        t.date AS date,
        t.kind AS kind,
        t.amount AS amount,
        c.name AS category,
        a.name AS account,
        t.note AS note
      FROM transactions t
      LEFT JOIN categories c ON c.id = t.category_id
      LEFT JOIN accounts a ON a.id = t.account_id
      ORDER BY t.date DESC, t.id DESC
    ''');

    final buf = StringBuffer();
    buf.writeln('fecha,tipo,monto,categoria,cuenta,nota');
    for (final r in rows) {
      buf.writeln([
        r['date'],
        r['kind'],
        r['amount'],
        _csv(r['category'] as String?),
        _csv(r['account'] as String?),
        _csv(r['note'] as String?),
      ].join(','));
    }

    final dir = await getTemporaryDirectory();
    final ts = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
    final f = File(p.join(dir.path, 'saldo-export-$ts.csv'));
    await f.writeAsString(buf.toString());
    return f;
  }

  Future<void> share(File file, {String? subject}) async {
    await Share.shareXFiles([XFile(file.path)], subject: subject);
  }

  Future<int> importJson(String jsonStr) async {
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;
    final db = await AppDatabase.instance.db;
    int total = 0;
    await db.transaction((tx) async {
      await tx.delete('transactions');
      await tx.delete('recurring');
      await tx.delete('reminders');
      await tx.delete('categories');
      await tx.delete('accounts');
      for (final row in (data['accounts'] as List? ?? [])) {
        await tx.insert('accounts', Map<String, Object?>.from(row),
            conflictAlgorithm: ConflictAlgorithm.replace);
        total++;
      }
      for (final row in (data['categories'] as List? ?? [])) {
        await tx.insert('categories', Map<String, Object?>.from(row),
            conflictAlgorithm: ConflictAlgorithm.replace);
        total++;
      }
      for (final row in (data['transactions'] as List? ?? [])) {
        await tx.insert('transactions', Map<String, Object?>.from(row),
            conflictAlgorithm: ConflictAlgorithm.replace);
        total++;
      }
      for (final row in (data['recurring'] as List? ?? [])) {
        await tx.insert('recurring', Map<String, Object?>.from(row),
            conflictAlgorithm: ConflictAlgorithm.replace);
        total++;
      }
      for (final row in (data['reminders'] as List? ?? [])) {
        await tx.insert('reminders', Map<String, Object?>.from(row),
            conflictAlgorithm: ConflictAlgorithm.replace);
        total++;
      }
    });
    return total;
  }

  String _csv(String? s) {
    if (s == null) return '';
    final needsQuote = s.contains(',') || s.contains('"') || s.contains('\n');
    final escaped = s.replaceAll('"', '""');
    return needsQuote ? '"$escaped"' : escaped;
  }
}
