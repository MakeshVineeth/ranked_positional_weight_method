import 'package:flutter/material.dart';
import 'package:rotation_positional_method/common.dart';

class BtnDesign extends StatelessWidget {
  final String text;
  final Function function;

  const BtnDesign({@required this.text, @required this.function});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: RaisedButton(
        shape: Common.roundBorder,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        ),
        onPressed: () => function(),
        color: Colors.white,
      ),
    );
  }
}
