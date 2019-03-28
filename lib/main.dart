import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'user_database.dart';
import 'party_screen.dart';
import 'globals.dart' as globals;

void main() => runApp(MyApp());

class AppBuilder extends StatefulWidget {
  final Function(BuildContext) builder;

  const AppBuilder(
      {Key key, this.builder})
      : super(key: key);

  @override
  AppBuilderState createState() => new AppBuilderState();

  static AppBuilderState of(BuildContext context) {
    return context.ancestorStateOfType(const TypeMatcher<AppBuilderState>());
  }
}

class AppBuilderState extends State<AppBuilder> {

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }

  void rebuild() {
    setState(() {});
  }
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBuilder(builder: (context) {
      ThemeData theme;
      if (globals.darkMode)
        theme = ThemeData.dark();
      else
        theme = ThemeData.light();
      return MaterialApp(
        title: globals.appName,
        theme: theme,
        home: HomeScreen(title: globals.homeTitle),
      );
    });
  }
}

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // to logout
  void _logout() {
    globals.isLoggedIn = false;
    globals.user = null;
    AppBuilder.of(context).rebuild();
    _showDialog("logout");
  }

  // for light/dark mode
  void _setDarkMode() {
    if (globals.darkMode) {
      globals.darkMode = false;
    } else {
      globals.darkMode = true;
    }
    AppBuilder.of(context).rebuild();
  }


  // for hack the mainframe
  void _showDialog(String type) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String text = "";
        if (type == "hack") {
          if (globals.isLoggedIn) {
            text = "We know who you are, " + globals.user.displayName + ". Why would you want to hack now?";
          } else {
            text = "You must be logged in to use hacking tools.";
          }
        } else if (type == "logout") {
          text = "You have been logged out.";
        } else if (type == "settings") {
          text = "Yeah so there are no settings yet. Please check back later.";
        }
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Notice"),
          content: new Text(text),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Okay"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
/*
  @override
  Widget build(BuildContext context) {

    DefaultTabController pageData;

    //if (globals.isLoggedIn) {
      pageData = DefaultTabController(
        length: 3,
        child: new Scaffold(
          appBar: new AppBar(
            title: new Text("Simple Tab Demo"),
            bottom: new TabBar(
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
              ],
            ),
          ),
          body: new TabBarView(
            children: <Widget>[
              new Container(
                color: Colors.deepOrangeAccent,
                child: new Center(
                  child: new Text("First"),
                ),
              ),
              new Container(
                color: Colors.blueGrey,
                child: new Center(
                  child: new Text("Second"),
                ),
              ),
              new Container(
                color: Colors.teal,
                child: new Center(
                  child: new Text("Third"),
                ),
              ),
            ],
          ),
        ),
      );
    //}

    return pageData;

  }
*/

  @override
  Widget build(BuildContext context) {

    Scaffold pageData;
    if (globals.isLoggedIn) { // user is logged in
      pageData = new Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.accessible),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PartyScreen()),
              ),//Navigator.push(context, MaterialPageRoute(builder: (context) => TestScreen())),
            ),
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => UserDatabase.getNickname(globals.user.uid),//Navigator.push(context, MaterialPageRoute(builder: (context) => TestScreen())),
            ),
            IconButton(
              icon: Icon(Icons.wb_sunny),
              onPressed: () => _setDarkMode(), //_showDialog("settings"),
            ),
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () => _logout(),
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.network(
                globals.user.photoUrl,
              ),
              Text(
                'Welcome back, ' + globals.user.displayName,
                textScaleFactor: 2,
              ),
              Text(
                "Email: " + globals.user.email,
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showDialog("hack"),
          icon: Icon(Icons.public),
          label: Text("Hack the mainframe"),
          backgroundColor: Colors.orange,
        ),
      );

    } else { // user is not logged in
      pageData = new Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'You aren\'t logged in.',
                textScaleFactor: 2,
              ),
              RaisedButton(
                child: Text("Login", textScaleFactor: 2,),
                color: Colors.blueAccent,
                onPressed: () =>  Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showDialog("hack"),
          icon: Icon(Icons.public),
          label: Text("Hack the mainframe"),
          backgroundColor: Colors.orange,
        ),
      );
    }

    return pageData;
  }




}
