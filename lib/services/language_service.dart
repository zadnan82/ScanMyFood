// lib/services/language_service.dart
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static LanguageService? _instance;
  static LanguageService get instance => _instance ??= LanguageService._();
  LanguageService._();

  String _currentLanguage = 'English';
  Map<String, dynamic> _currentTranslations = {};
  Map<String, dynamic> _currentIngredients = {};

  // Supported languages with their codes and ingredient file names
  static const Map<String, Map<String, String>> supportedLanguages = {
    'English': {
      'code': 'en',
      'flag': 'gb',
      'ingredientsFile': 'assets/ingredients_en.json',
      'translationsFile': 'assets/translations_en.json',
    },
    'Swedish': {
      'code': 'sv',
      'flag': 'se',
      'ingredientsFile': 'assets/ingredients_sv.json',
      'translationsFile': 'assets/translations_sv.json',
    },
    'Spanish': {
      'code': 'es',
      'flag': 'es',
      'ingredientsFile': 'assets/ingredients_es.json',
      'translationsFile': 'assets/translations_es.json',
    },
  };

  // Getters
  String get currentLanguage => _currentLanguage;
  String get currentLanguageCode =>
      supportedLanguages[_currentLanguage]?['code'] ?? 'en';
  String get currentFlag =>
      supportedLanguages[_currentLanguage]?['flag'] ?? 'gb';
  Map<String, dynamic> get ingredients => _currentIngredients;
  List<String> get harmfulIngredientKeys => _currentIngredients.keys.toList();

  // Initialize language service
  Future<void> initialize() async {
    await _loadSavedLanguage();
    await _loadLanguageData();
  }

  // Load saved language from SharedPreferences
  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('language') ?? 'English';
  }

  // Change language
  Future<void> changeLanguage(String language) async {
    if (!supportedLanguages.containsKey(language)) return;

    _currentLanguage = language;

    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);

    // Load new language data
    await _loadLanguageData();
  }

  // Load both ingredients and translations for current language
  Future<void> _loadLanguageData() async {
    await Future.wait([
      _loadIngredients(),
      _loadTranslations(),
    ]);
  }

  // Load ingredients for current language
  Future<void> _loadIngredients() async {
    try {
      final ingredientsFile =
          supportedLanguages[_currentLanguage]?['ingredientsFile'];
      if (ingredientsFile == null) return;

      final jsonString = await rootBundle.loadString(ingredientsFile);
      final jsonData = json.decode(jsonString);
      _currentIngredients = jsonData['ingredients'] ?? {};
    } catch (e) {
      print('Error loading ingredients for $_currentLanguage: $e');
      // Fallback to English
      if (_currentLanguage != 'English') {
        try {
          final jsonString =
              await rootBundle.loadString('assets/ingredients_en.json');
          final jsonData = json.decode(jsonString);
          _currentIngredients = jsonData['ingredients'] ?? {};
        } catch (fallbackError) {
          print('Error loading fallback ingredients: $fallbackError');
          _currentIngredients = {};
        }
      }
    }
  }

  // Load UI translations for current language
  Future<void> _loadTranslations() async {
    try {
      final translationsFile =
          supportedLanguages[_currentLanguage]?['translationsFile'];
      if (translationsFile == null) return;

      final jsonString = await rootBundle.loadString(translationsFile);
      _currentTranslations = json.decode(jsonString);
    } catch (e) {
      print('Error loading translations for $_currentLanguage: $e');
      // Fallback to English
      if (_currentLanguage != 'English') {
        try {
          final jsonString =
              await rootBundle.loadString('assets/translations_en.json');
          _currentTranslations = json.decode(jsonString);
        } catch (fallbackError) {
          print('Error loading fallback translations: $fallbackError');
          _currentTranslations = {};
        }
      }
    }
  }

  // Get translated text
  String translate(String key, [String? fallback]) {
    final keys = key.split('.');
    dynamic current = _currentTranslations;

    for (final k in keys) {
      if (current is Map<String, dynamic> && current.containsKey(k)) {
        current = current[k];
      } else {
        return fallback ??
            key; // Return fallback or key if translation not found
      }
    }

    return current is String ? current : (fallback ?? key);
  }

  // Get ingredient data by key
  Map<String, dynamic>? getIngredient(String key) {
    return _currentIngredients[key.toLowerCase()];
  }

  // Get all ingredients matching a search term
  Map<String, Map<String, dynamic>> searchIngredients(String searchTerm) {
    final results = <String, Map<String, dynamic>>{};
    final lowerSearchTerm = searchTerm.toLowerCase();

    for (final entry in _currentIngredients.entries) {
      final key = entry.key.toLowerCase();
      final data = entry.value as Map<String, dynamic>;
      final name = (data['name'] ?? key).toLowerCase();

      if (key.contains(lowerSearchTerm) || name.contains(lowerSearchTerm)) {
        results[entry.key] = data;
      }
    }

    return results;
  }

  // Check if an ingredient exists
  bool hasIngredient(String key) {
    return _currentIngredients.containsKey(key.toLowerCase());
  }

  // Get ingredient display name
  String getIngredientName(String key) {
    final ingredient = getIngredient(key);
    return ingredient?['name'] ?? key;
  }

  // Get ingredient severity
  String getIngredientSeverity(String key) {
    final ingredient = getIngredient(key);
    return ingredient?['severity'] ?? 'medium';
  }

  // Reload current language data (useful for refreshing)
  Future<void> reload() async {
    await _loadLanguageData();
  }
}

// Extension for easy access to translations in widgets
extension BuildContextLanguageExtension on BuildContext {
  String tr(String key, [String? fallback]) {
    return LanguageService.instance.translate(key, fallback);
  }
}
