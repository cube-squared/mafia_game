import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'game_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_database/firebase_database.dart';
import 'globals.dart' as globals;

class GameScreen extends StatefulWidget {
  GameScreen({Key key, this.uid}) : super(key: key);

  final String uid;

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold (
      appBar: AppBar(
        title: Text("In Game - Day Phase"),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Card (
              child: Container (
                padding: EdgeInsets.all(10.0),
                child: Column(
                  children: <Widget>[
                    Text("Who do you want to burn at the stake?", style: TextStyle(fontSize: 20)),
                    RaisedButton(
                      child: Text("Daryl Denaga"),
                      onPressed: () {},
                    ),
                    RaisedButton(
                      child: Text("Spencer Floyd"),
                      onPressed: () {},
                    ),
                    RaisedButton(
                      child: Text("Matt Sheppard"),
                      onPressed: () {},
                    ),
                    RaisedButton(
                      child: Text("Crockett"),
                      onPressed: () {},
                    )
                  ],
                ),
              )
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15.0, 0, 15.0, 15.0),
            child: Card (
              child: Container (
                padding: EdgeInsets.all(10.0),
                child: Column(
                  children: <Widget>[
                    Text("Day 5 Narration", style: TextStyle(fontSize: 20)),
                    Text("It's day 5. You are exhausted of all this crap going on in your town. But, its finally time to take out that mafia member you're sure about. Who is it?")
                  ],
                ),
              )
            ),
          ),
        ],
      ),
    );
  }

}