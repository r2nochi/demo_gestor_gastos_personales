import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const _kCurrency = 'currency';
  static const _kThemeMode = 'themeMode';
  static const _kUserName = 'userName';
  static const _kPin = 'pin';
  static const _kOnboarded = 'onboarded';

  String currency = 'PEN';
  ThemeMode themeMode = ThemeMode.system;
  String userName = 'Tú';
  String? pin;
  bool onboarded = false;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    currency = p.getString(_kCurrency) ?? 'PEN';
    final tm = p.getString(_kThemeMode);
    themeMode = switch (tm) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    userName = p.getString(_kUserName) ?? 'Tú';
    pin = p.getString(_kPin);
    onboarded = p.getBool(_kOnboarded) ?? false;
    notifyListeners();
  }

  Future<void> setCurrency(String c) async {
    currency = c;
    final p = await SharedPreferences.getInstance();
    await p.setString(_kCurrency, c);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode m) async {
    themeMode = m;
    final p = await SharedPreferences.getInstance();
    final v = m == ThemeMode.light
        ? 'light'
        : m == ThemeMode.dark
            ? 'dark'
            : 'system';
    await p.setString(_kThemeMode, v);
    notifyListeners();
  }

  Future<void> setUserName(String n) async {
    userName = n;
    final p = await SharedPreferences.getInstance();
    await p.setString(_kUserName, n);
    notifyListeners();
  }

  Future<void> setPin(String? newPin) async {
    pin = newPin;
    final p = await SharedPreferences.getInstance();
    if (newPin == null) {
      await p.remove(_kPin);
    } else {
      await p.setString(_kPin, newPin);
    }
    notifyListeners();
  }

  Future<void> setOnboarded(bool v) async {
    onboarded = v;
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kOnboarded, v);
    notifyListeners();
  }
}
