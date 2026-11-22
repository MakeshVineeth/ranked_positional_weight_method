import 'package:shared_preferences/shared_preferences.dart';

/// Abstraction for persisting lightweight application preferences locally.
abstract interface class KeyValueStorage {
  /// Reads a stored string for [key], or `null` if absent.
  Future<String?> readString(String key);

  /// Persists a string [value] under [key].
  Future<void> writeString(String key, String value);
}

/// Platform-agnostic [KeyValueStorage] backed by [SharedPreferencesAsync].
class PreferencesStorageService implements KeyValueStorage {
  /// Creates a storage service backed by [SharedPreferencesAsync].
  PreferencesStorageService({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  @override
  Future<String?> readString(String key) async {
    return _preferences.getString(key);
  }

  @override
  Future<void> writeString(String key, String value) async {
    await _preferences.setString(key, value);
  }
}
