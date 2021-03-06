import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'game_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_database/firebase_database.dart';
import 'globals.dart' as globals;
import 'joined_party_screen.dart';
import 'ui_tools.dart';

class PartyScreen extends StatefulWidget {
  @override
  _PartyScreenState createState() => _PartyScreenState();
}

class _PartyScreenState extends State<PartyScreen> {

  @override
  void initState() {
    GameDatabase.queryParties().then((Query query) {
      setState(() {
        globals.partiesQuery = query;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: FirebaseAnimatedList (
        query: globals.partiesQuery,
        itemBuilder: (
            BuildContext context,
            DataSnapshot snapshot,
            Animation<double> animation,
            int index,
            ) {
          String key = snapshot.key;
          Map map = snapshot.value;
          String status = map['status'] as String;
          String name = map['name'] as String;
          String leader = map['leaderName'] as String;
          int cPlayers = map['cPlayers'] as int;
          int mPlayers = map['mPlayers'] as int;
          bool locked = map['locked'] as bool;
          Icon leadingIcon;
          try {
            if (cPlayers >= mPlayers) {
              leadingIcon =
                  Icon(MdiIcons.accountRemoveOutline, color: Colors.red);
            } else if (locked) {
              leadingIcon =
                  Icon(MdiIcons.lockOutline, color: Colors.orangeAccent);
            } else {
              leadingIcon = Icon(MdiIcons.lockOpenOutline, color: Colors.green);
            }
            if (status == "open") {
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
                    trailing: Text(
                      cPlayers.toString() + "/" + mPlayers.toString(),
                      textScaleFactor: 1.5,),
                    onTap: () {
                      if (cPlayers < mPlayers) {
                        if (!locked) {
                          GameDatabase.joinParty(key, globals.user, false);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>
                                JoinedPartyScreen(uid: key)),
                          );
                        } else {
                          UITools.showBasicPopup(
                              context, "Unable to join party",
                              "Yeah, sorry. This party is locked. We haven't really programmed anything for locked parties yet, so you just can't join this one. (If it makes you feel better, literally no one can join)");
                        }
                      } else {
                        UITools.showBasicPopup(context, "Unable to join party",
                            "Yeah, sorry. This party is already full. Please wait until someone leaves it. Or, you know, you could just join a different party.");
                      }
                    },
                  ),
                  new Divider(
                    height: 2.0,
                  ),
                ],
              );
            } else {
              return Container(width: 0, height: 0,);
            }
          } catch (e) {
            return Container(width: 0, height: 0,);
          }
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.add),
        label: Text("Create Party"),
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

  void _lockedChanged(bool value) => setState(() => locked = value);
  bool locked = false;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text('Create a new party'),
      contentPadding: EdgeInsets.all(30),

      children: <Widget>[
        // Party name
        TextFormField(
          controller: partyName,
          maxLength: 16,
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
          maxLength: 3,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            icon: Icon(Icons.person),
            hintText: 'Maximum number of players',
            labelText: 'Maximum number of players',
            hintStyle: TextStyle(fontSize: 12),
            labelStyle: TextStyle(fontSize: 12),

          ),
        ),

        // locked

        /*Row(
          children: <Widget>[
            Checkbox(value: locked, onChanged: _lockedChanged),
            Text("Lock Party"),
          ],
        ),*/

        Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Theme:"),
            ),
            ThemeSelector(),
          ],
        ),

        // Submit button
        RaisedButton(
            child: Text('Create'),
            onPressed: () {
              if (int.parse(maxNumPlayers.text) > 1) {
                GameDatabase.createParty(partyName.text, int.parse(maxNumPlayers.text), globals.user.uid, globals.user.displayName, locked, globals.themeDropdownValue.toLowerCase()).then((String key) {
                  GameDatabase.joinParty(key, globals.user, true);
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => JoinedPartyScreen(uid: key)),
                  );
                });
              }
            }
        ),

      ],

    );
  }
}

class ThemeSelector extends StatefulWidget {
  @override
  _ThemeSelectorState createState() => _ThemeSelectorState();
}

class _ThemeSelectorState extends State<ThemeSelector> {

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  @override
  void initState() {

    GameDatabase.getAllThemes().then((List<String> themes) {
      setState(() {
        globals.themeDropdownList = [];
        themes.forEach((String theme) {
          globals.themeDropdownList.add(DropdownMenuItem<String>(child: Text(capitalize(theme)), value: theme));
        });
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {


    print("THEMELIST: " + globals.themeDropdownList[0].child.toString());
    print("THEIR THING: " + <String>['One', 'Two', 'Free', 'Four'].map<DropdownMenuItem<String>>((String value) {return DropdownMenuItem<String>(value: value, child: Text(value),);}).toList().toString());

    return DropdownButton<String> (
      value: globals.themeDropdownValue,
      onChanged: (String newValue) {
        setState(() {
          globals.themeDropdownValue = newValue;
        });
      },
      items: globals.themeDropdownList.toList(),
    );
  }
}