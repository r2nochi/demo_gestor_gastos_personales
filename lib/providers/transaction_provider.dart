import 'package:flutter/material.dart';
import '../data/repositories/transaction_repo.dart';
import '../models/category.dart';
import '../models/transaction.dart';

enum PeriodMode { day, week, month, year, custom }

class TransactionProvider extends ChangeNotifier {
  final _repo = TxnRepository();

  List<Txn> _all = [];
  PeriodMode period = PeriodMode.week;
  DateTime _cursor = DateTime.now();
  DateTime? _customStart;
  DateTime? _customEnd;

  List<Txn> get all => _all;
  DateTime get cursor => _cursor;
  DateTime? get customStart => _customStart;
  DateTime? get customEnd => _customEnd;

  ({DateTime start, DateTime end}) get range {
    final c = _cursor;
    switch (period) {
      case PeriodMode.day:
        final start = DateTime(c.year, c.month, c.day);
        return (start: start, end: start.add(const Duration(days: 1)));
      case PeriodMode.week:
        final weekday = c.weekday; // 1=Mon
        final start = DateTime(c.year, c.month, c.day - (weekday - 1));
        return (start: start, end: start.add(const Duration(days: 7)));
      case PeriodMode.month:
        final start = DateTime(c.year, c.month, 1);
        final end = DateTime(c.year, c.month + 1, 1);
        return (start: start, end: end);
      case PeriodMode.year:
        return (start: DateTime(c.year, 1, 1), end: DateTime(c.year + 1, 1, 1));
      case PeriodMode.custom:
        final s = _customStart ?? DateTime(c.year, c.month, c.day);
        final e = _customEnd ?? s.add(const Duration(days: 1));
        return (start: s, end: e.add(const Duration(days: 1)));
    }
  }

  Future<void> load() async {
    _all = await _repo.all();
    notifyListeners();
  }

  List<Txn> currentByKind(TxKind kind, {int? accountId}) {
    final r = range;
    return _all.where((t) =>
        t.kind == kind &&
        !t.date.isBefore(r.start) &&
        t.date.isBefore(r.end) &&
        (accountId == null || t.accountId == accountId)).toList();
  }

  List<Txn> currentAll({int? accountId}) {
    final r = range;
    return _all.where((t) =>
        !t.date.isBefore(r.start) &&
        t.date.isBefore(r.end) &&
        (accountId == null || t.accountId == accountId)).toList();
  }

  void setPeriod(PeriodMode m) {
    period = m;
    notifyListeners();
  }

  void shift(int direction) {
    final c = _cursor;
    switch (period) {
      case PeriodMode.day:
        _cursor = c.add(Duration(days: direction));
        break;
      case PeriodMode.week:
        _cursor = c.add(Duration(days: 7 * direction));
        break;
      case PeriodMode.month:
        _cursor = DateTime(c.year, c.month + direction, c.day.clamp(1, 28));
        break;
      case PeriodMode.year:
        _cursor = DateTime(c.year + direction, c.month, c.day);
        break;
      case PeriodMode.custom:
        break;
    }
    notifyListeners();
  }

  void setCustomRange(DateTime start, DateTime end) {
    _customStart = start;
    _customEnd = end;
    period = PeriodMode.custom;
    notifyListeners();
  }

  Future<void> add(Txn t) async {
    await _repo.insert(t);
    await load();
  }

  Future<void> update(Txn t) async {
    await _repo.update(t);
    await load();
  }

  Future<void> delete(int id) async {
    await _repo.delete(id);
    await load();
  }

  double totalIncome({int? accountId}) =>
      currentByKind(TxKind.income, accountId: accountId).fold<double>(0, (s, t) => s + t.amount);
  double totalExpense({int? accountId}) =>
      currentByKind(TxKind.expense, accountId: accountId).fold<double>(0, (s, t) => s + t.amount);
  double balance({int? accountId}) => totalIncome(accountId: accountId) - totalExpense(accountId: accountId);

  double balanceAllTime({int? accountId}) {
    return _all.where((t) => accountId == null || t.accountId == accountId).fold<double>(
      0,
      (s, t) => s + (t.kind == TxKind.income ? t.amount : -t.amount),
    );
  }
}
