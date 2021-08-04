import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

ThemeData light = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blueGrey,
    accentColor: Colors.deepOrange,
    scaffoldBackgroundColor: Color(0xfff1f1f1));

ThemeData dark = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.blueGrey,
  accentColor: Colors.blueGrey[700],
  // scaffoldBackgroundColor: Color(0xfff1f1f1)
);

class ThemeNotifier extends ChangeNotifier {
  final String key = "theme";
  SharedPreferences sharedPreferences;
  bool _darkTheme;

  bool get darkTheme => _darkTheme;

  ThemeNotifier() {
    _darkTheme = true;
    _loadSharedPrefs();
  }

  toggleTheme() {
    _darkTheme = !_darkTheme;
    _saveToSharedPrefs();
    notifyListeners();
  }

  _initSharedPrefs() async {
    if (sharedPreferences == null)
      sharedPreferences = await SharedPreferences.getInstance();
  }

  _loadSharedPrefs() async {
    await _initSharedPrefs();
    _darkTheme = sharedPreferences.getBool(key) ?? true;
    notifyListeners();
  }

  _saveToSharedPrefs() async {
    await _initSharedPrefs();
    sharedPreferences.setBool(key, _darkTheme);
  }
}