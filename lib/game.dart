library game_package;

import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'game_database.dart';




abstract class Player {
  static List<Player> votes = [];
  static List<Player> allThePlayers = [];
  static List<String> deadDudes = [];
  static List<Player> mafiaMembers = [];

  String uid; //so we know which player players are players in the playing.
  String team; //never changes
  String role; //never changes
  String name; //never changes
  /*

  bool status;
  bool saved;
  */

  //UPDATED FOR FIRE BASE

  //getters and setters duh
  void setTeam(String team, String id) {
    this.team = team;
    GameDatabase.setPlayerAttribute(Game.partyId, id, "team", team);
  }

  void setRole(String role, String id) {
    this.role = role;
    GameDatabase.setPlayerAttribute(Game.partyId, id, "role", role);
  }

  void setName(String name, String id) {
    this.name = name;
    GameDatabase.setPlayerAttribute(Game.partyId, id, "name", name);
  }

  void setAlive(bool alive, String id) {
    GameDatabase.setPlayerAttribute(Game.partyId, id, "alive", alive);
  }

  void setSaved(bool saved, String id) {
    GameDatabase.setPlayerAttribute(Game.partyId, id, "saved", saved);
  }


  String getTeam() {
    return team;
  }

  String getRole() {
    return role;
  }

  String getName() {
    return name;
  }
  //unnecessary
  Future<bool> getStatus(String id) {
    return GameDatabase.getPlayerAttribute(Game.partyId, id, "alive");
  }

  Future<bool> getSaved(String id) {
    return GameDatabase.getPlayerAttribute(Game.partyId, id, "saved");
  }



//toString
  void displayDetails() async {
    print("uid: " + uid);
    print("Name: " + getName());
    print("Role: " + getRole());
    print("Team: " + getTeam());
    if (await getStatus(uid)) {
      print("Status: Alive\n");
    } else {
      print("Status: Dead\n");
    }
  }

//F1X TH1S
  static void vote(String theVote) async {
    String name;
    for (int i = 0; i < Player.allThePlayers.length; i++) {
      name = Player.allThePlayers[i].getName();
      if (name.toLowerCase() == theVote.toLowerCase()) {
        Player.votes.add(Player.allThePlayers[i]);
      }
    }
  }
}

class Game {
  static bool isMafiaVoting;
  static bool sleepyTime;
  static bool winner = false;
  static String teamWinner;
  static bool isTie = false;
  static int numOfDoctors = 1; //make it so you can set this at the beginning of the game
  static int numOfPlayers; //change to get from database later
  static int numOfMafia = sqrt(numOfPlayers).floor();
  static int tieCount = 0;
  static String partyId;
  static String leaderUid;
  static String doctorUid;


  //Make this unBad - Pass a player, kill that player, change game info based on that.
  /*
  static void makePlayersDead() {
    for (int i = 0; i < Player.allThePlayers.length; i++) {
      if (Player.allThePlayers[i].getStatus()) {
        Player.allThePlayers[i].setSaved(false);
      } else {
        if (Player.allThePlayers[i].getRole() == 'Doctor') numOfDoctors--;
        if (Player.allThePlayers[i].getRole() == 'Mafia') {
          numOfMafia--;
          for (int j = 0; j < Player.mafiaMembers.length; j++) {
            if (Player.allThePlayers[i] == Player.mafiaMembers[j])
              Player.mafiaMembers.removeAt(j);
          }
        }
        Player.deadDudes.add(Player.allThePlayers[i].getName());
        Player.allThePlayers.removeAt(i);
      }
    }
  }

  */


  //UPDATED FOR FIRE BASE INTEGRATION v2

  static void makePlayersDead() async{
    for (int i = 0; i < Player.allThePlayers.length; i++) {
      if (await GameDatabase.getPlayerAttribute(Game.partyId, Player.allThePlayers[i].uid, "alive")) {
        Player.allThePlayers[i].setSaved(false, Player.allThePlayers[i].uid);
      } else {
        if (Player.allThePlayers[i].getRole() == 'Doctor') numOfDoctors--;
        if (Player.allThePlayers[i].getRole() == 'Mafia') {
          numOfMafia--;
          for (int j = 0; j < Player.mafiaMembers.length; j++) {
            if (Player.allThePlayers[i] == Player.mafiaMembers[j])
              Player.mafiaMembers.removeAt(j);
          }
        }
        Player.deadDudes.add(Player.allThePlayers[i].getName());
        Player.allThePlayers.removeAt(i);
      }
    }
  }


  //UPDATED FOR FIRE BASE INTEGRATION

  static void assignRoles(List<String> playerIdList) async {
    numOfPlayers = playerIdList.length;
    int mafiaAssigned = 0;
    int doctorsAssigned = 0;

    playerIdList.shuffle();

    for (int i = 0; i < numOfPlayers; i++) {
      if (mafiaAssigned < numOfMafia) {

        print("${playerIdList[i]} is now mafia. \n");
        new Mafia(playerIdList[i]);
        mafiaAssigned++;
        if ( await GameDatabase.getPlayerAttribute(Game.partyId, playerIdList[i], "leader") == true) {
          leaderUid = playerIdList[i];

        }
      } else if (doctorsAssigned < numOfDoctors) {
        print("${playerIdList[i]} is now a doctor. \n");
        new Doctor(playerIdList[i]);
        doctorsAssigned++;
        if ( await GameDatabase.getPlayerAttribute(Game.partyId, playerIdList[i], "leader") == true) {
          leaderUid = playerIdList[i];
        }
      } else {
        print("${playerIdList[i]} is now an innocent. \n");
        new Innocent(playerIdList[i]);
        if ( await GameDatabase.getPlayerAttribute(Game.partyId, playerIdList[i], "leader") == true) {
          leaderUid = playerIdList[i];
        }
      }
    }
  }

  //UPDATED FOR FIRE BASE
  //Make this return a boolean, and then end the game based on that.
  static void checkWin() async {
    int counter = 0;
    for (int i = 0; i < Player.allThePlayers.length; i++) {
      if (Player.allThePlayers[i].getRole == 'Mafia') {
        counter++;
      }
    }
    if (counter == Player.allThePlayers.length) {
      String name = "Jean Claude Van Damme";
      GameDatabase.setNarration(Game.partyId, "win", name);
      winner = true;
      teamWinner = 'Mafia';
    } else if (counter == 0) {
      String name = "Jean Claude Van Damme";
      GameDatabase.setNarration(Game.partyId, "win", name);
      winner = true;
      teamWinner = 'Towns People';
    }
  }











  static void dayPhase() async {
    GameDatabase.setPartyAttribute(Game.partyId, 'daytime', true);
    makePlayersDead();
    stdout.writeln("Wakey wakey!");  //change to narration
    //Who died?
    sleepyTime = false;

    //DONT FUCK WITH ME I HAVE THE POWER OF GOD AND ANIME ON MY SIDE
    String name = "Jean Claude Van Damme";
    GameDatabase.setNarration(Game.partyId, "execution", name);
    //EUGGGGGGGGGGHAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA

    Player.deadDudes.clear();
    checkWin();
//oh people talk Chat();

//Vote for lynching
    isMafiaVoting = false;
    if (winner == false) {
      stdout.writeln("Whose ready for a town hanging?");
      Mafia.killPlayer(
          await calculateVote(Player.allThePlayers, Player.allThePlayers, "Innocent"));
      makePlayersDead();
      for (int i = 0; i < Player.deadDudes.length; i++) {
        stdout.writeln("AWE MAN " + Player.deadDudes[i] + " died");
      }
      Player.deadDudes.clear();
      for (int i = 0; i < Player.allThePlayers.length; i++) {
        print(Player.allThePlayers[i].getName());
      }
      checkWin();
    }
  }













  static void nightPhase() async {
    GameDatabase.setPartyAttribute(Game.partyId, 'daytime', false);
    sleepyTime = true;
    stdout.writeln("night night");
    String name = "Jean Claude Van Damme";
    GameDatabase.setNarration(Game.partyId, "murder", name);
//Doctor Bit                                                                    // Change once voting card is done
    /*for (int i = 0; i < numOfDoctors; i++) {
      stdout.writeln("Doctor ${i + 1} choose who to save.");
      String savedDude = stdin.readLineSync();
      Doctor.savePlayer(makeStringIntoPerson(savedDude));


//Mafia Bit
    isMafiaVoting = true;
    stdout.writeln("Hows it goin dude or dudette mafia! Vote for who to kill!");
    Mafia.killPlayer(calculateVote(Player.allThePlayers, Player.mafiaMembers));
    }*/


    // real doctor bit whos up
    print("part1");

    List<Player> s = await getVotes("doctor"); //gets list of who the doctor voted for
    Doctor.savePlayer(s[0]);  //only saves the first person in the list but it should only have one person in it anyway so who cares tbh ngl

    // real mafia bit whos up lmao its the mafia rip in peace
    //so i need to get the player(s) that the mafia chooses to die first
    //then after they have been flagged, during the loading phase it needs to kill that player
    //killPlayer just sets their status to dead, doesnt actually kill them yet
    //so the question right now is if killplayer will be able to check in if they had been saved since they kinda happen at the same time but as i type this i realize thats wrong so

    Player deadPerson = await calculateVote(Player.allThePlayers, Player.mafiaMembers, 'mafia');

    //print("before the d");
    //List<Player> d = await getVotes("mafia");
    //print("this is the print" + d[0].name);
    Mafia.killPlayer(deadPerson);


  }


  static Player makeUidIntoPerson(String theUid) {
    for (int i = 0; i < Player.allThePlayers.length; i++) {
      if (Player.allThePlayers[i].uid.toLowerCase() ==
          theUid.toLowerCase()) {
        return Player.allThePlayers[i];
      }
    }
    return null;
  }





  static Future<List<Player>> getVotes(String whoIsVoting) async {
    List<Player> votes = []; //what is being returned
    List<String> voteIds = []; // to store things from database
    List<String> vote;

    switch(whoIsVoting){
      case "doctor": {
        voteIds = await GameDatabase.getPlayerVote(Game.partyId, Game.doctorUid);
        for(int i = 0; i < voteIds.length; i++){
          votes.add(makeUidIntoPerson(voteIds[i]));
        }
        return votes;
      }
      break;
      case "mafia": {
        voteIds = await GameDatabase.getPlayerVote(Game.partyId, Player.mafiaMembers[0].uid);
        for(int i = 0; i < voteIds.length; i++){
          votes.add(makeUidIntoPerson(voteIds[i]));
        }
        return votes;
      }
      break;
      case "innocent": {
        for(int i = 0; i < Player.allThePlayers.length; i++){
          voteIds = []..addAll(await GameDatabase.getPlayerVote(Game.partyId, Player.allThePlayers[i].uid));
        }
        for(int i = 0; i < voteIds.length; i++){
          votes.add(makeUidIntoPerson(voteIds[i]));
        }
        return votes;
      }
      break;
    }

    return votes;


    /*
  } OLD CODE FOR CMDLINE VERSION
    List<Player> votes = [];

    for (int i = 0; i < votingPlayers.length; i++) {
      stdout.writeln(
          "Okay player number ${i + 1} vote! (type anything that isn't a players name to opt out of voting.):");
      String tempVote = stdin.readLineSync();
      if (makeStringIntoPerson(tempVote) == null) {
      } else {
        votes.add(makeStringIntoPerson(tempVote));
      }
    }
    return votes;
    */


  }












//Sort idea -> sort and count, compare counts to find highest
// While loop idea -> run through list over and over counting instances of each name, keep highest
  static Future<Player> calculateVote (
      List<Player> voteablePlayers, List<Player> votingPlayers, String whoIsVoting)  async{
    int counter = 0;
    int higher = 0;
    Player chosen;
    List<Player> highestVoted = [];
    List<Player> votes = [];


    if (tieCount == 3) {
      stdout.writeln("Ya'll a bunch a dummies, now nobody dies dummies.");
      tieCount = 0;
      return null;
    }

    votes = await getVotes(whoIsVoting);

    //sorts list of people who got voted
    votes.sort((a, b) => a.getName().compareTo(b.getName()));
    Player.allThePlayers.sort((a, b) => a.getName().compareTo(b.getName()));

    //Does a thing?
    for (int i = 0; i < voteablePlayers.length; i++) {
      for (int j = 0; j < votes.length; j++) {
        if (voteablePlayers[i].getName().toLowerCase() ==
            votes[j].getName().toLowerCase()) {
          counter++;
        }
        if (counter > higher) {
          higher = counter;
          highestVoted.clear();
          highestVoted.add(voteablePlayers[i]);
        } else if (counter == higher && counter != 0) {
          if (highestVoted.contains(voteablePlayers[i])) {
          } else {
            highestVoted.add(voteablePlayers[i]);
          }
        }
      }
      counter = 0;
    }
    if (highestVoted.length == 1) {
      chosen = highestVoted[0];
    } else if (highestVoted.length > 1) {
      tieCount++;
      return (calculateVote(voteablePlayers, votingPlayers, whoIsVoting));
    }

    if (whoIsVoting == 'mafia') {
      if (votes.length == 0) {
        return null;
      }
    } else if (votes.length < ((votingPlayers.length / 2) + 1).floor()) {
      return null;
      }


    //Ensures at least a majority vote for town hangings.
    if (!(higher < ((votingPlayers.length / 2).floor()))) {
      return chosen;
    }
  }








  //RUNNING THE GAME Methods

  //RUNS FIRST, creates allThePlayers list

  static void setUp(String partyUid, List<String> playerIdList) async{
    Game.partyId = partyUid;
    //GameDatabase.setPartyAttribute(Game.partyId, 'status', 'starting');
    assignRoles(playerIdList);
    String name;
    for(int i = 0; i < Player.allThePlayers.length; i++){
      name = await GameDatabase.getPlayerAttribute(Game.partyId, Player.allThePlayers[i].uid, "name");
      Player.allThePlayers[i].setName(name, Player.allThePlayers[i].uid);
    }
  }


  static void runGame(String partyUid, List<String> playerIdList) async {
    await setUp(partyUid, playerIdList);

    for (int i = 0; i < Player.allThePlayers.length; i++) {
      Player.allThePlayers[i].displayDetails();
    }


    GameDatabase.setNarration(partyUid, "intro", "");
    GameDatabase.setPartyStatus(partyUid, "ingame");



    /*
    print("\n\n\n\n\n\n\n\n\n\n\n\n\n\n Narration: \n\n");
    print( await GameDatabase.getNarration(Game.partyId, Player.allThePlayers.first.uid, "murder"));
    print("\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
    */
    //endGame();

  }

  static void nextDay(String partyUid, bool daytime, int day) {
    if(daytime){
    }
    else {
      nightPhase();
      GameDatabase.updateDay(day, partyUid);
      GameDatabase.setPartyStatus(partyUid, "ingame");
      //GameDatabase.startCountdown(partyUid, 25, false);
     // dayPhase();
    }


  }

  static void endGame() {
    GameDatabase.setPartyAttribute(Game.partyId, 'status', 'open');
    Player.allThePlayers.clear();
  }
}



class Mafia extends Player {

  //UPDATED FOR FIRE BASE INTEGRATION
  Mafia(String id) {
    /*
    team = 'Mafia';
    role = 'Mafia';
    this.name = name;
    status = true;
    saved = false;
    Player.mafiaMembers.add(this);
    Player.allThePlayers.add(this);
    */
    uid = id;
    GameDatabase.setPlayerAttribute(Game.partyId, uid, "team", "mafia");
    team = 'Mafia';
    GameDatabase.setPlayerAttribute(Game.partyId, uid, "role", "mafia");
    role = 'Mafia';
    GameDatabase.setPlayerAttribute(Game.partyId, uid, "alive", true);
    GameDatabase.setPlayerAttribute(Game.partyId, uid, "saved", false);
    Player.mafiaMembers.add(this);
    Player.allThePlayers.add(this);
  }

//For mafia at night to kill people
  static void killPlayer(Player player) {
    /*
    if(player == null) {
    } else {
      if (await player.getSaved(player.uid)) {
      } else {
        player.setStatus(false, player.uid);
      }
    }
   */

      player.setAlive(false, player.uid);
  }
}

class Doctor extends Player {
  static bool savedSelf;

  //UPDATED FOR FIRE BASE INTEGRATION

  Doctor(String id) {
    /*

    team = 'Town';
    role = 'Doctor';
    this.name = name;
    status = true;
    saved = false;
    Player.allThePlayers.add(this);
    */
    savedSelf = false;

    uid = id;
    Game.doctorUid = id;
    GameDatabase.setPlayerAttribute(Game.partyId, uid, "team", "town");
    team = 'Town';
    GameDatabase.setPlayerAttribute(Game.partyId, uid, "role", "doctor");
    role = 'Doctor';
    GameDatabase.setPlayerAttribute(Game.partyId, uid, "alive", true);
    GameDatabase.setPlayerAttribute(Game.partyId, uid, "saved", false);
    Player.allThePlayers.add(this);
  }

//for doctor at night to save person
  static void savePlayer(Player player){
    String docName;
    for (int i = 0; i < Player.allThePlayers.length; i++) {
      if (Player.allThePlayers[i].getRole() == "Doctor") {
        docName = Player.allThePlayers[i].getName();
      }
    }

    if(docName == player.getName()){
      if(savedSelf){
        //fails but idk how to relay that to the player
      }
      else {
        player.setSaved(true, player.uid);
      }
    }
    else {
      player.setSaved(true, player.uid);
    }
  }
}

//useless
class Innocent extends Player {
  Innocent(String id) {
    /*
    team = 'Town';
    role = 'Innocent';
    this.name = name;
    status = true;
    saved = false;
    Player.allThePlayers.add(this);
    */

    uid = id;
    GameDatabase.setPlayerAttribute(Game.partyId, uid, "team", "town");
    team = 'Town';
    GameDatabase.setPlayerAttribute(Game.partyId, uid, "role", "innocent");
    role = 'Innocent';
    GameDatabase.setPlayerAttribute(Game.partyId, uid, "alive", true);
    GameDatabase.setPlayerAttribute(Game.partyId, uid, "saved", false);
    Player.allThePlayers.add(this);
  }
}

main() async {                                                                  //very likely to fuck up
  /*
  List<String> listOfPlayers = [];
  listOfPlayers.add("Wyatt");
  listOfPlayers.add("Matthew");
  listOfPlayers.add("Talon");
  listOfPlayers.add("Elizabeth");
  listOfPlayers.add("Spencer");
  listOfPlayers.add("Daryl");
  listOfPlayers.add("Trey");
  listOfPlayers.add("Scott");
  */


 // Game.setUp(await GameDatabase.getAllPlayers(Game.partyId));


  //Game.setup

  /*
  //Runs literally the whole game until someone wins.
  while (!Game.winner) {
    Game.nightPhase();
    Game.dayPhase();
  }

  print('${Game.teamWinner} won the game!');

//Testing Thing
  for (int i = 0; i < Player.allThePlayers.length; i++)
    print(Player.allThePlayers[i].getName());
    */
}


//IDEAL MAIN FUNCTION
/*main(){
  assignRoles();
  while(noWinner){
    dayPhase();
    nighPhase();
  }
}
*/
