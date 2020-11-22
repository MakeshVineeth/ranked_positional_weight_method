import 'package:flutter/material.dart';
import 'package:rotation_positional_method/btnDesign.dart';
import 'package:rotation_positional_method/common.dart';
import 'package:rotation_positional_method/listViewDesign.dart';

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
      m = 0;
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

  static const f1 = 'Enter m and n values.';
  static const f2 = 'Enter Node, Final Node and Tek.';
  static const f3 = 'Enter Tek Value of Final Node';

  int m = 0;
  int n = 0;
  double finalNodeTek = 0;
  List<List<String>> allValues = [];

  static const separate = ' ';

  void nowCode() {
    if (placeHolder == f1) {
      List<String> values = myController.text.trim().split(separate);

      if (values.length == 2) {
        m = int.tryParse(values[0]);
        n = int.tryParse(values[1]);

        pushOutput('Entered: m = $m and n = $n');
        changePlaceHolder(f2);
      }
    }

    // f2
    else if (placeHolder == f2) {
      List<String> values = myController.text.trim().split(separate);

      if (values.length == 3) {
        allValues.add(values);

        if (allValues.length == m) {
          pushOutput('Entered: $values');
          changePlaceHolder('Enter Tek Value of Final Node');
        } else {
          pushOutput('Entered: $values');
          clearTextField();
        }
      }
    }

    // f3
    else if (placeHolder == f3) {
      finalNodeTek = double.tryParse(myController.text.trim());
      if (finalNodeTek != null) {
        pushOutput('Entered Final Tek: $finalNodeTek');
        pushOutput('Given Data: $allValues');
        changePlaceHolder('Processing...');
        disableField();
        doWork();
      }
    }
  }

  void doWork() {
    List<int> uniqueList = [];

    allValues.forEach((innerList) {
      int val = int.tryParse(innerList.elementAt(0));
      uniqueList.add(val);
      val = int.tryParse(innerList.elementAt(1));
      uniqueList.add(val);
    });

    uniqueList = [
      ...{...uniqueList}
    ];

    uniqueList.sort();

    List<String> out1 = [];
    uniqueList.forEach((int v) {
      for (int i = 0; i < allValues.length; i++) {
        int val = int.tryParse(allValues[i][0]);
        if (val == v) {
          out1.add('${allValues[i][0]} : ${allValues[i][2]}');
          break;
        }
      }
    });

    out1.add('${uniqueList[uniqueList.length - 1]} : $finalNodeTek');
    pushOutput('List of Nodes with Tek: $out1');

    List<List<String>> arrayChains = [];

    // m: 5, [126][231][346][463][673] chains: [123467][23467][3467][467][67][7]

    uniqueList.forEach((int mainNode) {
      // get chains for each node.
      List<String> temp = [];
      int tempVal = mainNode;

      List<int> indices = [];
      for (int i = 0; i < allValues.length; i++) {
        int val = int.tryParse(allValues[i][0]);
        if (val == mainNode) indices.add(i);
      }

      print(indices);

      for (int i = 0; i < indices.length; i++) {
        for (int j = indices[i]; j < allValues.length; j++) {
          for (int k = indices[i]; k < allValues.length; k++) {
            int val = int.tryParse(allValues[k][0]);

            if (val == tempVal) {
              temp.add('$val');
              tempVal = int.tryParse(allValues[k][1]);
            }
          }

          if (tempVal == uniqueList[uniqueList.length - 1]) {
            temp.add('${uniqueList[uniqueList.length - 1]}');
            arrayChains.add(temp);
            break;
          }
        }
      }

      // end for each final node.
    });

    // arrayChains.removeLast();
    pushOutput('Arrow Chains: $arrayChains');
    changePlaceHolder('Finished!');
  }
}
