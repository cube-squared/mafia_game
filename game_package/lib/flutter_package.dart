library game_package;

import 'dart:io';

abstract class Player {
  static List<Player> votes = [];
  static List<Player> allThePlayers = [];
  static List<Player> person = [];

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
  void killPlayers(){
    if(status == false){
      for(int i =0; i < allThePlayers.length; i++){
        if(this == allThePlayers[i]){
          allThePlayers.removeAt(i);
        }
      }
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

void assignRoles(){

}
void dayPhase(){

}
void nightPhase(){

}
//Sort idea -> sort and count, compare counts to find highest
// While loop idea -> run through list over and over counting instances of each name, keep highest
void calculateVote() {
  //sorts list of people who got voted
  Player.votes.sort((a, b) => a.getName().compareTo(b.getName()));
  Player.allThePlayers.sort((a,b) => a.getName().compareTo(b.getName()));

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
  for(int i = 0; i < Player.allThePlayers.length; i++){
    for(int j = 0; j < Player.votes.length; j++){
      if(Player.allThePlayers[i].getName().toLowerCase() == Player.votes[j].getName().toLowerCase()){
        counter++;
      }
      if(counter > higher){
        higher = counter;
        Player.person.clear();
        Player.person.add(Player.allThePlayers[i]);
      }
      else if(counter == higher){
        Player.person.add(Player.allThePlayers[i]);
      }
      if(Player.person.length == 1){
        chosen = Player.person[0];
      }
    }
    counter = 0;
  }

//  if(Player.person.length == 1){
//    chosen = Player.person[0];
//  }

  print("\nMost votes: " + chosen.getName());
  chosen.setStatus(false);
  chosen.killPlayers();
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
//  void killPlayer(Player player) {
//    if (player.team == "Town") {
//
//    }
//  }
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
    if(role == "Doctor"){
      vote(player.getName());
      calculateVote();
    }


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
  final player5 = Innocent("spencer");
  final player6 = Innocent("daryl");
  final player7 = Innocent("trey");
  final player8 = Innocent("scott");
  player1.vote('elizabeth');
  player2.vote('wyatt');
  player3.vote('wyatt');
  player4.vote('wyatt');
  player5.vote('elizabeth');
  player6.vote('elizabeth');
  player7.vote('talon');
  player8.vote('talon');

  calculateVote();

//Testing Thing
//  for(int i =0; i < Player.allThePlayers.length; i++)
//    print(Player.allThePlayers[i].getName());
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