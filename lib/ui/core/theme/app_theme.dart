import 'package:material_ui/material_ui.dart';
import 'package:ranked_positional_method/core/constants/app_constants.dart';

/// Provides Material 3 light, dark, and high-contrast themes for the application.
abstract final class AppTheme {
  static const Color _seedColor = Color(AppConstants.seedColorValue);

  /// Light Material 3 theme derived from the brand seed color.
  static ThemeData light() => _buildTheme(Brightness.light, contrastLevel: 0.0);

  /// Dark Material 3 theme derived from the brand seed color.
  static ThemeData dark() => _buildTheme(Brightness.dark, contrastLevel: 0.0);

  /// High-contrast light Material 3 theme for accessibility settings.
  static ThemeData highContrastLight() => _buildTheme(Brightness.light, contrastLevel: 1.0);

  /// High-contrast dark Material 3 theme for accessibility settings.
  static ThemeData highContrastDark() => _buildTheme(Brightness.dark, contrastLevel: 1.0);

  static ThemeData _buildTheme(Brightness brightness, {required double contrastLevel}) {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: brightness,
      contrastLevel: contrastLevel,
    );

    final RoundedRectangleBorder cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: colorScheme.outlineVariant),
    );

    return ThemeData(
      useMaterial3: true,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 2,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainerLow,
        shape: cardShape,
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        constraints: const BoxConstraints(minHeight: 48),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          minimumSize: const Size(48, 48),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        backgroundColor: colorScheme.surfaceContainer,
      ),
    );
  }
}
