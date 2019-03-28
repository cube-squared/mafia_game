library game_package;

import 'dart:io';


abstract class Player {
  static List<Player> votes = [];
  static List<Player> allThePlayers = [];
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
  void vote(String theVote) {
    for (int i = 0; i < Player.allThePlayers.length; i++) {
      if (Player.allThePlayers[i].getName().toLowerCase() ==
          theVote.toLowerCase()) {
        Player.votes.add(Player.allThePlayers[i]);
      }
    }
  }
}

//Sort idea -> sort and count, compare counts to find highest
// While loop idea -> run through list over and over counting instances of each name, keep highest
void calculateVote() {
  //sorts list of people who got voted
  Player.votes.sort((a, b) => a.getName().compareTo(b.getName()));
  for (int i = 0; i < Player.votes.length; i++) {
    print(Player.votes[i].getName());
  }

  int count = 0;
  int count2 = 0;
  Player person1;
  Player person2;
  Player personChosen;
  while (Player.votes.isNotEmpty) {
    for (int i = 1; i < Player.votes.length; i++) {
      person1 = Player.votes[0];
      if (Player.votes[0].getName().toLowerCase() ==
          Player.votes[i].getName().toLowerCase()) {
        count++;
        Player.votes.remove(Player.votes[i]);
      }
    }
    Player.votes.remove(Player.votes[0]);
    for (int i = 1; i < Player.votes.length; i++) {
      person2 = Player.votes[1];
      if (Player.votes[1].getName().toLowerCase() ==
          Player.votes[i].getName().toLowerCase()) {
        count2++;
        Player.votes.remove(Player.votes[i]);
      }
    }
      if (count > count2)
        personChosen = person1;
      else
        personChosen = person2;
  }

  Player.votes.add(personChosen);

  print("\nmost votes: " + personChosen.getName());

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
  void killPlayer(Player player) {
    if (player.team == "Town") {

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
  void savePlayer(Player player) {
    if (player.saved == false) {
      player.saved = true;
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
  final player5 = Doctor("spencer");
  final player6 = Mafia("darly");
  final player7 = Innocent("trey");
  final player8 = Innocent("scott");
  player1.vote('tALOn');
  player2.vote('taLON');
  player3.vote('elizabeth');
  player4.vote('matthew');
  player5.vote('tALOn');
  player6.vote('taLON');
  player7.vote('elizabeth');
  player8.vote('wyatt');

  calculateVote();

  /*for(int i =0; i < Player.allThePlayers.length; i++)
    print(Player.votes[i].getName());*/
}