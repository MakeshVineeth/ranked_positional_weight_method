import 'package:flutter/material.dart';
import 'package:ranked_positional_method/common.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:clipboard/clipboard.dart';

class ListItem extends StatelessWidget {
  final SnackBar snackBar = SnackBar(
    content: Text('Copied to Clipboard!'),
  );

  final String string;

  ListItem({@required this.string});

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      duration: const Duration(milliseconds: 500),
      child: Card(
        color: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: Common.textCardBorder),
        elevation: 1.5,
        child: InkWell(
          borderRadius: Common.textCardBorder,
          onTap: () {
            FlutterClipboard.copy('${string.trim()}').then((value) {
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            });
          },
          child: IgnorePointer(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                '${string.trim()}',
                style: TextStyle(
                  backgroundColor: Colors.transparent,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
