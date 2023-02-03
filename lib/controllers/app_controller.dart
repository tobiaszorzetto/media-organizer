import 'package:flutter/material.dart';

class AppController extends ChangeNotifier {
  static AppController instance = AppController();

  ThemeData theme = ThemeData.dark();
  bool darkMode = true;

  void changeTheme() {
    if (darkMode) {
      theme = ThemeData.fallback();
      darkMode = false;
    } else {
      theme = ThemeData.dark();
      darkMode = true;
    }
    notifyListeners();
  }
}
