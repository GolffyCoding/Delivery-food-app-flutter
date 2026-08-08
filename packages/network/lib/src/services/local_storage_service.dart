import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:opendelivery_core/opendelivery_core.dart';

/// Service for local key-value storage using SharedPreferences.
/// Values are JSON-encoded so any primitive/Map/List can be stored.
class LocalStorageService {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<T?> get<T>(String key) async {
    try {
      final prefs = await _instance;
      final raw = prefs.getString(key);
      if (raw == null) return null;
      return jsonDecode(raw) as T?;
    } catch (e) {
      AppLogger.error('Failed to read from local storage', error: e, tag: 'LocalStorage');
      return null;
    }
  }

  Future<void> save<T>(String key, T value) async {
    try {
      final prefs = await _instance;
      await prefs.setString(key, jsonEncode(value));
    } catch (e) {
      AppLogger.error('Failed to write to local storage', error: e, tag: 'LocalStorage');
    }
  }

  Future<void> delete(String key) async {
    try {
      final prefs = await _instance;
      await prefs.remove(key);
    } catch (e) {
      AppLogger.error('Failed to delete from local storage', error: e, tag: 'LocalStorage');
    }
  }

  Future<void> deleteAll() async {
    try {
      final prefs = await _instance;
      await prefs.clear();
    } catch (e) {
      AppLogger.error('Failed to clear local storage', error: e, tag: 'LocalStorage');
    }
  }

  Future<bool> has(String key) async {
    try {
      final prefs = await _instance;
      return prefs.containsKey(key);
    } catch (e) {
      AppLogger.error('Failed to check local storage', error: e, tag: 'LocalStorage');
      return false;
    }
  }
}
