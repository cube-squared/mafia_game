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
    return Scaffold(
      appBar: AppBar(
        title: Text("Party"),
        backgroundColor: Colors.green,
      ),
      body: FirebaseAnimatedList (
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
          if (leader) {
            leadingIcon = Icon(MdiIcons.crown, color: Colors.orangeAccent);
          } else {
            leadingIcon = Icon(MdiIcons.account, color: Colors.blue);
          }
          return Card(
            child: new Column(
              children: <Widget>[
                new ListTile(
                  title: new Text('$name'),
                  leading: leadingIcon,
                  subtitle: Row(
                    children: <Widget>[
                      //Icon(MdiIcons.crown, color: Colors.orangeAccent),
                      Text("Leader: "),
                    ],
                  ),
                  trailing: Text("/rajsjsryk", textScaleFactor: 1.5,),
                  onTap: () {},
                ),
                new Divider(
                  height: 2.0,
                ),
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




