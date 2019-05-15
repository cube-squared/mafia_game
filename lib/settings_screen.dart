import 'package:flutter/material.dart';
import 'main.dart';
import 'globals.dart' as globals;
import 'user_database.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({Key key, this.uid}) : super(key: key);

  final String uid;

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  // for light/dark mode
  void _setDarkMode(bool value) {
    if (value) {
      globals.darkMode = true;
    } else {
      globals.darkMode = false;
    }
    AppBuilder.of(context).rebuild();
    UserDatabase.setSetting(globals.user.uid, "darkMode", value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold (
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text("Dark Mode"),
            subtitle: Text("For those who like their eyes"),
            trailing: Switch(
              value: globals.darkMode,
              onChanged: (bool value) {
                setState(() {
                  _setDarkMode(value);
                });
              }
            ),
            onTap: () {
              setState(() {
                if (globals.darkMode)
                  _setDarkMode(false);
                else
                  _setDarkMode(true);
              });
            },
          ),
          ListTile(
            title: Text("Confirm Party Exit"),
            subtitle: Text("We'll make sure you actually want to leave your friends"),
            trailing: Switch(
                value: globals.confirmOnPartyExit,
                onChanged: (bool value) {
                  setState(() {
                    globals.confirmOnPartyExit = value;
                  });
                  UserDatabase.setSetting(globals.user.uid, "confirmOnPartyExit", value);
                }
            ),
            onTap: () {
              setState(() {
                if (globals.confirmOnPartyExit) {
                  globals.confirmOnPartyExit = false;
                  UserDatabase.setSetting(globals.user.uid, "confirmOnPartyExit", false);
                } else {
                  globals.confirmOnPartyExit = true;
                  UserDatabase.setSetting(globals.user.uid, "confirmOnPartyExit", true);
                }
              });
            },
          ),
        ],
      ),
    );
  }

}
