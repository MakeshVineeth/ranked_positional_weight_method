/// Application metadata, bounds, and links used across the app.
abstract final class AppConstants {
  /// Display title shown in app bars and about sections.
  static const String appTitle = 'Calculate RPW';

  /// Full application subtitle describing the domain.
  static const String appSubtitle = 'Assembly Line Balancing';

  /// Semantic application version displayed to users.
  static const String appVersion = '3.0.0';

  /// Repository and project web homepage URL.
  static const String projectUrl =
      'https://makeshvineeth.github.io/ranked_positional_weight_method/';

  /// Standalone privacy policy URL hosted on GitHub Pages.
  static const String privacyPolicyUrl =
      'https://makeshvineeth.github.io/ranked_positional_weight_method/privacy/';

  /// Maximum edges accepted to guard against excessive CPU and memory use.
  static const int maxEdges = 500;

  /// Maximum unique nodes allowed in a single precedence network.
  static const int maxUniqueNodes = 200;

  /// Maximum character length accepted in a single input field.
  static const int maxInputLength = 128;

  /// Floating-point comparison tolerance used when summing task times.
  static const double epsilon = 1e-9;

  /// Seed color used to derive Material 3 light and dark color schemes.
  static const int seedColorValue = 0xFF3F51B5;
}
