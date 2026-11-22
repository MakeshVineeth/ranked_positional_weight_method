import 'package:ranked_positional_method/data/repositories/theme_repository.dart';
import 'package:ranked_positional_method/data/services/clipboard_service.dart';
import 'package:ranked_positional_method/data/services/preferences_storage_service.dart';
import 'package:ranked_positional_method/domain/services/rpw_input_validator.dart';
import 'package:ranked_positional_method/domain/services/rpw_output_composer.dart';
import 'package:ranked_positional_method/domain/services/rpw_solver.dart';

/// Singleton composition root providing application dependencies.
class ServiceLocator {
  ServiceLocator._({
    KeyValueStorage? storage,
    ClipboardAdapter? clipboard,
    RpwInputValidator? validator,
    RpwSolver? solver,
    RpwOutputComposer? composer,
    ThemeRepository? themeRepository,
  }) : storage = storage ?? PreferencesStorageService(),
       clipboard = clipboard ?? const FlutterClipboardService(),
       validator = validator ?? const RpwInputValidator(),
       solver =
           solver ??
           HelgesonBirnieRpwSolver(
             validator: validator ?? const RpwInputValidator(),
           ),
       composer = composer ?? const RpwOutputComposer() {
    this.themeRepository = themeRepository ?? ThemeRepository(storage: this.storage);
  }

  static ServiceLocator? _instance;

  /// Returns the singleton [ServiceLocator], creating defaults on first access.
  static ServiceLocator get instance => _instance ??= ServiceLocator._();

  /// Replaces the singleton instance for tests or custom startup configuration.
  static void configure({
    KeyValueStorage? storage,
    ClipboardAdapter? clipboard,
    RpwInputValidator? validator,
    RpwSolver? solver,
    RpwOutputComposer? composer,
    ThemeRepository? themeRepository,
  }) {
    _instance = ServiceLocator._(
      storage: storage,
      clipboard: clipboard,
      validator: validator,
      solver: solver,
      composer: composer,
      themeRepository: themeRepository,
    );
  }

  /// Clears the singleton instance so tests start from a fresh state.
  static void reset() {
    _instance = null;
  }

  /// Local key-value storage abstraction.
  final KeyValueStorage storage;

  /// System clipboard abstraction.
  final ClipboardAdapter clipboard;

  /// Input validation and parser service.
  final RpwInputValidator validator;

  /// Active RPW calculation strategy.
  final RpwSolver solver;

  /// Composite result builder and plain-text formatter.
  final RpwOutputComposer composer;

  /// Theme preference repository and state notifier.
  late final ThemeRepository themeRepository;
}
