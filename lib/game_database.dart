import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'game.dart';
import 'dart:math';

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

  static Future<String> createParty(String name, int maxPlayers, String leaderUID, String leaderName, bool locked, String theme) async {
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    var party = <String, dynamic>{
      'name' : name,
      'cPlayers' : 1,
      'mPlayers' : maxPlayers,
      'created': _getDateNow(),
      'leaderUID' : leaderUID,
      'leaderName' : leaderName,
      'locked' : locked,
      'status' : 'open',
      'theme' : theme,
      'daytime' : false,
      'day' : 0,
      'timer' : 0,
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
      'role' : "",
      'team' : "",
      'alive' : true,
      'saved' : false,
      'vote' : [],
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
      // mark party as deleted if last one leaves, then wait 3 seconds and delete it
      setPartyStatus(uid, "deleted");
      await new Future.delayed(const Duration(seconds: 3), () => "3");
      deleteParty(uid);
    }
  }

  static Future<String> getTheme(String partyUID) async {
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    return ref.child("parties").child(partyUID).child("theme").once().then((DataSnapshot snap) {
      return snap.value;
    });
  }

  static Future<String> getStatus(String partyUID) async {
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    return ref.child("parties").child(partyUID).child("status").once().then((DataSnapshot snap) {
      return snap.value;
    });
  }

  static Future<String> getNarration(String partyUID, String playerUID, String event) async{
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    String theme = await getTheme(partyUID);
    print("theme: " + theme);
    print ("event: " + event);
    switch (event){
      case "execution":{
        return ref.child("themes").child(theme).child("execution").child("1").once().then((DataSnapshot snap) {
          return snap.value.toString();
          });
        }
      break;
      case "intro":{
        String role = await getPlayerAttribute(partyUID, playerUID, "role");
        return ref.child("themes").child(theme).child("intro").child(role).once().then((DataSnapshot snap) {
          return snap.value.toString();
        });
      }
      break;
      case "murder":{
        var rng = new Random();
        String val = (rng.nextInt(3)+1).toString();
        return ref.child("themes").child(theme).child("murder").child(val).once().then((DataSnapshot snap) {
          return snap.value.toString();
        });
      }
      break;
      case "win":{
        String winner;
        if(Game.teamWinner == 'Mafia'){
          winner = 'mafia';
        } else if (Game.teamWinner == 'Towns People'){
          winner = 'innocent';
        } else {
          winner = 'YamessedupBUD!';
        }
        return ref.child("themes").child(theme).child("win").child(winner).once().then((DataSnapshot snap) {
          return snap.value.toString();
        });
      }
      break;
    }
    return "Yello";
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

  static Future<void> setPartyStatus(String uid, String status) async {
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    ref.child("parties").child(uid).child("status").set(status);
  }

  static Future<void> setPlayerStatus(String uid, FirebaseUser user, String status) async {
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    ref.child("parties").child(uid).child("players").child(user.uid).child("status").set(status);
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
        'leaderUID' : "",
        'chat' : [],
        'theme' : "original",
        'players' : [],
        'status' : 'open',
      };

      info['name'] = event.snapshot.value["name"];
      info['mPlayers'] = event.snapshot.value['mPlayers'];
      info['locked'] = event.snapshot.value['locked'];
      info['leaderName'] = event.snapshot.value['leaderName'];
      info['leaderUID'] = event.snapshot.value['leaderUID'];
      info['cPlayers'] = event.snapshot.value['players'].length;
      info['chat'] = event.snapshot.value['chat'];
      info['theme'] = event.snapshot.value['theme'];
      info['players'] = event.snapshot.value['players'];
      info['status'] = event.snapshot.value['status'];

      onData(info);
    });

    return subscription;

  }

  static Future<void> sendPartyChat(String uid, FirebaseUser user, String message) async {
    message = message.trim();
    if (message.isNotEmpty) {
      DatabaseReference ref = FirebaseDatabase.instance.reference();
      var chat = <String, dynamic>{
        'name' : user.displayName,
        'photoUrl' : user.photoUrl,
        'message' : message,
        'time' : DateTime.now().millisecondsSinceEpoch * -1,
      };
      ref.child("parties").child(uid).child("chat").push().set(chat);
    }
  }

  static Future<Query> queryPartyChat(String uid) async {
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    return ref
        .child("parties")
        .child(uid)
        .child("chat")
        .orderByChild("time");
  }

  static Future<List<String>> getAllThemes() async {
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    return ref.child("themes").once().then((DataSnapshot snap) {
      List<String> themes = new List<String>();
      snap.value.keys.toList().forEach((dynamic key) {
        String theme = key as String;
        themes.add(theme);
      });
      return themes;
    });
  }



  //  ------------------------- IN GAME FUNCTIONS -------------------------

  static Future<StreamSubscription<Event>> getGameInfoStream(String uid, void onData(Map<String, dynamic> map)) async {
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    StreamSubscription<Event> subscription = ref.child("parties").child(uid).onValue.listen((Event event) {
      var info = <String, dynamic> {
        'status' : 'open',
        'name' : 'Party',
        'cPlayers' : 0,
        'theme' : "original",
        'players' : [],
        'daytime': false,
        'day': 0,
        'timer' : 1000,
      };

      info['status'] = event.snapshot.value["status"];
      info['name'] = event.snapshot.value['name'];
      info['cPlayers'] = event.snapshot.value['cPlayers'];
      info['theme'] = event.snapshot.value['theme'];
      info['players'] = event.snapshot.value['players'];
      info['daytime'] = event.snapshot.value['daytime'];
      info['day'] = event.snapshot.value['day'];
      info['timer'] = event.snapshot.value['timer'];

      onData(info);
    });

    return subscription;
  }

  static Future<StreamSubscription<Event>> getAllPlayersNamesStream(String uid, void onData(List<Map<String, String>> map)) async {
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    StreamSubscription<Event> subscription = ref.child("parties").child(uid).child("players").onValue.listen((Event event) {
      var info = new List<Map<String, String>>();

      event.snapshot.value.forEach((key, playerData) => info.add(<String, String> {'name' : playerData["name"], 'uid' : key}));

      onData(info);
    });

    return subscription;
  }

  static Future<void> setPlayerAttribute(String partyUID, String playerUID, String attribute, dynamic value) async {
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    ref.child("parties").child(partyUID).child("players").child(playerUID).child(attribute).set(value);
  }

  static Future<dynamic> getPlayerAttribute(String partyUID, String playerUID, String attribute) async {
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    dynamic data = await ref.child('parties').child(partyUID).child("players").child(playerUID).once().then((DataSnapshot snap) {
      return snap.value[attribute];
    });

    return data;
  }

  static Future<dynamic> getRoleDescription(String role) async {
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    dynamic data = await ref.child('roles').once().then((DataSnapshot snap) {
      return snap.value[role];
    });

    return data;
  }

  static Future<void> setPartyAttribute(String partyUID, String attribute, dynamic value) async {
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    ref.child("parties").child(partyUID).child(attribute).set(value);
  }

  static Future<List<String>> getAllPlayers(String partyUID) async {
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    List<String> data = await ref.child('parties').child(partyUID).child("players").once().then((DataSnapshot snap) {
      List<String> players = new List<String>();
      snap.value.keys.forEach((player) {
        players.add(player);
      });
      return players;
    });
    return data;
  }

  static Future<List<String>> getPlayerVote(String partyUID, String playerUID) async {
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    List<String> data = await ref.child('parties').child(partyUID).child("players").child(playerUID).child("vote").once().then((DataSnapshot snap) {
      List<String> votes = new List<String>();
      snap.value.forEach((uid) {
        votes.add(uid);
      });
      return votes;
    });
    return data;
  }

  static Future<bool> startCountdown(String partyUID, int lengthInSeconds) async {
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    ref.child("parties").child(partyUID).child("timer").set(lengthInSeconds);
    int remaining = lengthInSeconds;

    new Timer.periodic(const Duration(seconds: 1), (Timer t) {
      remaining--;
      ref.child("parties").child(partyUID).child("timer").set(remaining);
      if (remaining <= 0) {
        t.cancel();
        ref.child("parties").child(partyUID).child("status").set("loading");
      }
    });

    return true;
  }

}

String _getDateNow() {
  return DateTime.now().millisecondsSinceEpoch.toString();
}