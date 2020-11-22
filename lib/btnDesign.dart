import 'package:flutter/material.dart';
import 'package:ranked_positional_method/common.dart';

class BtnDesign extends StatelessWidget {
  final String text;
  final Function function;

  const BtnDesign({@required this.text, @required this.function});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(3),
        child: RaisedButton(
          shape: Common.roundBorder,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          onPressed: () => function(),
        ),
      ),
    );
  }
}
