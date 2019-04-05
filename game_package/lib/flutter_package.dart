library game_package;

import 'dart:io';

abstract class Player {
  static List<Player> votes = [];
  static List<Player> allThePlayers = [];
  static List<String> deadDudes = [];
  static List<Player> mafiaMembers = [];

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
    print("Name: " + name);
    print("Role: " + role);
    print("Team: " + team);
    if (status) {
      print("Status: Alive");
    } else {
      print("Status: Dead");
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
  static bool sleepyTime;
  static bool winner = false;
  static String teamWinner;
  static bool isTie = false;
  static int numOfDoctors = 0;

  static void makePlayersDead() {
    for (int i = 0; i < Player.allThePlayers.length; i++) {
      if (Player.allThePlayers[i].getStatus()) {
        Player.allThePlayers[i].setSaved(false);
      } else {
        if(Player.allThePlayers[i].getRole() == 'Doctor')
          numOfDoctors--;
        Player.deadDudes.add(Player.allThePlayers[i].getName());
        Player.allThePlayers.removeAt(i);
      }
    }
  }

  static void assignRoles() {}

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
    if (winner == false) {
      stdout.writeln("Whose ready for a town hanging?");
      Mafia.killPlayer(calculateVote(Player.allThePlayers, Player.allThePlayers));
      makePlayersDead();
      for(int i = 0; i < Player.allThePlayers.length; i++){
        print(Player.allThePlayers[i].getName());
      }
      checkWin();
    }
  }

  static void nightPhase() {
    sleepyTime = true;
    stdout.writeln("night night");
//Doctor Bit
    for(int i = 0; i < numOfDoctors; i++) {
      stdout.writeln("Doctor ${i+1} choose who to save.");
      String savedDude = stdin.readLineSync();
      Doctor.savePlayer(makeStringIntoPerson(savedDude));
    }

//Mafia Bit
    stdout.writeln("Hows it goin dude or dudette mafia! Vote for who to kill!");
      Mafia.killPlayer(calculateVote(Player.allThePlayers, Player.mafiaMembers));
      makePlayersDead();
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

  static List<Player> getVotes(List<Player> votingPlayers){
    List<Player> votes = [];

    for (int i = 0; i < votingPlayers.length; i++) {
      stdout.writeln("Okay player number ${i + 1} vote! (type anything that isn't a players name to opt out of voting.):");
      votes.add(makeStringIntoPerson(stdin.readLineSync()));
    }
    return votes;
  }

//Sort idea -> sort and count, compare counts to find highest
// While loop idea -> run through list over and over counting instances of each name, keep highest
  static Player calculateVote(List<Player> voteablePlayers, List<Player> votingPlayers) {
    int counter = 0;
    int higher = 0;
    Player chosen;
    List<Player> highestVoted = [];
    List<Player> votes = [];

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
        if(highestVoted.contains(voteablePlayers[i])){
          if (counter > higher)
          higher = counter;
        } else {
          if (counter > higher) {
            higher = counter;
            highestVoted.clear();
            highestVoted.add(voteablePlayers[i]);
          } else if (counter == higher && counter != 0) {
            highestVoted.add(voteablePlayers[i]);
          }
        }
      }
      counter = 0;
    }
    if (highestVoted.length == 1) {
      chosen = highestVoted[0];
    } else if (highestVoted.length > 1) {
      return(calculateVote(highestVoted, votingPlayers));
    }

    //Ensures at least a majority vote for town hangings.
    if(!(higher < (votingPlayers.length/2))) {
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
  Doctor(String name) {
    team = 'Town';
    role = 'Doctor';
    this.name = name;
    status = true;
    saved = false;
    Game.numOfDoctors++;
    Player.allThePlayers.add(this);
  }

//for doctor at night to save person
  static void savePlayer(Player player) {
    if (player == null) {
    } else {
      if (player.saved == false) {
        player.saved = true;
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

//testy
main() {
  final player1 = Doctor("Wyatt");
  final player2 = Mafia("Matthew");
  final player3 = Innocent("Talon");
  final player4 = Innocent("Elizabeth");
  final player5 = Innocent("spencer");
  final player6 = Innocent("daryl");
  final player7 = Innocent("trey");
  final player8 = Innocent("scott");

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
