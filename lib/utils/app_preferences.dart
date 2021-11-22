import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PreferenceKey {
  BRUTE_MIGRATION_DB,
  DIALOG_MESSAGE,
  DIALOG_SHOWS,
  LOGIN_PROVIDER
}

class AppPreferences {
  static final AppPreferences instance = AppPreferences.__internal();

  factory AppPreferences() => instance;

  late Future<SharedPreferences> _prefsFuture;

  AppPreferences.__internal() {
    _prefsFuture = SharedPreferences.getInstance();
  }

  Future<Object> valueWithKey(PreferenceKey key, {dynamic defValue}) async {
    var _prefs = await _prefsFuture;
    var localKey = key.toString();
    if (_prefs.containsKey(localKey)) return _prefs.get(localKey)!;
    if (defValue == null)
      throw ErrorDescription("Value with key $key not present");
    await this.putValue(key, defValue);
    return _prefs.get(localKey)!;
  }

  Future<bool> containsKey(PreferenceKey key) async {
    var _prefs = await _prefsFuture;
    return _prefs.containsKey(key.toString());
  }

  Future<void> putValue(PreferenceKey key, dynamic value,
      {bool override = true}) async {
    var _prefs = await _prefsFuture;
    var localKey = key.toString();
    if (!override && _prefs.containsKey(localKey)) return;
    if (value is int)
      _prefs.setInt(localKey, value);
    else if (value is String)
      _prefs.setString(localKey, value);
    else if (value is bool)
      _prefs.setBool(localKey, value);
    else if (value is double) {
      _prefs.setDouble(localKey, value);
    }
  }
}
