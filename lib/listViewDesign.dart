import 'package:flutter/material.dart';
import 'package:rotation_positional_method/common.dart';

class ListViewDesign extends StatelessWidget {
  final List<String> output;

  const ListViewDesign({@required this.output});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: Common.roundBorder,
      elevation: Common.cardElevation,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
          physics:
              BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          itemCount: output.length,
          itemBuilder: (context, index) {
            return Card(
              shape:
                  RoundedRectangleBorder(borderRadius: Common.textCardBorder),
              elevation: 1.5,
              child: InkWell(
                borderRadius: Common.textCardBorder,
                onTap: () {},
                child: IgnorePointer(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      '${output[index].trim()}',
                      style: TextStyle(
                        backgroundColor: Colors.transparent,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
