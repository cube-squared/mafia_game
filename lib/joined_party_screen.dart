import 'dart:async';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'game_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_database/firebase_database.dart';
import 'globals.dart' as globals;

class JoinedPartyScreen extends StatefulWidget {
  JoinedPartyScreen({Key key, this.uid}) : super(key: key);

  final String uid;

  @override
  _JoinedPartyScreenState createState() => _JoinedPartyScreenState();
}

class _JoinedPartyScreenState extends State<JoinedPartyScreen> {

  bool userReady = false;
  String FABtext = "Not Ready";
  Icon FABicon = Icon(MdiIcons.minusCircleOutline);
  Color FABcolor = Colors.red;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Party"),
        backgroundColor: Colors.green,
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: (){
            showDialog(context: context, builder: (BuildContext context) {
              return AlertDialog(
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
                    }
                  ),
                ],
              );
            });
          }
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
      floatingActionButton: FloatingActionButton.extended(
        icon: FABicon, //Icon(MdiIcons.playCircleOutline),
        label: Text(FABtext), // Text("Start Game"),
        backgroundColor: FABcolor,
        onPressed: () {
          if (!userReady) {
            userReady = true;
            GameDatabase.setStatus(widget.uid, globals.user, "ready");
            setState(() {
              FABcolor = Colors.green;
              FABicon = Icon(MdiIcons.check);
              FABtext = "Ready";
            });
          } else {
            userReady = false;
            GameDatabase.setStatus(widget.uid, globals.user, "notready");
            setState(() {
              FABcolor = Colors.red;
              FABicon = Icon(MdiIcons.minusCircleOutline);
              FABtext = "Not Ready";
            });
          }
        },
      ),
    );
  }

}


class PartyDetails extends StatefulWidget {
  PartyDetails({Key key, this.uid}) : super(key: key);

  final String uid;

  @override
  _PartyDetailsState createState() => _PartyDetailsState();
}

class _PartyDetailsState extends State<PartyDetails> {

  Size deviceSize;
  Map<String, dynamic> info;
  StreamSubscription infoSubscription;
  Widget startButton;

  @override
  void initState() {
    GameDatabase.getPartyInfoStream(widget.uid, _updateInfo).then((StreamSubscription s) => infoSubscription = s);

    super.initState();
  }

  void _updateInfo(Map<String, dynamic> map) {
    setState(() {
      info = map;
    });
  }

  @override
  Widget build(BuildContext context) {
    String lockedText;
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
                      Text("Theme: Original", style: TextStyle(fontSize: 20),),
                      Text(lockedText, style: TextStyle(fontSize: 20),),
                      Text("Party UID: " + widget.uid, style: TextStyle(fontSize: 15),),
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
        String name = map['name'] as String;
        String photoUrl = map['photoUrl'] as String;
        bool leader = map['leader'] as bool;
        String status = map['status'] as String;
        List<Widget> subtitle;
        List<Widget> trailing;

        if (userUID == globals.user.uid) {
          name += " (You)";
        }

        if (status == "notready") {
          trailing = <Widget> [
            Text("Not Ready ", style: TextStyle(color: Colors.red), textScaleFactor: 1.5,),
            Icon(MdiIcons.minusCircleOutline, color: Colors.red),
          ];
        } else if (status == "ready") {
          trailing = <Widget> [
            Text("Ready ", style: TextStyle(color: Colors.green), textScaleFactor: 1.5,),
            Icon(MdiIcons.check, color: Colors.green,),
          ];
        }

        if (leader) {
          subtitle = <Widget> [
            Icon(MdiIcons.crown, color: Colors.orangeAccent),
            Text("Party Leader"),
          ];
        } else {
          subtitle = <Widget> [
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

      },
    );
  }
}