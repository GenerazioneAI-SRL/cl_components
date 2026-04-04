import 'package:shared_preferences/shared_preferences.dart';

class SharedManager {
  //
  static SharedPreferences? prefs;

  static initPrefs() async {
    prefs ??= await SharedPreferences.getInstance();
  }

  /*
  static bool firstTimeOnApp() {
    return prefs!.getBool(AppStrings.firstTimeOnApp) ?? true;
  }
  //
  static bool authenticated() {
    return prefs!.getBool(AppStrings.authenticated) ?? false;
  }*/

  static bool? getBool(String key) {
    return prefs!.getBool(key) ?? false;
  }

  static Future<bool?> setBool(String key, bool value) async {
    prefs!.setBool(key, value);
    return getBool(key);
  }

  static String getString(String key, {String defaultValue=""}) {
    return prefs!.getString(key) ?? defaultValue;
  }

  static Future<String?> setString(String key, String value) async {
    prefs!.setString(key, value);
    return getString(key);
  }

  static Future<List<String>?> setStringList(String key, List<String> value) async {
    prefs!.setStringList(key, value);
    return getStringList(key);
  }

  static List<String>? getStringList(String key, {List<String>? defaultValue = const []}) {
    return prefs!.getStringList(key) ?? defaultValue;
  }

  static int getInt(String key) {
    return prefs!.getInt(key) ?? 0;
  }

  static Future<int> setInt(String key, int value) async {
    prefs!.setInt(key, value);
    return getInt(key);
  }

  static Future<bool?> remove(String key) async {
    return await prefs!.remove(key);
  }
}
