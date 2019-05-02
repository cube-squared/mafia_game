library game_package;

import 'dart:io';
import 'dart:math';

abstract class Player {
  static List<Player> votes = [];
  static List<Player> allThePlayers = [];
  static List<String> deadDudes = [];
  static List<Player> mafiaMembers = [];

  String uid; //so we know which player players are players in the playing.
  String team;
  String role;
  String name;
  bool status;
  bool saved;

  //getters and setters duh
  void setTeam(String team) {
    this.team = team;
  }

  void setRole(String role) {
    this.role = role;
  }

  void setName(String name) {
    this.name = name;
  }

  void setStatus(bool status) {
    this.status = status;
  }

  void setSaved(bool saved) {
    this.saved = saved;
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

  bool getStatus() {
    return status;
  }

  bool getSaved() {
    return saved;
  }

//toString (shhh)
  void displayDetails() {
    print("uid: " + uid);
    print("Name: " + name);
    print("Role: " + role);
    print("Team: " + team);
    if (status) {
      print("Status: Alive\n");
    } else {
      print("Status: Dead\n");
    }
  }

//gets each players vote.
  static void vote(String theVote) {
    for (int i = 0; i < Player.allThePlayers.length; i++) {
      if (Player.allThePlayers[i].getName().toLowerCase() ==
          theVote.toLowerCase()) {
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

  //Make this unBad - Pass a player, kill that player, change game info based on that.
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

  static void assignRoles(List<String> playerList) {
    numOfPlayers = playerList.length;
    int mafiaAssigned = 0;
    int doctorsAssigned = 0;

    playerList.shuffle();

    for (int i = 0; i < numOfPlayers; i++) {
      if (mafiaAssigned < numOfMafia) {
        print("${playerList[i]} is now mafia. \n");
        new Mafia(playerList[i]);
        mafiaAssigned++;
      } else if (doctorsAssigned < numOfDoctors) {
        print("${playerList[i]} is now a doctor. \n");
        new Doctor(playerList[i]);
        doctorsAssigned++;
      } else {
        print("${playerList[i]} is now an innocent. \n");
        new Innocent(playerList[i]);
      }
    }
  }

  //Make this return a boolean, and then end the game based on that.
  static void checkWin() {
    int counter = 0;
    for (int i = 0; i < Player.allThePlayers.length; i++) {
      if (Player.allThePlayers[i].getRole() == 'Mafia') {
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
    stdout.writeln("Wakey wakey!");
    //Who died?
    sleepyTime = false;
    for (int i = 0; i < Player.deadDudes.length; i++) {
      stdout.writeln("AWE MAN " + Player.deadDudes[i] + " died");
    }
    Player.deadDudes.clear();
    checkWin();
//oh people talk Chat();

//Vote for lynchin
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
//Doctor Bit
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
}

class Mafia extends Player {
  Mafia(String name) {
    team = 'Mafia';
    role = 'Mafia';
    this.name = name;
    status = true;
    saved = false;
    Player.mafiaMembers.add(this);
    Player.allThePlayers.add(this);
  }

//For mafia at night to kill people
  static void killPlayer(Player player) {
    if (player == null) {
    } else {
      if (player.saved) {
      } else {
        player.setStatus(false);
      }
    }
  }
}

class Doctor extends Player {
  static bool savedSelf;

  Doctor(String name) {
    savedSelf = false;
    team = 'Town';
    role = 'Doctor';
    this.name = name;
    status = true;
    saved = false;
    Player.allThePlayers.add(this);
  }

//for doctor at night to save person
  static void savePlayer(Player player) {
    String docName;
    for (int i = 0; i < Player.allThePlayers.length; i++) {
      if (Player.allThePlayers[i].getRole() == "Doctor") {
        docName = Player.allThePlayers[i].getName();
      }
    }
    if (player == null) {
    } else {
      if (!savedSelf) {
        if (player.saved == false) {
          player.saved = true;
        }
        if (player.getName() == docName) {
          savedSelf = true;
        }
      } else {
        if (player.getName() == docName) {
        } else {
          if (player.saved == false) {
            player.saved = true;
          }
        }
      }
    }
  }
}

//useless
class Innocent extends Player {
  Innocent(String name) {
    team = 'Town';
    role = 'Innocent';
    this.name = name;
    status = true;
    saved = false;
    Player.allThePlayers.add(this);
  }
}

main() {
  List<String> listOfPlayers = [];
  listOfPlayers.add("Wyatt");
  listOfPlayers.add("Matthew");
  listOfPlayers.add("Talon");
  listOfPlayers.add("Elizabeth");
  listOfPlayers.add("Spencer");
  listOfPlayers.add("Daryl");
  listOfPlayers.add("Trey");
  listOfPlayers.add("Scott");
  Game.assignRoles(listOfPlayers);

  //Runs literally the whole game until someone wins.
  while (!Game.winner) {
    Game.nightPhase();
    Game.dayPhase();
  }
  print('${Game.teamWinner} won the game!');

//Testing Thing
  for (int i = 0; i < Player.allThePlayers.length; i++)
    print(Player.allThePlayers[i].getName());
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
