import 'package:flutter/material.dart';
import 'globals.dart' as globals;
import 'home_screen.dart';

void main() => runApp(MyApp());

class AppBuilder extends StatefulWidget {
  final Function(BuildContext) builder;

  const AppBuilder(
      {Key key, this.builder})
      : super(key: key);

  @override
  AppBuilderState createState() => new AppBuilderState();

  static AppBuilderState of(BuildContext context) {
    return context.ancestorStateOfType(const TypeMatcher<AppBuilderState>());
  }
}

class AppBuilderState extends State<AppBuilder> {

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }

  void rebuild() {
    setState(() {});
  }
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBuilder(builder: (context) {
      ThemeData theme;
      if (globals.darkMode)
        theme = ThemeData.dark();
      else
        theme = ThemeData.light();
      return MaterialApp(
        title: globals.appName,
        theme: theme,
        home: HomeScreenTabbed(),//HomeScreen(title: globals.homeTitle),
      );
    });
  }
}

