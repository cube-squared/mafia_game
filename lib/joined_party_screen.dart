import 'dart:async';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'game_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_database/firebase_database.dart';
import 'globals.dart' as globals;
import 'game_screen.dart';
import 'chat_screen.dart';
import 'ui_tools.dart';
import 'game.dart';
import 'game2.dart';

class JoinedPartyScreen extends StatefulWidget {
  JoinedPartyScreen({Key key, this.uid}) : super(key: key);

  final String uid;


  @override
  _JoinedPartyScreenState createState() => _JoinedPartyScreenState();
}

class _JoinedPartyScreenState extends State<JoinedPartyScreen> {

  StreamSubscription infoSubscription;

  @override
  void initState() {
    GameDatabase.getPartyInfoStream(widget.uid, _updateInfo).then((StreamSubscription s) => infoSubscription = s);
    super.initState();
  }

  void _updateInfo(Map<String, dynamic> map) {
    setState(() {
      info = map;
      if (info['status'] == "ingame" || info['status'] == "loading")
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => GameScreen(uid: widget.uid)),
        );
    });
  }

  Future<void> _checkLeave() {
    if (globals.confirmOnPartyExit) {
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _checkLeave(),
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        appBar: AppBar(
          title: Text("Party"),
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back),
            onPressed: () => _checkLeave(),
             ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(icon: Icon(Icons.menu), onPressed: () {
                // currently does nothing
              },),
              IconButton(icon: Icon(Icons.chat), onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatScreen(uid: widget.uid)),
                );
              }),
            ],
          ),
        ),
        body: Column(
          children: <Widget>[

            // party display / settings
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: PartyDetails(uid: widget.uid,),
            ),

            // player list
            Flexible(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 0.0),
                  child: PlayerList(uid: widget.uid),
                )
            ),
          ],
        ),
        floatingActionButton: FAB(uid: widget.uid),
      ),
    );

  }

}


class FAB extends StatefulWidget {
  FAB({Key key, this.uid}) : super(key: key);

  final String uid;

  @override
  _FABState createState() => _FABState();
}

class _FABState extends State<FAB> {

  bool userReady = false;
  String FABtext = "Not Ready";
  Icon FABicon = Icon(MdiIcons.minusCircleOutline);
  Color FABcolor = Colors.red;

  @override
  Widget build(BuildContext context) {
    // check if all players ready
    bool allReady = true;
    info['players'].forEach((uid, playerData) {
      if (playerData['status'] != "ready")
        allReady = false;
    });

    if (globals.user.uid == info['leaderUID'] && allReady) {
      return FloatingActionButton.extended(
        icon: Icon(MdiIcons.playCircleOutline),
        label: Text("Start Game"),
        backgroundColor: Colors.blue,
        onPressed: () {
          Game2.assignRoles(widget.uid);
          GameDatabase.setNarration(widget.uid, "intro", "");
          GameDatabase.setPartyStatus(widget.uid, "ingame");
          GameDatabase.startCountdown(widget.uid, 15, false);
        },
      );
    }

    return FloatingActionButton.extended(
      icon: FABicon, //Icon(MdiIcons.playCircleOutline),
      label: Text(FABtext), // Text("Start Game"),
      backgroundColor: FABcolor,
      onPressed: () {
        if (!userReady) {
          userReady = true;
          GameDatabase.setPlayerStatus(widget.uid, globals.user, "ready");
          setState(() {
            FABcolor = Colors.green;
            FABicon = Icon(MdiIcons.check);
            FABtext = "Ready";
          });
        } else {
          userReady = false;
          GameDatabase.setPlayerStatus(widget.uid, globals.user, "notready");
          setState(() {
            FABcolor = Colors.red;
            FABicon = Icon(MdiIcons.minusCircleOutline);
            FABtext = "Not Ready";
          });
        }
      },
    );
  }
}



class PartyDetails extends StatefulWidget {
  PartyDetails({Key key, this.uid}) : super(key: key);

  final String uid;

  @override
  _PartyDetailsState createState() => _PartyDetailsState();
}


// info is global so we can access it from PartyDetails card and top appbar
Map<String, dynamic> info;
class _PartyDetailsState extends State<PartyDetails> {

  Size deviceSize;
  Widget startButton;

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    String lockedText;
    try {
      if (info['locked']) {
        lockedText = "Party Locked";
      } else {
        lockedText = "Party Unlocked";
      }
      return Card (
          child: Container(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                Text(info['name'], style: TextStyle(fontSize: 40, color: Colors.orange),),
                Row (
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column (
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("Leader: " + info['leaderName'], style: TextStyle(fontSize: 20),),
                        Text("Theme: " + capitalize(info['theme']), style: TextStyle(fontSize: 20),),
                        //Text(lockedText, style: TextStyle(fontSize: 20),),
                        //Text("Party UID: " + widget.uid, style: TextStyle(fontSize: 15),),
                      ],
                    ),
                    Column (
                      children: <Widget>[
                        Text("Players:", style: TextStyle(fontSize: 20),),
                        Text(info["cPlayers"].toString() + "/" + info['mPlayers'].toString(), style: TextStyle(fontSize: 30),),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          )
      );
    } catch (e) {
      return Card(
        child: Text("Error displaying party details"),
      );
    }

  }

}




class PlayerList extends StatefulWidget {
  PlayerList({Key key, this.uid}) : super(key: key);

  final String uid;

  @override
  _PlayerListState createState() => _PlayerListState();
}

class _PlayerListState extends State<PlayerList> {

  Query _partyquery;

  @override
  void initState() {
    GameDatabase.queryParty(widget.uid).then((Query partyquery) {
      setState(() {
        _partyquery = partyquery;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FirebaseAnimatedList (
      query: _partyquery,
      itemBuilder: (
          BuildContext context,
          DataSnapshot snapshot,
          Animation<double> animation,
          int index,
          ) {

        String userUID = snapshot.key;

        Map map = snapshot.value;
        String name;
        String photoUrl;
        bool leader;
        String status;
        name = map['name'] as String;
        leader = map['leader'] as bool;
        photoUrl = map['photoUrl'] as String;
        status = map['status'] as String;
        List<Widget> subtitle;
        List<Widget> trailing;

        try {
          if (userUID == globals.user.uid) {
            name += " (You)";
          }

          if (status == "notready") {
            trailing = <Widget>[
              Text("Not Ready ", style: TextStyle(color: Colors.red),
                textScaleFactor: 1.5,),
              Icon(MdiIcons.minusCircleOutline, color: Colors.red),
            ];
          } else if (status == "ready") {
            trailing = <Widget>[
              Text("Ready ", style: TextStyle(color: Colors.green),
                textScaleFactor: 1.5,),
              Icon(MdiIcons.check, color: Colors.green,),
            ];
          }

          if (leader) {
            subtitle = <Widget>[
              Icon(MdiIcons.crown, color: Colors.orangeAccent),
              Text("Party Leader"),
            ];
          } else {
            subtitle = <Widget>[
              Icon(MdiIcons.account, color: Colors.blue),
              Text("Player"),
            ];
          }


          return Card(
            child: new ListTile(
              title: new Text('$name'),
              leading: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(35.0),
                    border: Border.all(width: .5, color: Colors.black12)),
                child: CircleAvatar(
                  radius: 20.0,
                  backgroundImage: NetworkImage(photoUrl),
                ),
              ),
              subtitle: Row(
                children: subtitle,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: trailing,
              ),
              onTap: () {},
            ),
          );
        } catch (e) {
          return Card(
            child: Text("Error displaying player list"),
          );
        }

      },
    );
  }
}
