import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:intl/intl.dart';

class GameDatabase {

  static Future<Query> queryParties() async {
    return FirebaseDatabase.instance
        .reference()
        .child("parties")
        .orderByChild("cPlayers");
  }

  static Future<Query> queryParty(String uid) async {
    return FirebaseDatabase.instance
        .reference()
        .child("parties")
        .child(uid)
        .child("players")
        .orderByChild("name");
  }

  static Future<String> createParty(String name, int maxPlayers, String leaderUID, String leaderName, bool locked) async {
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    var party = <String, dynamic>{
      'name' : name,
      'cPlayers' : 1,
      'mPlayers' : maxPlayers,
      'created': _getDateNow(),
      'leaderUID' : leaderUID,
      'leaderName' : leaderName,
      'locked' : locked,
    };

    DatabaseReference dbParty = ref.child("parties").push();
    dbParty.set(party);
    return dbParty.key;
  }

  static Future<void> joinParty(String uid, FirebaseUser user, bool leader) async {
    // add player to list in party
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    var player = <String, dynamic>{
      'name' : user.displayName,
      'photoUrl' : user.photoUrl,
      'leader' : leader,
    };
    ref.child("parties").child(uid).child("players").child(user.uid).set(player);

    // get number of players in the lobby
    //int numPlayers;
    //ref.child("parties").child(uid).once().then((DataSnapshot snap) => {print("length = " + snap.value.length)});
    //print("numPlayers = " + numPlayers.toString());
    //ref.child("parties").child(uid).update(<String, int>{'cPlayers' : numPlayers});
  }

  static Future<void> leaveParty(String uid, FirebaseUser user) async {
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    ref.child("parties").child(uid).child("players").child(user.uid).remove();
  }

  static Future<int> getPartyNumPlayers(String uid) async {
    DatabaseReference ref = FirebaseDatabase.instance.reference();

  }



}

String _getDateNow() {
  var now = new DateTime.now();
  var formatter = new DateFormat('yyyy-MM-dd HH:mm:ss');
  return formatter.format(now);
}