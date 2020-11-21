import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(RootApp());
  GestureBinding.instance.resamplingEnabled = true;
}

class RootApp extends StatelessWidget {
  static final title = 'Rotation Positional Method';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.light,
      title: title,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<String> output = [];
  final myController = TextEditingController();
  String placeHolder = f1;

  static const f1 = 'Enter m and n.';
  static const f2 = 'Enter Node, Final Node and Tek.';

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          RootApp.title,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Card(
                shape: roundBorder,
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ListView.separated(
                    separatorBuilder: (context, index) => Divider(
                      height: 30,
                      thickness: 1.5,
                    ),
                    physics: BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics()),
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
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Card(
              shape: roundBorder,
              elevation: 3,
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
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      )),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                btnPaste('Enter', nowCode),
                SizedBox(
                  width: 10,
                ),
                btnPaste('Clear', clearAll)
              ],
            ),
          ],
        ),
      ),
    );
  }

  final roundBorder =
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(15));

  Widget btnPaste(String text, Function function) {
    return Expanded(
      child: RaisedButton(
        shape: roundBorder,
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

          changePlaceHolder('Enter final Node Tek');
          finalNodeTek = double.tryParse(myController.text);

          pushOutput('Given Data: $allValues');
          changePlaceHolder('Processing...');
          disableField();
          doWork();
        } else {
          pushOutput('Entered: $values');
          clearTextField();
        }
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
    pushOutput('List of Nodes with Tek: $out1');

    List<List<String>> arrayChains = [];

    // m: 5, [126][231][346][463][673] chains: [123467][23467][3467][467][67][7]

    uniqueList.forEach((int mainNode) {
      // get chains for each node.
      List<String> temp = [];
      int tempVal = mainNode;

      for (int i = 0; i < allValues.length; i++) {
        for (int i = 0; i < allValues.length; i++) {
          int val = int.tryParse(allValues[i][0]);

          if (val == tempVal) {
            temp.add('$val');
            tempVal = int.tryParse(allValues[i][1]);
          }
        }

        if (tempVal == uniqueList[uniqueList.length - 1]) {
          temp.add('${uniqueList[uniqueList.length - 1]}');
          arrayChains.add(temp);
          break;
        }
      }

      // end for each final node.
    });

    pushOutput('Arrow Chains: $arrayChains');
    changePlaceHolder('Finished!');
  }
}
