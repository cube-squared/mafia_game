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

  void setStatus(bool status, String id) {
    GameDatabase.setPlayerAttribute(Game.partyId, id, "alive", status);
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
  static String partyId = "-Lew9d89Ycz74hh798Lo";
  static String leaderUid;


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
      winner = true;
      teamWinner = 'Mafia';
    } else if (counter == 0) {
      winner = true;
      teamWinner = 'Towns People';
    }
  }











  static void dayPhase() {
    makePlayersDead();
    stdout.writeln("Wakey wakey!");  //change to narration
    //Who died?
    sleepyTime = false;
    for (int i = 0; i < Player.deadDudes.length; i++) {
      stdout.writeln("AWE MAN " + Player.deadDudes[i] + " died");
    }
    Player.deadDudes.clear();
    checkWin();
//oh people talk Chat();

//Vote for lynching
    isMafiaVoting = false;
    if (winner == false) {
      stdout.writeln("Whose ready for a town hanging?");
      Mafia.killPlayer(
          calculateVote(Player.allThePlayers, Player.allThePlayers));
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













  static void nightPhase() {
    sleepyTime = true;
    stdout.writeln("night night");
//Doctor Bit                                                                    // Change once voting card is done
    for (int i = 0; i < numOfDoctors; i++) {
      stdout.writeln("Doctor ${i + 1} choose who to save.");
      String savedDude = stdin.readLineSync();
      Doctor.savePlayer(makeStringIntoPerson(savedDude));
    }

//Mafia Bit
    isMafiaVoting = true;
    stdout.writeln("Hows it goin dude or dudette mafia! Vote for who to kill!");
    Mafia.killPlayer(calculateVote(Player.allThePlayers, Player.mafiaMembers));
  }

  static Player makeStringIntoPerson(String theString) {
    for (int i = 0; i < Player.allThePlayers.length; i++) {
      if (Player.allThePlayers[i].getName().toLowerCase() ==
          theString.toLowerCase()) {
        return Player.allThePlayers[i];
      }
    }
    return null;
  }





  // BASICALLY IS UNNECESSARY, REMAKE ONCE VOTING CARD ON UI IS DONE
  static List<Player> getVotes(List<Player> votingPlayers) {
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
  }












//Sort idea -> sort and count, compare counts to find highest
// While loop idea -> run through list over and over counting instances of each name, keep highest
  static Player calculateVote(
      List<Player> voteablePlayers, List<Player> votingPlayers) {
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

    votes = getVotes(votingPlayers);

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
      return (calculateVote(highestVoted, votingPlayers));
    }

    if (isMafiaVoting) {
      if (votes.length == 0) {
        return null;
      }
    } else {
      if (votes.length < ((votingPlayers.length / 2) + 1).floor()) {
        return null;
      }
    }

    //Ensures at least a majority vote for town hangings.
    if (!(higher < ((votingPlayers.length / 2).floor()))) {
      return chosen;
    }
  }








  //RUNNING THE GAME Methods

  //RUNS FIRST, creates allThePlayers list

  static void setUp(List<String> playerIdList) async{
    assignRoles(playerIdList);
    String name;
    for(int i = 0; i < Player.allThePlayers.length; i++){
      name = await GameDatabase.getPlayerAttribute(Game.partyId, Player.allThePlayers[i].uid, "name");
      Player.allThePlayers[i].setName(name, Player.allThePlayers[i].uid);
    }
  }

  static void runGame() async {
    for (int i = 0; i < Player.allThePlayers.length; i++) {
      Player.allThePlayers[i].displayDetails();
    }
    print( await GameDatabase.getNarration(Game.partyId, Player.allThePlayers[1].uid, "murder"));
    endGame();

  }

  static void endGame() {
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
  static void killPlayer(Player player) async{
    if(player == null) {
    } else {
      if (await player.getSaved(player.uid)) {
      } else {
        player.setStatus(false, player.uid);
      }
    }
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
    GameDatabase.setPlayerAttribute(Game.partyId, uid, "team", "town");
    team = 'Town';
    GameDatabase.setPlayerAttribute(Game.partyId, uid, "role", "doctor");
    role = 'Doctor';
    GameDatabase.setPlayerAttribute(Game.partyId, uid, "alive", true);
    GameDatabase.setPlayerAttribute(Game.partyId, uid, "saved", false);
    Player.allThePlayers.add(this);
  }

//for doctor at night to save person
  static void savePlayer(Player player) async{
    String docName;
    for (int i = 0; i < Player.allThePlayers.length; i++) {
      if (Player.allThePlayers[i].getRole() == "Doctor") {
        docName = Player.allThePlayers[i].getName();
      }
    }
    if (player == null) {
    } else {
      if (!savedSelf) {
        if (await player.getSaved(player.uid) == false) {
           player.setSaved(true, player.uid);
        }
        if (player.getName() == docName) {
          savedSelf = true;
        }
      } else {
        if (player.getName() == docName) {
        } else {
          if (await player.getSaved(player.uid) == false) {
            player.setSaved(true, player.uid);
          }
        }
      }
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


  Game.setUp(await GameDatabase.getAllPlayers(Game.partyId));


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
