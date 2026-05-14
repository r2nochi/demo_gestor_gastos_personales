import 'package:flutter/material.dart';
import '../data/repositories/account_repo.dart';
import '../models/account.dart';

class AccountProvider extends ChangeNotifier {
  final _repo = AccountRepository();
  List<Account> _all = [];
  int _selectedId = 0;

  List<Account> get all => _all;
  int get selectedId => _selectedId;
  Account? get selected => _all.firstWhere(
        (a) => a.id == _selectedId,
        orElse: () => _all.isNotEmpty ? _all.first : const Account(
          name: 'Principal',
          colorValue: 0xFF5B4FE6,
          iconCode: 0xe2c4,
        ),
      );

  Account? byId(int id) {
    try {
      return _all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> load() async {
    _all = await _repo.all();
    if (_all.isNotEmpty && _selectedId == 0) {
      _selectedId = _all.first.id ?? 0;
    }
    notifyListeners();
  }

  void select(int id) {
    _selectedId = id;
    notifyListeners();
  }

  Future<void> add(Account a) async {
    await _repo.insert(a);
    await load();
  }

  Future<void> update(Account a) async {
    await _repo.update(a);
    await load();
  }

  Future<void> delete(int id) async {
    await _repo.delete(id);
    await load();
  }
}
