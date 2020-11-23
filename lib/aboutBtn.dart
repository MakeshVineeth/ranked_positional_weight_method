import 'package:flutter/material.dart';
import 'package:ranked_positional_method/common.dart';

class AboutApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => showAboutDialog(
        context: context,
        applicationIcon: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image(
            image: AssetImage('assets/logo.png'),
            width: 40,
          ),
        ),
        applicationName: Common.title,
        applicationLegalese: Common.legals,
        applicationVersion: Common.ver,
      ),
      icon: Icon(
        Icons.help_rounded,
      ),
    );
  }
}
