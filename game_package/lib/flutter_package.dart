library game_package;

abstract class Player {
  var team;
  var role;
  var name;
  var status;
  var saved;






  void setDead(){
    if(saved == false) {
        status = 'Dead';
      }
  }

  void displayDetails() {
    print("Name: " + name);
    print("Role: " + role);
    print("Team: " + team);
    print("Status: " + status);
  }



}

class Mafia extends Player {

  Mafia(String name){
    team = 'Mafia';
    role = 'Mafia';
    this.name = name;
    status = "Alive";
    saved = false;
  }

  void killPlayer(Player player) {
    if (role == "Mafia") {
      player.setDead();
    }
  }
}


class Doctor extends Player{

  Doctor(String name){
    team = 'Town';
    role = 'Doctor';
    this.name = name;
    status = "Alive";
    saved = false;
  }

}

class Innocent extends Player{
  Innocent(String name){
    team = 'Town';
    role = 'Innocent';
    this.name = name;
    status = "Alive";
    saved = false;
  }
}


main() {
  final player1 = Doctor("Wyatt");
  final player2 = Mafia("Matthew");
  player1.displayDetails();
  player2.displayDetails();
  player2.killPlayer(player1);
  player1.displayDetails();

}