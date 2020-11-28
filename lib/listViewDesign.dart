import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:ranked_positional_method/listItem.dart';

class ListViewDesign extends StatelessWidget {
  final List<dynamic> output;
  final SnackBar snackBar = SnackBar(
    content: Text('Copied to Clipboard!'),
  );

  ListViewDesign({@required this.output});

  final ScrollController _scrollController = new ScrollController();

  @override
  Widget build(BuildContext context) {
    if (output.length > 2)
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
          controller: _scrollController,
          physics:
              BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          itemCount: output.length,
          itemBuilder: (context, index) {
            return output[index] is String
                ? ListItem(
                    string: output[index],
                  )
                : output[index];
          },
        ),
      ),
    );
  }
}
