import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'globals.dart' as globals;
import 'user_database.dart';


class LoginScreen extends StatefulWidget {
  LoginScreen({Key key}) : super(key: key);


  @override
  _LoginScreenState createState() => _LoginScreenState();
}


class _LoginScreenState extends State<LoginScreen> {

  // for firebase/google signin
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser user;

  Future<FirebaseUser> _handleSignIn() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    user = await _auth.signInWithCredential(credential);
    print("signed in " + user.displayName);
    globals.user = user;
    globals.isLoggedIn = true;
    UserDatabase.createUser(user);
    Navigator.pop(context);
    return user;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login to Mafia"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Please select a login method:',
              textScaleFactor: 1.5,
            ),
            SignInButton(
              Buttons.Google,
              onPressed: () => _handleSignIn().then((FirebaseUser user) => print(user)).catchError((e) => print(e)),
            ),
          ],
        ),
      ),
    );
  }
}