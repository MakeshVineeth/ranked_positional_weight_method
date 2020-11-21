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
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView.builder(
                physics: BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                itemCount: output.length,
                itemBuilder: (context, index) {
                  return Text(
                    '${output[index]}',
                    style: TextStyle(
                      backgroundColor: Colors.transparent,
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      letterSpacing: 1.5,
                    ),
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 22,
                      backgroundColor: Colors.transparent,
                    ),
                    keyboardType: TextInputType.number,
                    controller: myController,
                    decoration: InputDecoration(
                        border: new OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(10.0),
                          ),
                        ),
                        hintText: placeHolder,
                        hintStyle: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'Enter',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    onPressed: () => nowCode(),
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  int m = 0;
  int n = 0;
  List allValues = [];

  static const separate = ' ';

  void nowCode() {
    if (placeHolder == f1) {
      List<String> values = myController.text.trim().split(separate);

      if (values.length == 2) {
        m = int.tryParse(values[0]);
        n = int.tryParse(values[1]);

        pushOutput('Entered: m = $m and n = $n\n');
        changePlaceHolder(f2);
      }
    }

    // f2
    else if (placeHolder == f2) {
      List<String> values = myController.text.trim().split(separate);

      if (values.length == 3) {
        allValues.add(values);

        if (allValues.length == m) {
          pushOutput('Data given: $allValues');
          changePlaceHolder('Next');
        } else {
          clearTextField();
        }
      }
    }
  }
}
