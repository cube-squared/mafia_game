import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

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

// THEME DROPDOWN (for persistence)
List<DropdownMenuItem<String>> themeDropdownList = [];
String themeDropdownValue = "original";

// TIMER
Timer timer;