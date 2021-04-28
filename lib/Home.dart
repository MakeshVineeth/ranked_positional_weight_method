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

  // Initializations

  static const f1 = 'Enter Number of Nodes.';
  static const f2 = 'Enter Node, Final Node and Tek Value.';
  static const f3 = 'Enter Last Node and it\'s Tek';
  static const f4 = 'Enter Time';

  int n = 0;
  double finalNodeTek = 0;
  double time = 0.0;
  List<List<String>> allValues = [];
  List<int> ls1 = []; // first node list
  List<int> ls2 = []; // second final node list.
  List<double> ls3 = []; // store tek values.
  double maxRPW = 0.0;
  List<int> uniqueList = [];
  int lastElement;
  List<List<dynamic>> withTeks = [];

  // Use space as separate to split inputs and store in different lists.
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
            changePlaceHolder(f3);
          } else {
            pushOutput('Data ${allValues.length}: $values');
            clearTextField();
          }
        }
      }

      // f3
      else if (placeHolder == f3) {
        lastElement = int.tryParse(text.split(separate).elementAt(0));
        finalNodeTek = double.tryParse(text.split(separate).elementAt(1));
        if (finalNodeTek != null) {
          pushOutput('Entered Final Node and Tek: $lastElement $finalNodeTek');
          changePlaceHolder(f4);
        }
      }

      //f4
      else if (placeHolder == f4) {
        time = double.tryParse(text);
        pushOutput('Given Time for Jobs: $time');

        newSection();

        displayList('Given Data', allValues);

        changePlaceHolder('Processing...');
        disableField();
        doWork();
      }
    }
  }

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
      // Remove duplicates in list by using ... operator, DART Exclusive.
      uniqueList = [
        ...{...ls1},
        ...{...ls2}
      ];

      // Remove duplicates all together in combined list.
      uniqueList = [
        ...{...uniqueList}
      ];

      uniqueList.sort(); // Sort by ascending.

      // Following loop copies nodes and their tek values into separate list called withTeks.
      for (int count = 0; count < uniqueList.length; count++) {
        if (uniqueList[count] == lastElement)
          withTeks.add([lastElement, finalNodeTek]);
        else
          for (int i = 0; i < ls1.length; i++)
            if (ls1.elementAt(i) == uniqueList.elementAt(count)) {
              withTeks.add([ls1.elementAt(i), ls3.elementAt(i)]);
              break;
            }
      }

      // If not equal, then given data must be incorrect.
      if (withTeks.length != uniqueList.length) throw Exception;

      // Outputs
      String outStr = '';
      withTeks.forEach((val) {
        outStr = outStr + 'N${val[0]} = ' + '${val[1]}, ';
      });

      // Outputs using a helperFunction called removeLastDisplay in a neat manner.
      removeLastDisplay('List of Nodes with Tek', outStr);

      // Following foreach loop creates arrow chains.
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

      // Outputs
      displayList('Arrow Chains', arrowChains);
      newSection();

      // Get RPW for each chain.
      List<double> rpwList = [];
      arrowChains.forEach((list) {
        double val = 0.0;
        list.forEach((num) {
          for (int i = 0; i < withTeks.length; i++) {
            int cur = withTeks.elementAt(i).elementAt(0);
            if (num == cur) {
              val += withTeks
                  .elementAt(i)
                  .elementAt(1); // adding each node's tek value in a chain.
            }
          }
        });
        rpwList.add(val);
        pushOutput('RPW${list.elementAt(0)}: $val');
      });
      rpwList.add(finalNodeTek); // add final tek value.

      // outputs.
      pushOutput('RPW$lastElement: $finalNodeTek');
      newSection();

      // Table1 Generation
      List<List<dynamic>> table1 = []; // list format: [node tek rpw chain]
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

      // Sorting table based on RPW in descending manner.
      table1.sort((b, a) {
        double v1 = b.elementAt(2);
        double v2 = a.elementAt(2);
        return v2.compareTo(v1);
      });

      // Retrieving predecessors in this loop.
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

      // Initializations.
      List<List<dynamic>> rangeIn =
          []; // For RPW/Tek values within given time range.
      List<List<dynamic>> rangeOut =
          []; // For RPW/Tek values having more than given time range.

      table1.forEach((eachList) {
        double time1 = eachList.elementAt(1);
        if (time1 <= time)
          rangeIn.add(eachList);
        else
          rangeOut.add(eachList);
      });

      int curStation = 1; // Starting station with 1.
      List<List<dynamic>> stations = []; // Stations will be added here.
      List<int> completed =
          []; // A list to check what has been completed so far.
      List<List<dynamic>> dependsOnBig =
          []; // For nodes that depend on other nodes having more than given time range.

      // This loop for generation of stations.
      while (rangeIn.length > 0) {
        stations.add([curStation, [], 0.0]);

        for (int i = 0; i < rangeIn.length;) {
          double sum = stations.last.last;
          sum += rangeIn.elementAt(i).elementAt(
              1); // variable sum is used to check total station value and keep within time limits.
          if (sum <= time) {
            int curNode = rangeIn.elementAt(i).first;

            // Checks if precedence exists for node. Length > 3 meaning it exists.
            if (rangeIn.elementAt(i).length > 3) {
              List<int> nodePrecedence = rangeIn.elementAt(i).last;

              // check precedence here and see if it already completed. Returns nodes that are NOT completed.
              List<int> checks = nodePrecedence
                  .where((item) => !completed.contains(item))
                  .toList();

              // If checks is empty, meaning all node precedence are completed and can add directly now.
              if (checks.isEmpty) {
                stations.last.last = sum;
                completed.add(curNode);
                stations.last
                    .elementAt(1)
                    .add(rangeIn.elementAt(i).elementAt(0));
                rangeIn.removeAt(i);
              }

              // If node precedence not over, check if any of the node depends on nodes having more than given time limits.
              else {
                bool flag = false;
                for (int i = 0; i < nodePrecedence.length; i++) {
                  if (rangeOut.contains(nodePrecedence.elementAt(i))) {
                    dependsOnBig.add(rangeIn.elementAt(i));
                    rangeIn.removeAt(
                        i); // If found any node that exceeds time limits, remove it.
                    flag = true;
                    break;
                  }
                }

                if (!flag)
                  i++; // Just increment counter if a node cannot be completed right now. It will move on to next one without removing it.
              }
            }

            // If precedence not available, then add directly.
            else {
              stations.last.last = sum;
              completed.add(curNode);
              stations.last.elementAt(1).add(rangeIn.elementAt(i).elementAt(0));
              rangeIn.removeAt(i); // remove the ones that are added.
            }
          } else
            i++; // Just increment counter if a node cannot be completed right now. It will move on to next one without removing it.
        }

        pushOutput(
            'Station: $curStation Done: ${stations.last.elementAt(1)} Sum: ${stations.last.last} Idle Time: ${time - stations.last.last}');

        maxRPW = (maxRPW <= stations.last.last)
            ? stations.last.last
            : maxRPW; // Store max rpw value.
        curStation++;
      }

      // From here, nodes having more or exceed given time range, will be added here.
      if (rangeOut.length > 0) {
        rangeOut.sort((a, b) {
          double aT = a.elementAt(1);
          double bT = b.elementAt(1);
          return bT.compareTo(aT);
        });
      }

      // Loop adds rangeOut values i.e. having more than given time range, to the end of the list and as separate stations.
      rangeOut.forEach((item) {
        curStation = stations.length + 1;
        stations.add([
          curStation,
          [item.first],
          item.elementAt(1)
        ]);

        pushOutput(
            'Station: $curStation Done: ${stations.last.elementAt(1)} Sum: ${stations.last.last}');
      });

      print(
          'Production Rate can be increased by (1 / $maxRPW) = ${1.0 / maxRPW} units/min.');

      double sumTek = 0.0;
      withTeks.forEach((List val) => sumTek += val.elementAt(1));
      pushOutput(
          'Balance Delay: ${(stations.length * maxRPW - sumTek) / (stations.length * maxRPW)}');

      // TODO: Extra features (for future): Keep dependsOnBig values to stations too; check precedences of rangeOut values too. Loop continuously and check precedences.
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

  // Function to get arrow chains for each node in a recursive manner.
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
