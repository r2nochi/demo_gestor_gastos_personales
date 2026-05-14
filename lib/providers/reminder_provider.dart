import 'package:flutter/material.dart';

import '../data/repositories/reminder_repo.dart';
import '../models/reminder.dart';
import '../services/notification_service.dart';

class ReminderProvider extends ChangeNotifier {
  final _repo = ReminderRepository();
  List<Reminder> _all = [];
  List<Reminder> get all => _all;

  Future<void> load() async {
    _all = await _repo.all();
    notifyListeners();
  }

  Future<void> add(Reminder r) async {
    final id = await _repo.insert(r);
    if (r.active) {
      await NotificationService.instance.schedule(
        id: id,
        title: r.title,
        body: r.message,
        when: r.dateTime,
      );
    }
    await load();
  }

  Future<void> update(Reminder r) async {
    await _repo.update(r);
    if (r.id != null) {
      await NotificationService.instance.cancel(r.id!);
      if (r.active) {
        await NotificationService.instance.schedule(
          id: r.id!,
          title: r.title,
          body: r.message,
          when: r.dateTime,
        );
      }
    }
    await load();
  }

  Future<void> delete(int id) async {
    await NotificationService.instance.cancel(id);
    await _repo.delete(id);
    await load();
  }
}
