import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'game_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_database/firebase_database.dart';
import 'globals.dart' as globals;
import 'main.dart';
import 'chat_screen.dart';
import 'ui_tools.dart';
import 'dart:async';
import 'game.dart';
import 'dart:math';


class GameScreen extends StatefulWidget {
  GameScreen({Key key, this.uid}) : super(key: key);

  final String uid;

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {

  @override
  Widget build(BuildContext context) {
    List<String> allPlayers;
    GameDatabase.getAllPlayersNames(widget.uid).then((List<String> a) => allPlayers = a);
    return Scaffold (
      appBar: AppBar(
        title: Text("In Game - Day Phase"),
      ),
      body: ListView(
        children: <Widget>[
          DayNightHeading(day: true, dayNum: 10,),
          Narration(role: "Mafia", text: "It's day 10. The town wakes up to find Trey murdered in cold blood and left out to dry hanging from the clothes line in his backyard. You are pretty sure no one else knows you are a part of the mafia yet (and a part of Trey's murder), but you can't be too sure. You know that one guy has been sounding pretty suspicious when he was talking about you. Maybe it's time to take him out."),
          PlayerSelector(players: allPlayers, uid: widget.uid),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(icon: Icon(Icons.help), onPressed: () {
              UITools.showBasicPopup(context, "Game Information", "You are part of the Mafia. Every night, you will be able to select someone to kill with your fellow mafia members. If the medic doesn't choose to save that person, they will be killed. During the day, all the townspeople will vote on someone to hang for suspicion of being a mafia member, so it's your job to keep your job secret.");
            }),
            Row(
              children: <Widget>[
                Icon(MdiIcons.timer, color: Colors.green,),
                Text("1:23", style: TextStyle(fontSize: 23, color: Colors.green),),
              ],
            ),
            IconButton(icon: Icon(Icons.chat), onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatScreen(uid: widget.uid)),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class DayNightHeading extends StatefulWidget {
  DayNightHeading({Key key, this.day, this.dayNum}) : super(key: key);

  final bool day;
  final int dayNum;

  @override
  _DayNightHeadingState createState() => _DayNightHeadingState();
}

class _DayNightHeadingState extends State<DayNightHeading> {
  @override
  Widget build(BuildContext context) {
    String phase;
    Color phaseColor;
    if (widget.day) {
      phase = "Day";
      phaseColor = Colors.orange;
    } else {
      phase = "Night";
      phaseColor = Colors.purple;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 15.0),
      child: Card (
          child: Container (
            padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("$phase Phase", style: TextStyle(fontSize: 30, color: phaseColor)),
                    Text("Day " + widget.dayNum.toString(), style: TextStyle(fontSize: 20)),
                  ],
                ),
                Column(
                  children: <Widget>[
                    Text("You are", style: TextStyle(fontSize: 12)),
                    Row(
                      children: <Widget>[
                        Text("Mafia", style: TextStyle(fontSize: 25, color: Colors.red)),
                        Icon(MdiIcons.hatFedora, color: Colors.red, size: 30),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          )
      ),
    );
  }
}



class WaitingForPlayers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }
}

class Narration extends StatelessWidget {
  Narration({Key key, this.role, this.text}) : super(key: key);

  final String role;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 15.0),
      child: Card(
          child: Container(
            padding: EdgeInsets.all(10.0),
            width: double.infinity,
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Text("Day 10", style: TextStyle(fontSize: 20)),
                  ],
                ),
                Text(text, style: TextStyle(fontSize: 15))
              ],
            ),
          )
      ),
    );
  }
}

class PlayerSelector extends StatefulWidget {
  PlayerSelector({Key key, this.players, this.uid}) : super(key: key);

  final List<String> players;
  final String uid;

  @override
  _PlayerSelectorState createState() => _PlayerSelectorState();
}

class _PlayerSelectorState extends State<PlayerSelector> {
  List<String> selectedPlayers = new List<String>();
  int numberSelected;
  List<String> allPlayers;
  String votingPrompt;
  Icon iconSelected;

  void addToSelection(String name) {
    setState(() {
      if (selectedPlayers.contains(name)) {
        selectedPlayers.remove(name);
        return;
      }
      if (selectedPlayers.length >= numberSelected) {
        selectedPlayers.remove(selectedPlayers[0]);
      }
      selectedPlayers.add(name);
    });
  }


  @override
  Widget build(BuildContext context) {

    String role;
    GameDatabase.getPlayerAttribute(widget.uid, globals.user.uid, "role").then((dynamic r) => role = r);

    allPlayers = widget.players;
    numberSelected = 0;

    if (Game.sleepyTime == false) {
      iconSelected = Icon(MdiIcons.hatFedora, color: Colors.black);
      numberSelected = 1;
      votingPrompt = "Select who you think is the Mafia:";
    }
    else if (Game.sleepyTime) {
      if (role == "doctor") {
        iconSelected = Icon(MdiIcons.medicalBag, color: Colors.green);
        numberSelected = 1;
        votingPrompt = "Select a player to save:";
      }
      else if (role == "mafia") {
        numberSelected = (Player.mafiaMembers.length / sqrt(Player.allThePlayers.length)).round();
        iconSelected = Icon(MdiIcons.skullOutline, color: Colors.red);
        if(numberSelected > 1){
          votingPrompt = "Select " + numberSelected.toString() + "players to kill:";
        }
        else if(numberSelected == 1) {
          votingPrompt = "Select a player to kill:";
        }
      }
    }

    // put prompt at top
    List<Widget> widgets = new List<Widget>();
    widgets.add(Text(votingPrompt, style: TextStyle(fontSize: 20)));

    // build list of players to select from
    widget.players.forEach((String name) {
      Color bkgColor = Theme.of(context).cardColor;
      Icon icon = Icon(MdiIcons.chevronRight, color: Colors.green);
      if (selectedPlayers.contains(name)) {
        if (globals.darkMode)
          bkgColor = Colors.red.withOpacity(.5);
        else
          bkgColor = Colors.red[100];
        icon = iconSelected;
      }
      widgets.add(Card(
        color: bkgColor,
        child: ListTile(
          leading: icon,
          title: Text(name),
          onTap: () {addToSelection(name);},
        ),
      ));
    });

    // return final card for UI
    return Padding(
      padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 15.0),
      child: Card (
          child: Container (
            padding: EdgeInsets.all(10.0),
            width: double.infinity,
            child: Column(
              children: widgets,
            ),
          )
      ),
    );
  }
}