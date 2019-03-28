library game_package;

import 'dart:io';


abstract class Player {
  static List<Player> votes = [];
  static List<Player> allThePlayers =[];
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
  void vote(String theVote){
    for (int i = 0; i < Player.allThePlayers.length; i++){
      if (Player.allThePlayers[i].getName().toLowerCase() == theVote.toLowerCase()){
        Player.votes.add(Player.allThePlayers[i]);
      }
    }
  }
//Sort idea -> sort and count, compare counts to find highest
  // While loop idea -> run through list over and over counting instances of each name, keep highest
  void calculateVote(){

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
  player1.vote('tALOn');
  player2.vote('taLON');
  player3.vote('elizabeth');
  player4.vote('matthew');
  for(int i =0; i < Player.allThePlayers.length; i++)
  print(Player.votes[i].getName());
}