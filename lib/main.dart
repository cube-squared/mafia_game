import 'package:flutter/material.dart';
import 'dart:async';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mafia Game',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(title: 'The Temperature Game'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int temp = 70;

  bool heating = false;
  bool cooling = false;

  Color heatColor = Colors.white;
  Color coolColor = Colors.white;
  Color sliderColor = Colors.blue;

  
  void _showDialog(String text) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Warning"),
          content: new Text(text),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Please Save Me"),
              onPressed: () {
                setState(() {
                 temp = 50; 
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void set_status(bool heat) {
    setState(() {
      if (heat && !heating) {
        heatColor = Colors.red;
        coolColor = Colors.white;
        heating = true;
        cooling = false;
      } else if (!heat && !cooling) {
        heatColor = Colors.white;
        coolColor = Colors.blue;
        heating = false;
        cooling = true;
      } else {
        heatColor = Colors.white;
        coolColor = Colors.white;
        heating = false;
        cooling = false;
      }
    });
  }
  

  void calculate_temp(Timer timer) {
    if (heating || cooling) {
      setState(() {
        if (heating) {
          temp++;
        } else if (cooling) {
          temp--;
        }
      });
      updateSliderColor();
    }
  }

  void updateSliderColor () {
    setState(() {
      if (temp < 70) {
        sliderColor = Colors.blue;
      } else if (temp < 90) {
        sliderColor = Colors.lightBlue;
      } else if (temp < 110) {
        sliderColor = Colors.yellowAccent;
      } else if (temp < 130) {
        sliderColor = Colors.yellow;
      } else if (temp < 150) {
        sliderColor = Colors.orangeAccent;
      } else if (temp < 170) {
        sliderColor = Colors.orange;
      } else if (temp < 185) {
        sliderColor = Colors.redAccent;
      } else {
        sliderColor = Colors.red;
      }
    });
  }

  Timer timer;

  @override
  void initState() {
    super.initState();
    timer = new Timer.periodic(const Duration(milliseconds: 200), calculate_temp);
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
    

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[ 
                  Column(children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(5),
                      child:
                        RaisedButton(
                          onPressed: () => set_status(false),
                          color: coolColor,
                          child: Column(
                            children: <Widget>[
                              Icon(Icons.ac_unit),
                              Text("COOL"),
                          ],)
                        ),
                    ),
                  ],),
                  Column(children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(5),
                      child:
                        RaisedButton(
                          onPressed: () => set_status(true),
                          color: heatColor,
                          child: Column(
                            children: <Widget>[
                              Icon(Icons.hot_tub),
                              Text("HEAT"),
                          ],)
                        ),
                    ),
                  ],),
              ],),
            ),

            Slider(
              activeColor: sliderColor,
              min: 0,
              max: 200,
              onChanged: (newRating) {
                updateSliderColor();
                setState(() => temp = temp);
              },
              value: temp.toDouble(),
            ),

            Text(
              'Current Temperature:',
            ),
            Text(
              '$temp',
              style: Theme.of(context).textTheme.display1,
            ),

          ],
        ),
      ),
      /*floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),*/ // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
