import 'package:flutter/material.dart';
import '../data/repositories/category_repo.dart';
import '../models/category.dart';

class CategoryProvider extends ChangeNotifier {
  final _repo = CategoryRepository();
  List<Category> _all = [];

  List<Category> get all => _all;
  List<Category> byKind(TxKind k) => _all.where((c) => c.kind == k).toList();

  Category? byId(int id) {
    try {
      return _all.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> load() async {
    _all = await _repo.all();
    notifyListeners();
  }

  Future<void> add(Category c) async {
    await _repo.insert(c);
    await load();
  }

  Future<void> update(Category c) async {
    await _repo.update(c);
    await load();
  }

  Future<void> delete(int id) async {
    await _repo.delete(id);
    await load();
  }
}
