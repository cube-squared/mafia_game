import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:intl/intl.dart';

class UserDatabase {

  static Future<void> createUser(FirebaseUser fbuser) async {
    bool alreadyInDB = await doesUserExist(fbuser);
    if (!alreadyInDB) {
      DatabaseReference ref = FirebaseDatabase.instance.reference();

      var user = <String, dynamic>{
        'name' : fbuser.displayName,
        'email' : fbuser.email,
        'nickname' : '',
        'created': _getDateNow(),
        'lastLogin' : fbuser.metadata.lastSignInTimestamp,
      };

      ref.child("users").child(fbuser.uid).set(user);
    } else {
      print(fbuser.displayName + " already exists in Realtime Database");
    }
  }

  static Future<bool> doesUserExist(FirebaseUser fbuser) async {
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    String name;
    ref.child('users').child(fbuser.uid).once().then((DataSnapshot snap) {
      name = snap.value["name"];
    });

    if (name == fbuser.displayName)
      return true;
    else
      return false;
  }

  static Future<void> saveNickname(String uid, String nickname) async {
    return FirebaseDatabase.instance
        .reference()
        .child("users")
        .child(uid)
        .child("nickname")
        .set(nickname);
  }

  static Future<void> getNickname(String uid) async {
    DatabaseReference ref = FirebaseDatabase.instance.reference();

    ref.child('users').child(uid).once().then((DataSnapshot snap) {
      var keys = snap.value.keys;
      var data = snap.value;
      for (var key in keys) {
        print(key + ": " + data[key].toString());
      }
    });
  }

  static Future<StreamSubscription<Event>> getNameStream(String mountainKey,
      void onData(String name)) async {
    String accountKey = await _getAccountKey();

    StreamSubscription<Event> subscription = FirebaseDatabase.instance
        .reference()
        .child("accounts")
        .child(accountKey)
        .child("mountains")
        .child(mountainKey)
        .child("name")
        .onValue
        .listen((Event event) {
      String name = event.snapshot.value as String;
      if (name == null) {
        name = "";
      }
      onData(name);
    });

    return subscription;
  }

  static Future<Query> queryMountains() async {
    String accountKey = await _getAccountKey();

    return FirebaseDatabase.instance
        .reference()
        .child("accounts")
        .child(accountKey)
        .child("mountains")
        .orderByChild("name");
  }
}

Future<String> _getAccountKey() async {
  return '12345678';
}

/// requires: intl: ^0.15.2
String _getDateNow() {
  var now = new DateTime.now();
  var formatter = new DateFormat('yyyy-MM-dd HH:mm:ss');
  return formatter.format(now);
}