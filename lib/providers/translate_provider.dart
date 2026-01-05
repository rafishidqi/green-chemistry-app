import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TranslateProvider extends ChangeNotifier {
  static const String _languageKey = 'app_language';
  static const String _defaultLanguage = 'id';

  String _currentLanguage = _defaultLanguage;

  String get currentLanguage => _currentLanguage;

  bool get isEnglish => _currentLanguage == 'en';
  bool get isIndonesian => _currentLanguage == 'id';

  TranslateProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString(_languageKey) ?? _defaultLanguage;
    notifyListeners();
  }

  Future<void> toggleLanguage() async {
    _currentLanguage = _currentLanguage == 'id' ? 'en' : 'id';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, _currentLanguage);
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    if (languageCode != 'en' && languageCode != 'id') return;
    _currentLanguage = languageCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, _currentLanguage);
    notifyListeners();
  }
}

