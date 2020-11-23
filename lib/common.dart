import 'package:flutter/material.dart';

class Common {
  static const title = 'Line Balancing using RPW';
  static const legals =
      'An App that calculates the Ranked Positional Weight Method (RPW), it can be used to develop and balance an assembly line. Values are to be separated by spaces.';
  static const ver = '1.0.0';

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
        iconTheme: IconThemeData(
          color: isDark ? Colors.yellow : Colors.blue,
        ),
        textTheme: TextTheme(
          headline6: Theme.of(context).textTheme.headline6.copyWith(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
      applyElevationOverlayColor: isDark,
      cardTheme: CardTheme(
        elevation: isDark ? 3 : 2,
        shape: roundBorder,
        color: isDark ? bgBlack : bgWhite,
      ),
    );
  }

  static bool checkFormat(String text) {
    String ls = '0123456789. ';
    List<String> lsArray = ls.split('');
    bool isIncorrect = false;
    for (int i = 0; i < text.length; i++) {
      if (text[0] == ' ') {
        isIncorrect = true;
        break;
      } else if (text[i] == ' ' && i - 1 >= 0 && text[i - 1] == ' ') {
        isIncorrect = true;
        break;
      } else if (!lsArray.contains(text[i])) {
        isIncorrect = true;
        break;
      }
    }
    return isIncorrect;
  }
}
