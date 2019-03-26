
import 'package:flutter/material.dart';
import 'lobby_bloc.dart';
import 'game_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_database/firebase_database.dart';

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

    final lobbyBloc = LobbyProvider.of(context).lobbyBloc;

    return Scaffold(

      appBar: AppBar(
        title: StreamBuilder<int>(
            initialData: 0, // lobbyBloc.partyWidgets.length,
            stream: lobbyBloc.numRooms,
            builder: (context, snapshot) {
              return Text('Lobby - (Rooms: ${snapshot.data})');
            }
        ),
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
          String mountainKey = snapshot.key;
          Map map = snapshot.value;
          String name = map['name'] as String;
          int cPlayers = map['cPlayers'] as int;
          int mPlayers = map['mPlayers'] as int;
          return new Column(
            children: <Widget>[
              new ListTile(
                title: new Text('$name'),
                subtitle: Row(
                  children: <Widget>[
                    //Icon(Icons.linear_scale, color: Colors.yellowAccent),
                    Text("Players: " + cPlayers.toString() + "/" + mPlayers.toString()),
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
      ),


      /*StreamBuilder<List<Widget>>(
          initialData: lobbyBloc.partyWidgets,
          stream: lobbyBloc.parties,
          builder: (context, snapshot) {
            /*
            Updating the ListView widget by using .toList() to its children.
            StreamBuilder only rebuilds widgets based on a new value or
            object, so this is a decent solution.
          */

            return ListView(children: snapshot.data.toList());
          }
      ),*/

      floatingActionButton: FloatingActionButton(
        // foregroundColor: Colors.red,
        backgroundColor: Colors.red,
        child: Icon(Icons.add),
        onPressed: () {

          // Dialog widget that takes a sink from a BLoC as an argument
          return showDialog(
            context: context,
            child: CreatePartyDialog(lobbyBloc: lobbyBloc),

          );

        } ,
      ),
    );
  }
}

class CreatePartyDialog extends StatefulWidget {

  final LobbyBloc lobbyBloc;

  CreatePartyDialog({Key key, this.lobbyBloc}): super(key: key);

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
        TextFormField(
          controller: currentNumPlayers,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            icon: Icon(Icons.person),
            hintText: 'Current number of players',
            labelText: 'Current number of players',
            hintStyle: TextStyle(fontSize: 12),
            labelStyle: TextStyle(fontSize: 12),

          ),
        ),

        // Submit button
        RaisedButton(
            child: Text('Create'),
            onPressed: () {
              // Append new ListTile to the sink.
              // TODO: Add an option to remove ListTile
              /*widget.lobbyBloc.newParty.add(
                ListTile(
                  title: Text(partyName.text),
                  subtitle: Text('Players: (${currentNumPlayers.text} / ${maxNumPlayers.text})'),
                ),
              );*/
              GameDatabase.createParty(partyName.text, int.parse(maxNumPlayers.text));

              // print('Party name: ${partyName.text}\nMaximum number of players: ${maxNumPlayers.text}\nCurrent number of players: ${currentNumPlayers.text}');
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