// lib/dbHelper/shared_prefs.dart - Add missing methods
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static SharedPreferences? _preferences;

  Future<void> init() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get instance {
    if (_preferences == null) {
      throw Exception('SharedPreferences not initialized. Call init() first.');
    }
    return _preferences!;
  }

  // Add the missing methods for custom ingredients list
  Future<List<String>> getCustomIngredientsList() async {
    await init();
    return instance.getStringList('custom_ingredients_list') ?? [];
  }

  Future<bool> saveCustomIngredientsList(List<String> ingredients) async {
    await init();
    return await instance.setStringList('custom_ingredients_list', ingredients);
  }

  // Optional: Add method to clear the custom list
  Future<bool> clearCustomIngredientsList() async {
    await init();
    return await instance.remove('custom_ingredients_list');
  }

  // Optional: Add method to check if custom list exists
  bool hasCustomIngredientsList() {
    if (_preferences == null) return false;
    return instance.containsKey('custom_ingredients_list');
  }

  // Add any other existing methods your app uses
  Future<bool> setString(String key, String value) async {
    await init();
    return await instance.setString(key, value);
  }

  String? getString(String key) {
    return instance.getString(key);
  }

  Future<bool> setBool(String key, bool value) async {
    await init();
    return await instance.setBool(key, value);
  }

  bool? getBool(String key) {
    return instance.getBool(key);
  }

  Future<bool> setInt(String key, int value) async {
    await init();
    return await instance.setInt(key, value);
  }

  int? getInt(String key) {
    return instance.getInt(key);
  }

  Future<bool> remove(String key) async {
    await init();
    return await instance.remove(key);
  }

  Future<bool> clear() async {
    await init();
    return await instance.clear();
  }
}
