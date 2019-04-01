import 'package:flutter/material.dart';
import 'new_page.dart';


class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();

}

class _MyHomePageState extends State<MyHomePage> {

  // Add screen widgets to the 'tab' widget list.
  final List<Widget> tabs = [

    /*
    MyNewPage(text: 'Text 1'),
    MyNewPage(text: 'Text 2'),
    MyNewPage(text: 'Text 3'),
    MyNewPage(text: 'Text 4')
    */

  ];

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Home"),

          leading: IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyNewPage(text: 'Page')),
              );
            },
          ),

          bottom: TabBar(
            tabs: <Widget>[
              new Tab(
                text: "First",
              ),
              new Tab(
                text: "Second",
              ),
              new Tab(
                text: "Third",
              ),
              new Tab(
                text: "Fourth",
              ),
            ],
          ),
        ),

        /*
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Example Text',
                style: Theme.of(context).textTheme.display1,
              ),
            ],
          ),
        ),
        */

        body: TabBarView(
          children: tabs
        ),


      ),
    );
  }
}
