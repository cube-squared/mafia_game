import 'dart:math';

import 'game_database.dart';

class Game2 {
  static Future<void> assignRoles(String partyUID) async {
    List<String> players = await GameDatabase.getAllPlayers(partyUID);

    // assign mafia
    int numMafia = sqrt(players.length).floor();
    List<int> mafiaIndexes = new List<int>();
    Random rand = new Random();
    for (var i = 0; i < numMafia; i++) {
      int num = rand.nextInt(numMafia);
      GameDatabase.setPlayerAttribute(partyUID, players[num], "role", "mafia");
      mafiaIndexes.add(num);
    }

    // assign doctor
    int num = rand.nextInt(numMafia);
    while (mafiaIndexes.contains(num)) {
      num = rand.nextInt(players.length);
    }
    int doctorIndex = num;
    GameDatabase.setPlayerAttribute(partyUID, players[num], "role", "doctor");

    // everyone else gets innocent
    for (var i = 0; i < players.length; i++) {
      if (doctorIndex != i && !mafiaIndexes.contains(i)) {
        GameDatabase.setPlayerAttribute(partyUID, players[i], "role", "innocent");
      }
    }
  }

  static Future<void> processDay(String partyUID) async {
    print("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nPROCESSSING DAY");
    List<String> players = await GameDatabase.getAllPlayers(partyUID);
    List<int> totalVotes = new List<int>(players.length);
    for (int i = 0; i < players.length; i++) {
      totalVotes[i] = 0;
    }
    dynamic allData = await GameDatabase.getAllTheDataFromTheStinkingParty(partyUID);

    players.forEach((String playerUID) {
      List<dynamic> votes = allData["players"][playerUID]["vote"];
      if (votes != null) {
        votes.forEach((dynamic uid) {
          String uidStr = uid as String;
          totalVotes[players.indexOf(uidStr)]++;
        });
      }
    });

    int heDeadIndex = 0;
    int biggestVotes = 0;
    for (int i = 0; i < players.length; i++) {
      if (totalVotes[i] > biggestVotes) {
        heDeadIndex = i;
        biggestVotes = totalVotes[i];
      }
      GameDatabase.setPlayerAttribute(partyUID, players[i], "vote", null);
    }

      GameDatabase.setPlayerAttribute(
          partyUID, players[heDeadIndex], "alive", false);
    print("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
    print("Check 1");
    allData = await GameDatabase.getAllTheDataFromTheStinkingParty(partyUID);
    String win = "none";
    int numAlivePlayers = 0;
    players.forEach((String uid){
      print(uid);
      print(allData["players"][uid]["alive"]);
      if(allData["players"][uid]["alive"]){
        numAlivePlayers++;
      }
    });
    print("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
    print(numAlivePlayers);
    int numMafia = 0;
    players.forEach((String uid){
      if(allData["players"][uid]["alive"] && allData["players"][uid]["role"] == "mafia"){
        numMafia++;
      }
    });
    print("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
    print(numMafia);
    int numInnocent = 0;
    players.forEach((String uid){
      if((allData["players"][uid]["alive"] && allData["players"][uid]["role"] == "innocent") || (allData["players"][uid]["alive"] && allData["players"][uid]["role"] == "doctor")){
        numInnocent++;
      }
    });
    print("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
    print(numInnocent);
    if(numAlivePlayers == numInnocent){
      win = "innocentWin";
    }
    else if(numAlivePlayers == numMafia){
      win = "mafiaWin";
    }
    print("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
    print(win);
    if(win == "none") {
      GameDatabase.setPartyAttribute(partyUID, "daytime", false);
      GameDatabase.setNarration(partyUID, "execution",
          allData["players"][players[heDeadIndex]]["name"]);
      GameDatabase.setPartyStatus(partyUID, "ingame");
      GameDatabase.startCountdown(partyUID, 15, false);
    }
    else{
      GameDatabase.setPartyStatus(partyUID, win);
      if(win == "mafiaWin"){
        GameDatabase.setPartyAttribute(partyUID, "mafiaNarration", GameDatabase.getWinNarration("mafia", partyUID) );
      }
      else if(win == "innocentWin"){
        GameDatabase.setPartyAttribute(partyUID, "mafiaNarration", GameDatabase.getWinNarration("innocent", partyUID) );
      }
    }
  }


  static Future<void> processNight(String partyUID) async {
    List<String> players = await GameDatabase.getAllPlayers(partyUID);
    List<int> totalMafiaVotes = new List<int>(players.length);
    for (int i = 0; i < players.length; i++) {
      totalMafiaVotes[i] = 0;
    }
    String doctorVote = "";
    dynamic allData = await GameDatabase.getAllTheDataFromTheStinkingParty(partyUID);

    players.forEach((String playerUID) {
      List<dynamic> votes = allData["players"][playerUID]["vote"];
      if (votes != null) {
        String role = allData["players"][playerUID]["role"];
        if (role == "mafia") {
          votes.forEach((dynamic uid) {
            String uidStr = uid as String;
            totalMafiaVotes[players.indexOf(uidStr)]++;
          });
        } else if (role == "doctor") {
          doctorVote = votes[0];
        }
      }
    });

    int heDeadIndex = 0;
    int biggestVotes = 0;
    for (int i = 0; i < players.length; i++) {
      if (totalMafiaVotes[i] != null) {
        if (totalMafiaVotes[i] > biggestVotes) {
          heDeadIndex = i;
          biggestVotes = totalMafiaVotes[i];
        }
      }
      GameDatabase.setPlayerAttribute(partyUID, players[i], "vote", null);
    }
    print("HE DEAD"  + players[heDeadIndex].toString());
    print("doctor vote"  + doctorVote);

    if (players[heDeadIndex] != doctorVote) {
      GameDatabase.setPlayerAttribute(partyUID, players[heDeadIndex], "alive", false);
      GameDatabase.setNarration(partyUID, "murder",  allData["players"][players[heDeadIndex]]["name"]);
    } else {
      GameDatabase.setNarration(partyUID, "murder", "nobody");
    }
    print("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
    print("Check 1");
    allData = await GameDatabase.getAllTheDataFromTheStinkingParty(partyUID);
    String win = "none";
    int numAlivePlayers = 0;
    players.forEach((String uid){
      print(uid);
    print(allData["players"][uid]["alive"]);
      if(allData["players"][uid]["alive"]){
        numAlivePlayers++;
      }
    });
    print("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
    print(numAlivePlayers);
    int numMafia = 0;
    players.forEach((String uid){
      if(allData["players"][uid]["alive"] && allData["players"][uid]["role"] == "mafia"){
        numMafia++;
      }
    });
    print("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
    print(numMafia);
    int numInnocent = 0;
    players.forEach((String uid){
      if((allData["players"][uid]["alive"] && allData["players"][uid]["role"] == "innocent") || (allData["players"][uid]["alive"] && allData["players"][uid]["role"] == "doctor")){
        numInnocent++;
      }
    });
    print("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
    print(numInnocent);
    if(numAlivePlayers == numInnocent){
      win = "innocentWin";
    }
    else if(numAlivePlayers == numMafia){
      win = "mafiaWin";
    }
    print("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
    print(win);
    if(win == "none") {
      GameDatabase.setPartyAttribute(partyUID, "daytime", true);
      GameDatabase.setPartyAttribute(partyUID, "day", allData["day"] + 1);
      GameDatabase.setPartyStatus(partyUID, "ingame");
      GameDatabase.startCountdown(partyUID, 15, true);
    }
    else{
      GameDatabase.setPartyStatus(partyUID, win);
      if(win == "mafiaWin"){
        GameDatabase.setPartyAttribute(partyUID, "mafiaNarration", GameDatabase.getWinNarration("mafia", partyUID) );
      }
      else if(win == "innocentWin"){
        GameDatabase.setPartyAttribute(partyUID, "mafiaNarration", GameDatabase.getWinNarration("innocent", partyUID) );
      }
    }
  }

}