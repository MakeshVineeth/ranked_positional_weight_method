import 'package:flutter/material.dart';
import 'package:rotation_positional_method/common.dart';

class ListViewDesign extends StatelessWidget {
  final List<String> output;

  const ListViewDesign({@required this.output});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: Common.roundBorder,
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.separated(
          separatorBuilder: (context, index) => Divider(
            height: 30,
            thickness: 1,
          ),
          physics:
              BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          itemCount: output.length,
          itemBuilder: (context, index) {
            return Text(
              '${output[index].trim()}',
              style: TextStyle(
                backgroundColor: Colors.transparent,
                fontWeight: FontWeight.w600,
                fontSize: 18,
                letterSpacing: 1,
              ),
            );
          },
        ),
      ),
    );
  }
}
