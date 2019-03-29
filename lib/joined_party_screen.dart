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

  Size deviceSize;

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

  Widget partyHeader() =>
      Container(
        height: 2 * deviceSize.height / 7,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Card(
            clipBehavior: Clip.antiAlias,
            color: Colors.green,
            child: FittedBox(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text(
                      "Spencer's Party",
                      style: TextStyle(color: Colors.white),
                    ),
                    Row(
                      children: <Widget>[
                        Icon(MdiIcons.crown, color: Colors.orange, size: 10),
                        Text("Spencer Floyd",
                          style: TextStyle(color: Colors.white),
                          textScaleFactor: .75,),
                      ],
                    ),
                    Text(
                      "Theme: Original",
                      style: TextStyle(color: Colors.white),
                      textScaleFactor: .75,
                    ),
                    Text(
                      "Players: 5/10",
                      style: TextStyle(color: Colors.white),
                      textScaleFactor: .75,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  /*Widget playerList () => FirebaseAnimatedList (
    query: _query,
    itemBuilder: (
        BuildContext context,
        DataSnapshot snapshot,
        Animation<double> animation,
        int index,
        ) {
      String key = snapshot.key;
      Map map = snapshot.value;
      String name = map['name'] as String;
      String photoUrl = map['photoUrl'] as String;
      Icon leadingIcon;
      return new Column(
        children: <Widget>[
          new ListTile(
            title: new Text('$name'),
            leading: Icon(MdiIcons.accountOutline),
            subtitle: Row(
              children: <Widget>[
                //Icon(MdiIcons.crown, color: Colors.orangeAccent),
                Text("Leader:"),
              ],
            ),
            onTap: () {},
          ),
          new Divider(
            height: 2.0,
          ),
        ],
      );
    },
  );*/

  @override
  Widget build(BuildContext context) {
    deviceSize = MediaQuery
        .of(context)
        .size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Party"),
        backgroundColor: Colors.green,
      ),
      body: FirebaseAnimatedList(
        query: _partyquery,
        itemBuilder: (BuildContext context,
            DataSnapshot snapshot,
            Animation<double> animation,
            int index,) {
          String key = snapshot.key;
          Map map = snapshot.value;
          String name = map['name'] as String;
          String photoUrl = map['photoUrl'] as String;
          //bool leader = map['leader'] as bool;
          Icon leadingIcon;
          //if (leader) {
          //  leadingIcon = Icon(MdiIcons.crown, color: Colors.orange);
          //} else {
          //  leadingIcon = Icon(MdiIcons.accountOutline, color: Colors.black26);
          //}
          return new Card(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: Icon(MdiIcons.accountOutline, color: Colors.black26, size: 30,),
                  title: Text(name, style: TextStyle(color: Colors.black87, fontSize: 20)),
                ),
                Text("hello")
              ],
            ),
          );
        },
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




