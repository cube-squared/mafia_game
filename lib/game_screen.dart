import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'game_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_database/firebase_database.dart';
import 'globals.dart' as globals;
import 'main.dart';

class GameScreen extends StatefulWidget {
  GameScreen({Key key, this.uid}) : super(key: key);

  final String uid;

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {

  String phaseName = "Day";
  Color phaseColor = Colors.orange;

  void _setDarkMode(bool value) {
    if (value) {
      globals.darkMode = true;
    } else {
      globals.darkMode = false;
    }
    AppBuilder.of(context).rebuild();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold (
      appBar: AppBar(
        title: Text("In Game - $phaseName Phase"),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 15.0),
            child: Card (
                child: Container (
                  padding: EdgeInsets.all(10.0),
                  width: double.infinity,
                  child: Column(
                    children: <Widget>[
                      Text("$phaseName Phase", style: TextStyle(fontSize: 30, color: phaseColor)),
                      Text("Day 10", style: TextStyle(fontSize: 20)),
                    ],
                  ),
                )
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 15.0),
            child: Card (
                child: Container (
                  padding: EdgeInsets.all(10.0),
                  width: double.infinity,
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Text("You are ", style: TextStyle(fontSize: 20)),
                          Text("Mafia", style: TextStyle(fontSize: 20, color: Colors.red)),
                        ],
                      ),
                      Text("It's day 5. You are exhausted of all this crap going on in your town. But, its finally time to take out that mafia member you're sure about. Who is it?", style: TextStyle(fontSize: 15))
                    ],
                  ),
                )
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 15.0),
            child: Card (
                child: Container (
                  padding: EdgeInsets.all(10.0),
                  width: double.infinity,
                  child: Column(
                    children: <Widget>[
                      Text("Waiting for other players...", style: TextStyle(fontSize: 20, color: Colors.green)),
                    ],
                  ),
                )
            ),
          ),
          /*Padding(
            padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 15.0),
            child: Card (
              child: Container (
                padding: EdgeInsets.all(10.0),
                width: double.infinity,
                child: Column(
                  children: <Widget>[
                    Text("Who do you want to burn at the stake?", style: TextStyle(fontSize: 20)),
                    Card(
                      child: ListTile(
                        leading: Icon(MdiIcons.chevronRight, color: Colors.green),
                        title: Text("Daryl Denaga"),
                        onTap: () {},
                      ),
                    ),
                    Card(
                      child: ListTile(
                        leading: Icon(MdiIcons.chevronRight, color: Colors.green),
                        title: Text("Crockett"),
                        onTap: () {},
                      ),
                    ),
                    Card(
                      color: Colors.green[300],
                      child: ListTile(
                        leading: Icon(MdiIcons.chevronRight, color: Colors.green),
                        title: Text("Spencer"),
                        onTap: () {},
                      ),
                    ),
                    Card(
                      child: ListTile(
                        leading: Icon(MdiIcons.chevronRight, color: Colors.green),
                        title: Text("Wyatt"),
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              )
            ),
          ),
          */
          RaisedButton(
            child: Text("switch phase"),
            onPressed: () {
              setState(() {
                if (globals.darkMode) {
                  _setDarkMode(false);
                  phaseColor = Colors.orange;
                  phaseName = "Day";
                } else {
                  _setDarkMode(true);
                  phaseColor = Colors.purple;
                  phaseName = "Night";
                }
              });
            },
          )
        ],
      ),
    );
  }

}