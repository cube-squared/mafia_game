import 'package:flutter/material.dart';
import 'main.dart';
import 'globals.dart' as globals;

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
          ),
        ],
      ),
    );
  }

}
