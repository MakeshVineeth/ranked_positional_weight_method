import 'package:flutter/material.dart';

class Common {
  static const title = 'Rotation Positional Method';

  static final roundBorder =
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));

  static const scaffoldPadding = EdgeInsets.all(12.0);
  static final textCardBorder = BorderRadius.circular(5);

  static ThemeData dataTheme(BuildContext context, Brightness brightness) {
    bool isDark = brightness == Brightness.dark;
    Color bgWhite = Colors.white;
    Color bgBlack = Colors.grey[900];

    return ThemeData(
      primarySwatch: isDark ? Colors.blue : Colors.red,
      brightness: brightness,
      buttonColor: isDark ? bgBlack : bgWhite,
      scaffoldBackgroundColor: isDark ? Colors.grey[850] : bgWhite,
      backgroundColor: isDark ? Theme.of(context).backgroundColor : bgWhite,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        brightness: brightness,
        color: isDark ? Theme.of(context).appBarTheme.color : bgWhite,
      ),
      applyElevationOverlayColor: isDark,
      cardTheme: CardTheme(
        elevation: isDark ? 3 : 2,
        shape: roundBorder,
        color: isDark ? bgBlack : bgWhite,
      ),
    );
  }
}
