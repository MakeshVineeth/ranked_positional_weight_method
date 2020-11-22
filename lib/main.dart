import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:rotation_positional_method/Home.dart';
import 'package:rotation_positional_method/common.dart';

void main() {
  runApp(RootApp());
  GestureBinding.instance.resamplingEnabled = true;
}

class RootApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Common.title,
      themeMode: ThemeMode.system,
      darkTheme: Common.dataTheme(context, Brightness.dark),
      theme: Common.dataTheme(context, Brightness.light),
      home: Home(),
      debugShowCheckedModeBanner: false,
    );
  }
}
