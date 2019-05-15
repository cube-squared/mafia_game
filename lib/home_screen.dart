import 'package:flutter/material.dart';
import 'party_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'globals.dart' as globals;
import 'main.dart';
import 'user_database.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'game_database.dart';


class HomeScreenTabbed extends StatefulWidget {

  @override
  _HomeScreenTabbedState createState() => _HomeScreenTabbedState();

}

class _HomeScreenTabbedState extends State<HomeScreenTabbed> {

  @override
  void initState() {
    if (globals.user != null)
      UserDatabase.getSettings(globals.user.uid, context);
    super.initState();
  }

  // to logout
  void _logout() {
    globals.isLoggedIn = false;
    globals.user = null;
    globals.darkMode = false;
    globals.confirmOnPartyExit = true;
    AppBuilder.of(context).rebuild();
  }

  // Add screen widgets to the 'tab' widget list.
  final List<Widget> tabs = [
    PartyScreen(),
    ProfileScreen(),
    SettingsScreen(),

  ];

  @override
  Widget build(BuildContext context) {

    if (globals.isLoggedIn) {
      return DefaultTabController(
        length: tabs.length,
        child: Scaffold(
          appBar: AppBar(
            title: Text(globals.homeTitle),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.exit_to_app),
                onPressed: () => _logout(),
              ),
            ],

            bottom: TabBar(
              tabs: <Widget>[
                new Tab(
                  icon: Icon(MdiIcons.accountMultiple),
                  text: "Parties",
                ),
                new Tab(
                  icon: Icon(MdiIcons.account),
                  text: "Profile",
                ),
                new Tab(
                  icon: Icon(MdiIcons.settings),
                  text: "Settings",
                ),
              ],
            ),
          ),

          body: TabBarView(
              children: tabs
          ),

        ),
      );
    } else {
      return LoginScreen();
    }


  }
}
