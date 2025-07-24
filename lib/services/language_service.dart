// lib/services/language_service.dart - Fixed version
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static LanguageService? _instance;
  static LanguageService get instance => _instance ??= LanguageService._();
  LanguageService._();

  String _currentLanguage = 'English';
  Map<String, dynamic> _currentTranslations = {};
  Map<String, dynamic> _currentIngredients = {};
  bool _isLoading = false;

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
  bool get isLoading => _isLoading;

  // Initialize language service
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    await _loadSavedLanguage();
    await _loadLanguageData();

    _isLoading = false;
    notifyListeners();
  }

  // Load saved language from SharedPreferences
  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentLanguage = prefs.getString('language') ?? 'English';
      debugPrint('Loaded saved language: $_currentLanguage');
    } catch (e) {
      debugPrint('Error loading saved language: $e');
      _currentLanguage = 'English';
    }
  }

  // Change language with proper state management
  Future<void> changeLanguage(String language) async {
    if (!supportedLanguages.containsKey(language) ||
        _currentLanguage == language) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _currentLanguage = language;

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', language);
      debugPrint('Language changed to: $language');

      // Load new language data
      await _loadLanguageData();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error changing language: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Load both ingredients and translations for current language
  Future<void> _loadLanguageData() async {
    try {
      await Future.wait([
        _loadIngredients(),
        _loadTranslations(),
      ]);
      debugPrint('Language data loaded successfully for $_currentLanguage');
    } catch (e) {
      debugPrint('Error loading language data: $e');
      rethrow;
    }
  }

  // Load ingredients for current language with better error handling
  Future<void> _loadIngredients() async {
    try {
      final ingredientsFile =
          supportedLanguages[_currentLanguage]?['ingredientsFile'];
      if (ingredientsFile == null) {
        throw Exception('Ingredients file not found for $_currentLanguage');
      }

      debugPrint('Loading ingredients from: $ingredientsFile');
      final jsonString = await rootBundle.loadString(ingredientsFile);
      final jsonData = json.decode(jsonString);

      if (jsonData['ingredients'] == null) {
        throw Exception('Invalid ingredients file format');
      }

      _currentIngredients = Map<String, dynamic>.from(jsonData['ingredients']);
      debugPrint('Loaded ${_currentIngredients.length} ingredients');
    } catch (e) {
      debugPrint('Error loading ingredients for $_currentLanguage: $e');

      // Fallback to English if not already trying English
      if (_currentLanguage != 'English') {
        try {
          debugPrint('Falling back to English ingredients...');
          final jsonString =
              await rootBundle.loadString('assets/ingredients_en.json');
          final jsonData = json.decode(jsonString);
          _currentIngredients =
              Map<String, dynamic>.from(jsonData['ingredients'] ?? {});
          debugPrint(
              'Fallback: Loaded ${_currentIngredients.length} English ingredients');
        } catch (fallbackError) {
          debugPrint('Error loading fallback ingredients: $fallbackError');
          _currentIngredients = {};
        }
      } else {
        _currentIngredients = {};
      }
    }
  }

  // Load UI translations for current language with better error handling
  Future<void> _loadTranslations() async {
    try {
      final translationsFile =
          supportedLanguages[_currentLanguage]?['translationsFile'];
      if (translationsFile == null) {
        throw Exception('Translations file not found for $_currentLanguage');
      }

      debugPrint('Loading translations from: $translationsFile');
      final jsonString = await rootBundle.loadString(translationsFile);
      _currentTranslations = json.decode(jsonString);
      debugPrint('Translations loaded successfully');
    } catch (e) {
      debugPrint('Error loading translations for $_currentLanguage: $e');

      // Fallback to English if not already trying English
      if (_currentLanguage != 'English') {
        try {
          debugPrint('Falling back to English translations...');
          final jsonString =
              await rootBundle.loadString('assets/translations_en.json');
          _currentTranslations = json.decode(jsonString);
          debugPrint('Fallback: English translations loaded');
        } catch (fallbackError) {
          debugPrint('Error loading fallback translations: $fallbackError');
          _currentTranslations = {};
        }
      } else {
        _currentTranslations = {};
      }
    }
  }

  // Get translated text with better debugging
  String translate(String key, [String? fallback]) {
    final keys = key.split('.');
    dynamic current = _currentTranslations;

    for (final k in keys) {
      if (current is Map<String, dynamic> && current.containsKey(k)) {
        current = current[k];
      } else {
        debugPrint(
            'Translation not found for key: $key in language: $_currentLanguage');
        return fallback ?? key;
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

  // Reload current language data
  Future<void> reload() async {
    _isLoading = true;
    notifyListeners();

    await _loadLanguageData();

    _isLoading = false;
    notifyListeners();
  }

  // Dispose method for proper cleanup
  @override
  void dispose() {
    super.dispose();
  }
}

// Provider widget for easy access
class LanguageProvider extends StatelessWidget {
  final Widget child;

  const LanguageProvider({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LanguageService>.value(
      value: LanguageService.instance,
      child: child,
    );
  }
}

// Extension for easy access to translations in widgets
extension BuildContextLanguageExtension on BuildContext {
  String tr(String key, [String? fallback]) {
    return LanguageService.instance.translate(key, fallback);
  }

  LanguageService get languageService => LanguageService.instance;
}
