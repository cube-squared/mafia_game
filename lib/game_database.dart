import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      'status' : "notready",
    };
    ref.child("parties").child(uid).child("players").child(user.uid).set(player);

    // update current num players
    int numPlayers = await getPartyNumPlayers(uid);
    ref.child("parties").child(uid).child("cPlayers").set(numPlayers);
  }

  static Future<void> leaveParty(String uid, FirebaseUser user) async {
    DatabaseReference ref = FirebaseDatabase.instance.reference();

    // get num players
    int numPlayers = await getPartyNumPlayers(uid);

    // if people left, update num players and delete player entry
    if (numPlayers > 1) {
      ref.child("parties").child(uid).child("players").child(user.uid).remove();
      numPlayers = await getPartyNumPlayers(uid);
      ref.child("parties").child(uid).child("cPlayers").set(numPlayers);
    } else {
      // remove party if last one leaves
      deleteParty(uid);
    }
  }

  static Future<int> getPartyNumPlayers(String uid) async {
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    int _numPlayers = await ref.child('parties').child(uid).once().then((DataSnapshot snap) {
      if (snap.value['players'] == null) {
        return 0;
      } else {
        return snap.value['players'].length;
      }
    });

    return _numPlayers;
  }

  static Future<void> deleteParty(String uid) async {
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    ref.child("parties").child(uid).remove();
  }

  static Future<void> setStatus(String uid, FirebaseUser user, String status) async {
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    ref.child("parties").child(uid).child("players").child(user.uid).child("status").set(status);
  }

  static Future<Map<String, dynamic>> getPartyInfo(String uid) async {
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    var info = <String, dynamic> {
      'name' : "Party Name",
      'cPlayers' : 0,
      'mPlayers' : 0,
      'locked' : false,
      'leaderName' : "Notch",
    };

    ref.child('parties').child(uid).once().then((DataSnapshot snap) {
      info['name'] = snap.value["name"];
      info['mPlayers'] = snap.value['mPlayers'];
      info['locked'] = snap.value['locked'];
      info['leaderName'] = snap.value['leaderName'];
      info['cPlayers'] = snap.value['players'].length;
    });

    return info;
  }

  static Future<StreamSubscription<Event>> getPartyInfoStream(String uid, void onData(Map<String, dynamic> map)) async {
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    StreamSubscription<Event> subscription = ref.child("parties").child(uid).onValue.listen((Event event) {
      var info = <String, dynamic> {
        'name' : "Party Name",
        'cPlayers' : 0,
        'mPlayers' : 0,
        'locked' : false,
        'leaderName' : "Notch",
      };

      info['name'] = event.snapshot.value["name"];
      info['mPlayers'] = event.snapshot.value['mPlayers'];
      info['locked'] = event.snapshot.value['locked'];
      info['leaderName'] = event.snapshot.value['leaderName'];
      info['cPlayers'] = event.snapshot.value['players'].length;

      onData(info);
    });

    return subscription;

  }



}

String _getDateNow() {
  var now = new DateTime.now();
  var formatter = new DateFormat('yyyy-MM-dd HH:mm:ss');
  return formatter.format(now);
}