import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:opendelivery_core/opendelivery_core.dart';

/// Service for secure key-value storage using Flutter Secure Storage.
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
          iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
        );

  Future<String?> get(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      AppLogger.error('Failed to read from secure storage', error: e, tag: 'Storage');
      return null;
    }
  }

  Future<void> save(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      AppLogger.error('Failed to write to secure storage', error: e, tag: 'Storage');
    }
  }

  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      AppLogger.error('Failed to delete from secure storage', error: e, tag: 'Storage');
    }
  }

  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      AppLogger.error('Failed to clear secure storage', error: e, tag: 'Storage');
    }
  }

  Future<bool> has(String key) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e) {
      AppLogger.error('Failed to check secure storage', error: e, tag: 'Storage');
      return false;
    }
  }
}
