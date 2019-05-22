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
import 'package:mafia_game/game_database.dart';


class GameScreen extends StatefulWidget {
  GameScreen({Key key, this.uid}) : super(key: key);

  final String uid;

  @override
  _GameScreenState createState() => _GameScreenState();
}

Map<String, dynamic> gamedata;
class _GameScreenState extends State<GameScreen> {

  StreamSubscription infoSubscription;

  @override
  void initState() {
    GameDatabase.getGameInfoStream(widget.uid, _updateInfo).then((StreamSubscription s) => infoSubscription = s);
    super.initState();
  }

  void _updateInfo(Map<String, dynamic> map) {
    setState(() {
      gamedata = map;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];

    if (gamedata['status'] == "ingame") {

        widgets.add(DayNightHeading(day: gamedata["daytime"], dayNum: gamedata["day"]));
        String narration = gamedata['players'][globals.user.uid]['role'] + "Narration";
        widgets.add(Narration(day: gamedata['day'], text: gamedata[narration]));



      if (gamedata["daytime"] || gamedata['players'][globals.user.uid]["role"] != "innocent") {
        widgets.add(PlayerSelector(uid: widget.uid));
      } else {
        widgets.add(WaitingNight());
      }
    } else if (gamedata['status'] == "loading") {
      widgets.add(WaitingLoading(daytime: gamedata['daytime'],));
    }

    Color timerColor;
    if (gamedata["timer"] > 20)
      timerColor = Colors.green;
    else if (gamedata["timer"] <= 10)
      timerColor = Colors.red;
    else
      timerColor = Colors.orange;

    return WillPopScope(
      onWillPop: () => _checkLeave(),
      child: Scaffold (
        appBar: AppBar(
          title: Text("In Game - " + gamedata["name"]),
        ),
        body: ListView(
          children: widgets,
        ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(icon: Icon(Icons.help), onPressed: () {
                UITools.showBasicPopup(context, "Game Information", "This game was created by Cube Squared, the best company in the world at making dumb stuff actually kind of work.");
              }),
              Row(
                children: <Widget>[
                  Icon(MdiIcons.timer, color: timerColor,),
                  Text(gamedata["timer"].toString(), style: TextStyle(fontSize: 23, color: timerColor),),
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
      ),
    );
  }

  Future<void> _checkLeave() async {
    if (globals.confirmOnPartyExit || globals.confirmOnPartyExit == null) {
      return showDialog(
        context: context,
        builder: (context) => new AlertDialog(
          title: Text("Leaving Party"),
          content: Text("Are you sure you want to leave this party?"),
          actions: <Widget> [
            FlatButton(
                child: Text("Stay"),
                onPressed: () {
                  Navigator.pop(context); // close the dialog
                }
            ),
            FlatButton(
                child: Text("Leave"),
                onPressed: () {
                  Navigator.pop(context); // close the dialog
                  Navigator.pop(context,true); // leave party UI
                  GameDatabase.leaveParty(widget.uid, globals.user);
                  globals.chatQuery = null; // reset internal party chat cache
                }
            ),
          ],
        ),
      );
    } else {
      Navigator.pop(context,true); // leave party UI
      GameDatabase.leaveParty(widget.uid, globals.user);
      globals.chatQuery = null; // reset internal party chat cache
    }
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
    String role = gamedata['players'][globals.user.uid]['role'].toString().toLowerCase();

    String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

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
            child: Column(
              children: <Widget>[
                // User and Role
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    // User avatar/name
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        CircleAvatar(
                          backgroundImage: NetworkImage(globals.user.photoUrl),
                          radius: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(globals.user.displayName, style: TextStyle(fontSize: 20)),
                        ),
                      ],
                    ),
                    // Role text/icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        // Get role from Firebase
                        Text(
                            (role != '' ? capitalize(role) : 'Unassigned'),
                            style: TextStyle(
                                fontSize: 20,
                                color:
                                (
                                    (role == 'doctor') ? Colors.blue :
                                    (role == 'mafia') ? Colors.red :
                                    null
                                )
                            )
                        ),
                        Icon(
                            (
                                (role == 'innocent') ? Icons.person :
                                (role == 'doctor') ? MdiIcons.doctor :
                                (role == 'mafia') ? MdiIcons.hatFedora :
                                null
                            ),
                            color:
                            (
                                (role == 'doctor') ? Colors.blue :
                                (role == 'mafia') ? Colors.red :
                                null
                            ),
                            size: 30
                        ),
                      ],
                    ),
                  ],
                ),

                // Role Description
                Column(
                  children: <Widget>[
                    FutureBuilder<Object>(
                        future: GameDatabase.getRoleDescription(role),
                        builder: (context, snapshot) {
                          return Text(snapshot.data.toString(), style: TextStyle(fontSize: 15));
                        }
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

class WaitingNight extends StatelessWidget {
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
                Text("You sleep soundly through the night.", style: TextStyle(fontSize: 20, color: Colors.green)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                  child: Text("Waiting for other players...", style: TextStyle(fontSize: 15)),
                ),
              ],
            ),
          )
      ),
    );
  }
}

class WaitingLoading extends StatelessWidget {
  WaitingLoading({Key key, this.daytime}) : super(key: key);
  bool daytime = false;

  @override
  Widget build(BuildContext context) {
    String text = "";
    if (daytime) {
      text = "The day is coming to an end.";
    } else {
      text = "You begin to wake up.";
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 15.0),
      child: Card (
          child: Container (
            padding: EdgeInsets.all(10.0),
            width: double.infinity,
            child: Column(
              children: <Widget>[
                Text(text, style: TextStyle(fontSize: 35, color: Colors.blue)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                  child: Text("Waiting for the host...", style: TextStyle(fontSize: 15)),
                ),
              ],
            ),
          )
      ),
    );
  }
}

class Narration extends StatelessWidget {
  Narration({Key key, this.day, this.text}) : super(key: key);

  final int day;
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
                    Text("Day " + day.toString(), style: TextStyle(fontSize: 20)),
                  ],
                ),
                Text(
                  // Check if the string is null
                    (text != null ? text : ''),
                    style: TextStyle(fontSize: 15)
                )
              ],
            ),
          )
      ),
    );
  }
}

class PlayerSelector extends StatefulWidget {
  PlayerSelector({Key key, this.uid}) : super(key: key);

  final String uid;

  @override
  _PlayerSelectorState createState() => _PlayerSelectorState();
}

List<Map<String, String>> allPlayers;
class _PlayerSelectorState extends State<PlayerSelector> {
  List<String> selectedPlayers = new List<String>();
  int numberSelected = 1;
  String votingPrompt = "hi";
  Icon iconSelected = Icon(MdiIcons.vote);

  StreamSubscription playerSubscription;

  @override
  void initState() {
    GameDatabase.getAllPlayersNamesStream(widget.uid, _updateInfo).then((StreamSubscription s) => playerSubscription = s);
    super.initState();
  }

  void _updateInfo(List<Map<String, String>> list) {
    setState(() {
      allPlayers = list;
    });
  }

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
    GameDatabase.setPlayerAttribute(widget.uid, globals.user.uid, "vote", selectedPlayers);
  }
  List<List<Widget>> getPicWidgets(String role) {
    List<List<Widget>> picWidgets = [];
    if(role == "all") {
      allPlayers.forEach((Map<String, String> player) {
        List<Widget> widgeList = [];
        allPlayers.forEach((Map<String, String> player2) {
          if (gamedata["players"][player2["uid"]]["vote"] != null) {
            if (gamedata["players"][player2["uid"]]["vote"][0] ==
                player["uid"]) {
              widgeList.add(
                CircleAvatar(
                  backgroundImage: NetworkImage(
                      gamedata["players"][player2["uid"]]["photoUrl"]),
                  radius: 20,

                ),

              );
            }
          }
        });
        picWidgets.add(widgeList);
      });
    }
    else {
      allPlayers.forEach((Map<String, String> player) {
        List<Widget> widgeList = [];
        allPlayers.forEach((Map<String, String> player2) {
          if (gamedata["players"][player2["uid"]]["vote"] != null) {
            if (gamedata["players"][player2["uid"]]["vote"][0] ==
                player["uid"] &&
                gamedata["players"][player2["uid"]]["role"] == role) {
              widgeList.add(
                CircleAvatar(
                  backgroundImage: NetworkImage(
                      gamedata["players"][player2["uid"]]["photoUrl"]),
                  radius: 20,

                ),

              );
            }
          }
        });
        picWidgets.add(widgeList);
      });
    }
    return picWidgets;
  }
  @override
  Widget build(BuildContext context) {

    //change this so its not hardcoded
    bool day = gamedata["daytime"];
    //bool day = true;
    List<String> mafias = [];
    String mafiaString = "";
    String role = gamedata["players"][globals.user.uid]["role"];
    print(allPlayers.length);
    allPlayers.forEach((Map<String, String> player) {
      if(gamedata["players"][player["uid"]]["role"] == "mafia" && player["uid"] != globals.user.uid){
        mafias.add(player["name"]);
      }

    });
    var num1 = 0;
    if(mafias.length == 0){
      mafiaString = "none";
    }
    else {
      mafias.forEach((String maf) {
        if (num1 + 1 < mafias.length) {
            mafiaString += maf + ", ";
        }
        else {
          mafiaString += maf;
        }
        num1++;
      });
    }

    List<List<Widget>> picWidgets;
    if (day == true) {
      iconSelected = Icon(MdiIcons.hatFedora, color: Colors.black);
      votingPrompt = "Select who you think is the Mafia:";
    }
   else if (day == false) {
      if (role == "doctor") {
        iconSelected = Icon(MdiIcons.medicalBag, color: Colors.green);
        votingPrompt = "Select a player to save:";
        picWidgets = getPicWidgets("doctor");
      }
      else if (role == "mafia") {
        //numberSelected = (Game.numOfMafia / sqrt(allPlayers.length)).round();
        iconSelected = Icon(MdiIcons.skullOutline, color: Colors.red);
        picWidgets = getPicWidgets("mafia");
        if (numberSelected > 1) {
          votingPrompt =
              "Select " + numberSelected.toString() + " players to kill:";
        }
        else if (numberSelected == 1) {
          votingPrompt = "Select a player to kill(Other mafia: " + mafiaString + "):";
        }
      }
    }

    // put prompt at top
    List<Widget> widgets = new List<Widget>();
    widgets.add(Text(votingPrompt, style: TextStyle(fontSize: 20)));

    // build list of players to select from
    var num = 0;
    allPlayers.forEach((Map<String, String> player){

      if(player["role"] == "mafia"){
        //display photoURL small and to the right for their selected player
        String photo = player["photoURL"];
      }

      Color bkgColor = Theme
          .of(context)
          .cardColor;
      Icon icon = Icon(MdiIcons.chevronRight, color: Colors.green);
      if (selectedPlayers.contains(player["uid"])) {
        if (globals.darkMode)
          bkgColor = Colors.red.withOpacity(.5);
        else if (role == "doctor" && day == false) {
          bkgColor = Colors.green[100];
          icon = iconSelected;
        }
        else {
          bkgColor = Colors.red[100];
          icon = iconSelected;
        }
      }
      widgets.add(Card(
        color: bkgColor,
        child:
          ListTile(
          leading: icon,
          title: Text(player["name"]),
          trailing:
          Row(
            mainAxisSize: MainAxisSize.min,
            children: picWidgets[num]
          ),
          onTap: () {addToSelection(player["uid"]);},
        ),
      ));
      num++;
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