import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
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
  List<dynamic> output = [];
  final myController = TextEditingController();
  String placeHolder = f1;
  FocusNode focusNode;

  bool isEditable = true;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
  }

  @override
  void dispose() {
    focusNode.dispose();
    myController.dispose();
    super.dispose();
  }

  void pushOutput(dynamic val) {
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

  void newSection() => pushOutput(SizedBox(
        height: 30,
      ));

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
    double width = MediaQuery.of(context).size.width;
    return FadeIn(
      duration: const Duration(milliseconds: 500),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            Common.title,
          ),
          actions: [
            CycleThemeIconButton(),
            AboutApp(),
          ],
        ),
        body: Padding(
          padding: Common.scaffoldPadding,
          child: Center(
            child: Container(
              width: width > 700 ? width / 1.5 : width,
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
                  Container(
                    width: width > 500 ? width / 2 : width,
                    child: Row(
                      children: [
                        BtnDesign(text: 'Enter', function: nowCode),
                        SizedBox(
                          width: 10,
                        ),
                        BtnDesign(text: 'Clear', function: clearAll)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
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
          focusNode: focusNode,
          onSubmitted: (value) {
            nowCode();
            focusNode.requestFocus();
          },
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
  List<double> ls3 = [];

  static const separate = ' ';

  void nowCode() {
    String text = myController.text.trim();
    if (!Common.checkFormat(text)) {
      if (placeHolder == f1) {
        n = int.tryParse(text);

        if (n != 0 && n != null) {
          pushOutput('Number of Nodes: $n');
          newSection();
          changePlaceHolder(f2);
        }
      }

      // f2
      else if (placeHolder == f2) {
        List<String> values = text.split(separate);

        if (values.length == 3) {
          allValues.add(values);
          ls1.add(int.tryParse(values.elementAt(0)));
          ls2.add(int.tryParse(values.elementAt(1)));
          ls3.add(double.tryParse(values.elementAt(2)));

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
          newSection();

          displayList('Given Data', allValues);

          changePlaceHolder('Processing...');
          disableField();
          doWork();
        }
      }
    }
  }

  List<int> uniqueList = [];
  int lastElement;
  List<List<dynamic>> withTeks = [];

  void displayList(String title, List list) {
    String outStr = '';
    list.forEach((val) {
      outStr = outStr + '$val, ';
    });

    removeLastDisplay(title, outStr);
  }

  void removeLastDisplay(String title, String outStr) {
    outStr = outStr.trim();
    outStr = outStr.substring(0, outStr.length - 1);
    pushOutput('$title: $outStr');
  }

  void doWork() {
    try {
      uniqueList = [
        ...{...ls1},
        ...{...ls2}
      ];

      uniqueList = [
        ...{...uniqueList}
      ];

      uniqueList.sort();
      lastElement = uniqueList[uniqueList.length - 1];

      for (int count = 0; count < uniqueList.length - 1; count++) {
        for (int i = 0; i < ls1.length; i++) {
          if (ls1.elementAt(i) == uniqueList.elementAt(count)) {
            withTeks.add([ls1.elementAt(i), ls3.elementAt(i)]);
            break;
          }
        }
      }

      withTeks.add([lastElement, finalNodeTek]);

      if (withTeks.length != uniqueList.length) throw Exception;

      String outStr = '';

      withTeks.forEach((val) {
        outStr = outStr + 'N${val[0]} = ' + '${val[1]}, ';
      });

      removeLastDisplay('List of Nodes with Tek', outStr);

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

      displayList('Arrow Chains', arrowChains);
      newSection();

      List<double> rpwList = [];
      arrowChains.forEach((list) {
        double val = 0.0;
        list.forEach((num) {
          for (int i = 0; i < withTeks.length; i++) {
            int cur = withTeks.elementAt(i).elementAt(0);
            if (num == cur) {
              val += withTeks.elementAt(i).elementAt(1);
            }
          }
        });
        rpwList.add(val);
        pushOutput('RPW${list.elementAt(0)}: $val');
      });
      rpwList.add(finalNodeTek);
      pushOutput('RPW$lastElement: $finalNodeTek');
      newSection();

      List<List<dynamic>> table1 = []; // list: [node tek rpw chain]
      for (int i = 0; i < withTeks.length; i++) {
        List<int> chain = [];
        int node = withTeks[i][0];

        for (int i = 0; i < ls2.length; i++) {
          if (ls2[i] == node) chain.add(ls1[i]);
        }

        if (chain.length > 1) {
          chain = [
            ...{...chain}
          ];
          chain.sort();
        }

        List temp = [
          node,
          withTeks[i][1],
          rpwList[i],
          if (chain.length > 0) chain,
        ];
        table1.add(temp);
      }

      table1.sort((b, a) {
        double v1 = b.elementAt(2);
        double v2 = a.elementAt(2);
        return v2.compareTo(v1);
      });

      table1.forEach((list) {
        List<int> pre = [];
        if (list.length > 3) pre.addAll(list.elementAt(3));
        String common =
            'Node: ${list.elementAt(0)} Tek: ${list.elementAt(1)} RPW: ${list.elementAt(2)}';

        if (pre.isNotEmpty)
          pushOutput('$common Predecessors: $pre');
        else
          pushOutput(common);
      });
      newSection();

      double time = 1.5;
      List<List<dynamic>> rangeIn = [];
      List<List<dynamic>> rangeOut = [];

      table1.forEach((eachList) {
        double time1 = eachList.elementAt(1);
        if (time1 <= time)
          rangeIn.add(eachList);
        else
          rangeOut.add(eachList);
      });

      int curStation = 1;
      List<List<dynamic>> stations = [];
      List<int> completed = [];
      List<List<dynamic>> dependsOnBig = [];

      while (rangeIn.length > 0) {
        stations.add([curStation, [], 0.0]);

        for (int i = 0; i < rangeIn.length;) {
          double sum = stations.last.last;
          sum += rangeIn.elementAt(i).elementAt(1);
          if (sum <= time) {
            stations.last.last = sum;
            completed.add(rangeIn.elementAt(i).first);
            stations.last.elementAt(1).add(rangeIn.elementAt(i).elementAt(0));
            rangeIn.removeAt(i);
          } else {
            i++;
          }
        }

        pushOutput(
            'Station: $curStation Done: ${stations.last.elementAt(1)} Sum: ${stations.last.last}');
        curStation++;
      }

      changePlaceHolder('Finished!');
    } catch (e) {
      print(e);
      clearAll();
      changePlaceHolder('Error!');
      pushOutput(
          'Error. Please make sure all nodes are connected to a single node in the end');
      disableField();
    }
  }

  List<int> getArrowChain(int currentNode) {
    List<int> chain = [];
    chain.add(currentNode);

    for (int count = 0; count < ls1.length; count++) {
      if (currentNode == ls1.elementAt(count)) {
        chain.add(ls2.elementAt(count));
        if (ls2.elementAt(count) == lastElement) break;
        chain.addAll(getArrowChain(ls2.elementAt(count)));
      }
    }

    return chain;
  }
}
