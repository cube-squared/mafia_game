import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'game_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_database/firebase_database.dart';
import 'globals.dart' as globals;

class PartyScreen extends StatefulWidget {
  @override
  _PartyScreenState createState() => _PartyScreenState();
}

class _PartyScreenState extends State<PartyScreen> {

  Query _query;
  @override
  void initState() {
    GameDatabase.queryParties().then((Query query) {
      setState(() {
        _query = query;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text("Maifa Parties"),
        backgroundColor: Colors.red,
      ),

      body: FirebaseAnimatedList (
        query: _query,
        itemBuilder: (
            BuildContext context,
            DataSnapshot snapshot,
            Animation<double> animation,
            int index,
            ) {
          Map map = snapshot.value;
          String name = map['name'] as String;
          String leader = map['leaderName'] as String;
          int cPlayers = map['cPlayers'] as int;
          int mPlayers = map['mPlayers'] as int;
          Icon leadingIcon;
          if (cPlayers >= mPlayers) {
            leadingIcon = Icon(MdiIcons.accountRemoveOutline, color: Colors.red);
          } else {
            leadingIcon = Icon(MdiIcons.lockOpenOutline, color: Colors.green);
          }
          return new Column(
            children: <Widget>[
              new ListTile(
                title: new Text('$name'),
                leading: leadingIcon,
                subtitle: Row(
                  children: <Widget>[
                    //Icon(MdiIcons.crown, color: Colors.orangeAccent),
                    Text("Leader: " + leader),
                  ],
                ),
                trailing: Text(cPlayers.toString() + "/" + mPlayers.toString(), textScaleFactor: 1.5,),
                onTap: () {},
              ),
              new Divider(
                height: 2.0,
              ),
            ],
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        // foregroundColor: Colors.red,
        backgroundColor: Colors.red,
        child: Icon(Icons.add),
        onPressed: () {
          // Dialog widget that takes a sink from a BLoC as an argument
          return showDialog(
            context: context,
            child: CreatePartyDialog(),
          );
        } ,
      ),
    );
  }
}

class CreatePartyDialog extends StatefulWidget {
  CreatePartyDialog({Key key, }): super(key: key);

  @override
  _CreatePartyDialogState createState() => _CreatePartyDialogState();
}

class _CreatePartyDialogState extends State<CreatePartyDialog> {

  TextEditingController partyName = TextEditingController();
  TextEditingController maxNumPlayers = TextEditingController();
  TextEditingController currentNumPlayers = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text('Create a new party'),
      contentPadding: EdgeInsets.all(30),

      children: <Widget>[
        // Party name
        TextFormField(
          controller: partyName,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(
            icon: Icon(Icons.person),
            hintText: 'Party name',
            labelText: 'Party name',
            hintStyle: TextStyle(fontSize: 12),
            labelStyle: TextStyle(fontSize: 12),
          ),
        ),

        // Maximum number of players
        TextFormField(
          controller: maxNumPlayers,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            icon: Icon(Icons.person),
            hintText: 'Maximum number of players',
            labelText: 'Maximum number of players',
            hintStyle: TextStyle(fontSize: 12),
            labelStyle: TextStyle(fontSize: 12),

          ),
        ),

        // Current number of players
        /*TextFormField(
          controller: currentNumPlayers,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            icon: Icon(Icons.person),
            hintText: 'Current number of players',
            labelText: 'Current number of players',
            hintStyle: TextStyle(fontSize: 12),
            labelStyle: TextStyle(fontSize: 12),

          ),
        ),*/

        // Submit button
        RaisedButton(
            child: Text('Create'),
            onPressed: () {
              GameDatabase.createParty(partyName.text, int.parse(maxNumPlayers.text), globals.user.uid, globals.user.displayName);
              Navigator.pop(context);
            }
        ),

      ],

    );
  }
}

class RoomListTile extends StatefulWidget {

  // TODO: Create a RoomListTile widget
  // final String lobbyName;
  // final int maxNumPlayers;
  // final int currentNumPlayers;




  @override
  _RoomListTileState createState() => _RoomListTileState();
}

class _RoomListTileState extends State<RoomListTile> {
  @override
  Widget build(BuildContext context) {
    return Container(

    );
  }
}