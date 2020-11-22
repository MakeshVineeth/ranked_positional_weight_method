import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ranked_positional_method/Home.dart';
import 'package:ranked_positional_method/common.dart';
import 'package:theme_provider/theme_provider.dart';

void main() {
  runApp(RootApp());
  GestureBinding.instance.resamplingEnabled = true;
}

class RootApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      saveThemesOnChange: true,
      themes: [
        AppTheme(
          id: 'dark_theme',
          data: Common.dataTheme(context, Brightness.dark),
          description: 'Dark Theme',
        ),
        AppTheme(
          id: 'light_theme',
          data: Common.dataTheme(context, Brightness.light),
          description: 'Light Theme',
        ),
      ],
      child: ThemeConsumer(
        child: Builder(
          builder: (BuildContext themeContext) => MaterialApp(
            theme: ThemeProvider.themeOf(themeContext).data,
            title: Common.title,
            home: Home(),
            debugShowCheckedModeBanner: false,
          ),
        ),
      ),
    );
  }
}
