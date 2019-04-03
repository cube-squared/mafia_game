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
          Flexible(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 0.0),
              child: PlayerList(uid: widget.uid),
            )
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(MdiIcons.playCircleOutline),
        label: Text("Start Game"),
        backgroundColor: Colors.green,
        onPressed: () {},
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

  @override
  Widget build(BuildContext context) {
    deviceSize = MediaQuery.of(context).size;
    return Container(
      height: deviceSize.height / 4,
      width: double.infinity,
      alignment: Alignment(-1.0, -1.0),
      child: Card (
        child: FittedBox(
          child: Column(
            children: <Widget> [
              Text("Party of Doom"),
              Text("Players: 0/10"),
              Text("Theme: Original"),
            ],
          ),
        ),
      ),
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
        String key = snapshot.key;
        Map map = snapshot.value;
        String name = map['name'] as String;
        bool leader = map['leader'] as bool;
        Icon leadingIcon;
        String subtitle;
        if (leader) {
          leadingIcon = Icon(MdiIcons.crown, color: Colors.orangeAccent);
          subtitle = "Party Leader";
        } else {
          leadingIcon = Icon(MdiIcons.account, color: Colors.blue);
          subtitle = "Player";
        }
        return Card(
          child: new ListTile(
            title: new Text('$name'),
            leading: leadingIcon,
            subtitle: Row(
              children: <Widget>[
                //Icon(MdiIcons.crown, color: Colors.orangeAccent),
                Text(subtitle),
              ],
            ),
            trailing: Text(subtitle, textScaleFactor: 1.5,),
            onTap: () {},
          ),
        );
      },
    );
  }
}