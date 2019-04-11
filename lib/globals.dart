import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

// MAIN APPLICATION
String appName = "Mafia Game";
String homeTitle = "The Mafia Game";

// USER ACCOUNT
bool isLoggedIn = false;
FirebaseUser user;

// SETTINGS
bool darkMode = false;
bool confirmOnPartyExit = true;

// PARTY QUERIES (for persistence)
Query partiesQuery;
Query chatQuery;