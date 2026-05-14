import 'package:flutter/material.dart';

import '../data/repositories/recurring_repo.dart';
import '../data/repositories/transaction_repo.dart';
import '../models/recurring.dart';
import '../models/transaction.dart';

class RecurringProvider extends ChangeNotifier {
  final _repo = RecurringRepository();
  final _txnRepo = TxnRepository();

  List<Recurring> _all = [];
  List<Recurring> get all => _all;

  Future<void> load() async {
    _all = await _repo.all();
    notifyListeners();
  }

  Future<void> add(Recurring r) async {
    await _repo.insert(r);
    await load();
  }

  Future<void> update(Recurring r) async {
    await _repo.update(r);
    await load();
  }

  Future<void> delete(int id) async {
    await _repo.delete(id);
    await load();
  }

  /// Runs through every active recurring item and inserts pending occurrences
  /// up to and including today. Returns how many transactions were created.
  Future<int> runDue() async {
    await load();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int created = 0;

    for (final r in _all.where((x) => x.active)) {
      var cursor = r.lastRun ?? r.startDate.subtract(const Duration(days: 1));
      var next = _nextOccurrence(cursor, r);
      while (!next.isAfter(today) &&
          (r.endDate == null || !next.isAfter(r.endDate!))) {
        await _txnRepo.insert(Txn(
          amount: r.amount,
          kind: r.kind,
          categoryId: r.categoryId,
          accountId: r.accountId,
          date: next,
          note: r.name,
          createdAt: DateTime.now(),
        ));
        cursor = next;
        next = _nextOccurrence(cursor, r);
        created++;
      }
      if (cursor != (r.lastRun ?? r.startDate.subtract(const Duration(days: 1)))) {
        await _repo.update(r.copyWith(lastRun: cursor));
      }
    }
    await load();
    return created;
  }

  DateTime _nextOccurrence(DateTime cursor, Recurring r) {
    switch (r.frequency) {
      case Frequency.daily:
        return cursor.add(const Duration(days: 1));
      case Frequency.weekly:
        return cursor.add(const Duration(days: 7));
      case Frequency.monthly:
        final m = cursor.month + 1;
        final y = cursor.year + (m > 12 ? 1 : 0);
        final mm = ((m - 1) % 12) + 1;
        final lastDay = DateTime(y, mm + 1, 0).day;
        final day = r.startDate.day.clamp(1, lastDay);
        return DateTime(y, mm, day);
      case Frequency.yearly:
        return DateTime(cursor.year + 1, r.startDate.month, r.startDate.day);
    }
  }
}
