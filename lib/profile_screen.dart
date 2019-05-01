import 'package:flutter/material.dart';
import 'globals.dart' as globals;

class ProfileScreen extends StatefulWidget {
  ProfileScreen({Key key, this.uid}) : super(key: key);

  final String uid;

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold (
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[

              CircleAvatar(
                backgroundImage: NetworkImage(globals.user.photoUrl),
                radius: 75,

              ),

              // Image.network(globals.user.photoUrl),

              Text(globals.user.displayName, textScaleFactor: 1.5,),
              Text(globals.user.email),
            ],
          ),
        ),
      )
    );
  }

}
