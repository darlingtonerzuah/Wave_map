import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  bool _darkMode = true;
  bool _arOverlay = true;
  bool _alerts = true;
  String _plan = 'Free';

  bool get darkMode => _darkMode;
  bool get arOverlay => _arOverlay;
  bool get alerts => _alerts;
  String get plan => _plan;

  SettingsProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _darkMode = prefs.getBool('darkMode') ?? true;
    _arOverlay = prefs.getBool('arOverlay') ?? true;
    _alerts = prefs.getBool('alerts') ?? true;
    _plan = prefs.getString('plan') ?? 'Free';
    notifyListeners();
  }

  Future<void> setDarkMode(bool val) async {
    _darkMode = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', val);
    notifyListeners();
  }

  Future<void> setArOverlay(bool val) async {
    _arOverlay = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('arOverlay', val);
    notifyListeners();
  }

  Future<void> setAlerts(bool val) async {
    _alerts = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('alerts', val);
    notifyListeners();
  }

  Future<void> setPlan(String val) async {
    _plan = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('plan', val);
    notifyListeners();
  }
}