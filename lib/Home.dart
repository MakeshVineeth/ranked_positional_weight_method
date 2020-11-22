import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ranked_positional_method/btnDesign.dart';
import 'package:ranked_positional_method/common.dart';
import 'package:ranked_positional_method/listViewDesign.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:ranked_positional_method/aboutBtn.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<String> output = [];
  final myController = TextEditingController();
  String placeHolder = f1;

  bool isEditable = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  void pushOutput(String val) {
    setState(() {
      output.add(val);
    });
  }

  void changePlaceHolder(String val) {
    setState(() {
      myController.clear();
      placeHolder = val;
    });
  }

  void clearTextField() {
    setState(() {
      myController.clear();
    });
  }

  void clearAll() {
    setState(() {
      myController.clear();
      isEditable = true;
      n = 0;
      allValues.clear();
      output.clear();
      placeHolder = f1;
    });
  }

  void disableField() {
    setState(() {
      isEditable = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Common.title,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.black
                : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          CycleThemeIconButton(),
          AboutApp(),
        ],
      ),
      body: Padding(
        padding: Common.scaffoldPadding,
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: ListViewDesign(
                output: output,
              ),
            ),
            SizedBox(
              height: 5,
            ),
            textFieldDesign(),
            SizedBox(
              height: 5,
            ),
            Row(
              children: [
                BtnDesign(text: 'Enter', function: nowCode),
                SizedBox(
                  width: 10,
                ),
                BtnDesign(text: 'Clear', function: clearAll)
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget textFieldDesign() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: TextField(
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            backgroundColor: Colors.transparent,
          ),
          controller: myController,
          enabled: isEditable,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp("[0-9 .]"))
          ],
          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: placeHolder,
              hintStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              )),
        ),
      ),
    );
  }

  static const f1 = 'Enter Number of Nodes.';
  static const f2 = 'Enter Node, Final Node and Tek Value.';
  static const f3 = 'Enter Tek Value of Final Node';

  int n = 0;
  double finalNodeTek = 0;
  List<List<String>> allValues = [];
  List<int> ls1 = [];
  List<int> ls2 = [];

  static const separate = ' ';

  void nowCode() {
    String text = myController.text.trim();
    if (!Common.checkFormat(text)) {
      if (placeHolder == f1) {
        n = int.tryParse(text);

        if (n != 0 && n != null) {
          pushOutput('Number of Nodes: $n');
          changePlaceHolder(f2);
        }
      }

      // f2
      else if (placeHolder == f2) {
        List<String> values = text.split(separate);

        if (values.length == 3) {
          allValues.add(values);
          ls1.add(int.tryParse(values[0]));
          ls2.add(int.tryParse(values[1]));

          if (allValues.length == n) {
            pushOutput('Data ${allValues.length}: $values');
            changePlaceHolder('Enter Tek Value of Final Node');
          } else {
            pushOutput('Data ${allValues.length}: $values');
            clearTextField();
          }
        }
      }

      // f3
      else if (placeHolder == f3) {
        finalNodeTek = double.tryParse(text);
        if (finalNodeTek != null) {
          pushOutput('Entered Final Tek: $finalNodeTek');
          pushOutput('Given Data: $allValues');
          changePlaceHolder('Processing...');
          disableField();
          doWork();
        }
      }
    }
  }

  List<int> uniqueList = [];
  int lastElement;

  void doWork() {
    uniqueList = [
      ...{...ls1},
      ...{...ls2}
    ];

    uniqueList = [
      ...{...uniqueList}
    ];

    uniqueList.sort();
    lastElement = uniqueList[uniqueList.length - 1];

    List<String> out1 = [];
    uniqueList.forEach((int v) {
      for (int i = 0; i < allValues.length; i++) {
        int val = int.tryParse(allValues[i][0]);
        if (val == v) {
          out1.add('N${allValues[i][0]}: ${allValues[i][2]}');
          break;
        }
      }
    });

    out1.add('N$lastElement: $finalNodeTek');
    pushOutput('List of Nodes with Tek: $out1');

    List<List<int>> arrowChains = [];
    uniqueList.forEach((int currentNode) {
      if (currentNode != lastElement) {
        List<int> arrow = getArrowChain(currentNode);
        arrow = [
          ...{...arrow}
        ];
        arrow.sort();
        arrowChains.add(arrow);
      }
    });

    pushOutput('Arrow Chains: $arrowChains');
    changePlaceHolder('Finished!');
  }

  List<int> getArrowChain(int currentNode) {
    List<int> chain = [];
    chain.add(currentNode);

    for (int count = 0; count < ls1.length; count++) {
      if (currentNode == ls1[count]) {
        chain.add(ls2[count]);
        if (ls2[count] == lastElement) break;
        chain.addAll(getArrowChain(ls2[count]));
      }
    }

    return chain;
  }
}
