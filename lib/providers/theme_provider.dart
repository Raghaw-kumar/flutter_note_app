import 'package:flutter/material.dart';
import '../themes/light_theme.dart';
import '../themes/dark_theme.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = lightTheme();
  bool _isDarkMode = false;

  ThemeData get themeData => _themeData;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _themeData = _isDarkMode ? darkTheme() : lightTheme();
    notifyListeners();
  }
}