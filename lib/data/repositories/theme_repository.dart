import 'package:material_ui/material_ui.dart';
import 'package:ranked_positional_method/data/services/preferences_storage_service.dart';

/// Persists and exposes the active [ThemeMode] preference.
class ThemeRepository extends ChangeNotifier {
  /// Creates a repository backed by [_storage].
  ThemeRepository({required this._storage});

  static const String _themeModeKey = 'app_theme_mode';
  final KeyValueStorage _storage;

  ThemeMode _themeMode = ThemeMode.system;

  /// Currently active [ThemeMode].
  ThemeMode get themeMode => _themeMode;

  /// Loads the persisted [ThemeMode] if one has been saved previously.
  Future<void> load() async {
    final String? saved = await _storage.readString(_themeModeKey);
    final ThemeMode resolved = switch (saved) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    if (resolved != _themeMode) {
      _themeMode = resolved;
      notifyListeners();
    }
  }

  /// Cycles through System, Light, and Dark modes and saves the choice.
  Future<void> cycleThemeMode() async {
    final ThemeMode next = switch (_themeMode) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
    await setThemeMode(next);
  }

  /// Sets the active [mode] and persists it locally.
  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) {
      return;
    }
    _themeMode = mode;
    notifyListeners();
    await _storage.writeString(_themeModeKey, mode.name);
  }
}
