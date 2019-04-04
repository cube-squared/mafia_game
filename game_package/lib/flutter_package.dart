library game_package;

import 'dart:io';

abstract class Player {
  static List<Player> votes = [];
  static List<Player> allThePlayers = [];
  static List<Player> person = [];
  static List<String> deadDudes = [];
  static bool sleepyTime;
  static bool winner = false;
  static String teamWinner;
  static bool thing = false;

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
  static void makePlayersDead() {
    for (int i = 0; i < Player.allThePlayers.length; i++) {
      if (Player.allThePlayers[i].getStatus()) {
        Player.allThePlayers[i].setSaved(false);
      } else {
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
      Player.winner = true;
      Player.teamWinner = 'Mafia';
    } else if (counter == 0) {
      Player.winner = true;
      Player.teamWinner = 'Towns People';
    }
  }

  static void dayPhase() {
    //Who died?
    Player.sleepyTime = false;
    for (int i = 0; i < Player.deadDudes.length; i++) {
      stdout.writeln("AWE MAN " + Player.deadDudes[i] + " died");
    }
    Player.deadDudes.clear();
    checkWin();
//oh people talk Chat();

//Vote for lynchin
    if (Player.winner == false) {
      getVotes();
      calculateVote();
      checkWin();
    }
  }

  static void nightPhase() {
    Player.sleepyTime = true;

//Doctor Bit
    stdout.writeln("Hey fellas ya gotta vote for who to save!");
    String savedDude = stdin.readLineSync();
    Doctor.savePlayer(makeStringIntoPerson(savedDude));

//Mafia Bit
    stdout.writeln("Hows it goin dude or dudette mafia! Kill someone!");
    String killedDude = stdin.readLineSync();
    Mafia.killPlayer(makeStringIntoPerson(killedDude));

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

  static void getVotes(){
    for (int i = 0; i < Player.allThePlayers.length; i++) {
      stdout.writeln("Okay player number ${i + 1} vote for lynchin (type anything that isn't a players name to opt out of voting.):");
      Player.vote(stdin.readLineSync());
    }
  }

//Sort idea -> sort and count, compare counts to find highest
// While loop idea -> run through list over and over counting instances of each name, keep highest
  static void calculateVote() {
    //sorts list of people who got voted
    Player.votes.sort((a, b) => a.getName().compareTo(b.getName()));
    Player.allThePlayers.sort((a, b) => a.getName().compareTo(b.getName()));

    for (int i = 0; i < Player.allThePlayers.length; i++) {
      print(Player.allThePlayers[i].getName());
    }
    print("\n");
    //testing thing
    for (int i = 0; i < Player.votes.length; i++) {
      print(Player.votes[i].getName());
    }

    int counter = 0;
    int higher = 0;
    Player chosen;
    for (int i = 0; i < Player.allThePlayers.length; i++) {
      for (int j = 0; j < Player.votes.length; j++) {
        if (Player.allThePlayers[i].getName().toLowerCase() ==
            Player.votes[j].getName().toLowerCase()) {
          counter++;
        }
        if(Player.person.contains(Player.allThePlayers[i])){

        } else {
          if (counter > higher) {
            higher = counter;
            Player.person.clear();
            Player.person.add(Player.allThePlayers[i]);
          } else if (counter == higher && counter != 0) {
            Player.person.add(Player.allThePlayers[i]);
          }
        }
      }
      counter = 0;
    }
    if (Player.person.length == 1) {
      chosen = Player.person[0];
    } else if (Player.person.length > 1) {
      Player.votes.clear();
      getVotes();
      chosen = calculateTie(Player.person);
    }

//  if(Player.person.length == 1){
//    chosen = Player.person[0];
//  }

    //Ensures at least a majority vote for town hangings.
    if(Player.thing == true){
      print("\nMost votes: " + chosen.getName());
      chosen.setStatus(false);
      Player.allThePlayers.removeAt(Player.allThePlayers.indexOf(chosen));
      print('${chosen.getName()} was lynched. ffff');

      stdout.writeln("TEST STUFF GO AWAY:");
      for (int i = 0; i < Player.allThePlayers.length; i++)
        stdout.writeln(Player.allThePlayers[i].getName());
      Player.thing = false;
    } else if (!(higher < (Player.allThePlayers.length/2))) {
      //Then kills them.
      print("\nMost votes: " + chosen.getName());
      chosen.setStatus(false);
      Player.allThePlayers.removeAt(Player.allThePlayers.indexOf(chosen));
      print('${chosen.getName()} was lynched. ffff');

      stdout.writeln("TEST STUFF GO AWAY:");
      for (int i = 0; i < Player.allThePlayers.length; i++)
        stdout.writeln(Player.allThePlayers[i].getName());
    }
  }

//Will eventually do a thing
  static Player calculateTie(List<Player> tiedPeople) {
    Player.thing = true;
    List<Player> tiedPeoplebutBetter = new List<Player>();
    for(int i = 0; i < tiedPeople.length; i++){
      tiedPeoplebutBetter.add(tiedPeople[i]);
    }
    Player.person.clear();
    tiedPeoplebutBetter.sort((a, b) => a.getName().compareTo(b.getName()));

    int tieCounter = 0;
    int tieHigher = 0;
    Player tieChosen;
    for (int i = 0; i < tiedPeoplebutBetter.length; i++) {
      for (int j = 0; j < Player.votes.length; j++) {
        if (tiedPeoplebutBetter[i].getName().toLowerCase() ==
            Player.votes[j].getName().toLowerCase()) {
          tieCounter++;
        }
        if(Player.person.contains(tiedPeoplebutBetter[i])){

        } else {
          if (tieCounter > tieHigher) {
            tieHigher = tieCounter;
            Player.person.clear();
            Player.person.add(tiedPeoplebutBetter[i]);
          } else if (tieCounter == tieHigher && tieCounter != 0) {
            Player.person.add(tiedPeoplebutBetter[i]);
          }
        }
        }
      tieCounter = 0;
    }
    if (Player.person.length == 1) {
      tieChosen = Player.person[0];
    } else if (Player.person.length != 1) {
      Player.votes.clear();
      getVotes();
      tieChosen = calculateTie(Player.person);
    }
    return tieChosen;
  }
}

class Mafia extends Player {
  Mafia(String name) {
    team = 'Mafia';
    role = 'Mafia';
    this.name = name;
    status = true;
    saved = false;
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
  while (!Player.winner) {
    Game.nightPhase();
    Game.dayPhase();
  }
  print('${Player.teamWinner} won the game!');

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
