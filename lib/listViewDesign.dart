import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:ranked_positional_method/common.dart';
import 'package:clipboard/clipboard.dart';

class ListViewDesign extends StatelessWidget {
  final List<String> output;
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
            return FadeIn(
              duration: const Duration(milliseconds: 500),
              child: Card(
                color: Theme.of(context).scaffoldBackgroundColor,
                shape:
                    RoundedRectangleBorder(borderRadius: Common.textCardBorder),
                elevation: 1.5,
                child: InkWell(
                  borderRadius: Common.textCardBorder,
                  onTap: () {
                    FlutterClipboard.copy('${output[index].trim()}')
                        .then((value) {
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    });
                  },
                  child: IgnorePointer(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
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
              ),
            );
          },
        ),
      ),
    );
  }
}
