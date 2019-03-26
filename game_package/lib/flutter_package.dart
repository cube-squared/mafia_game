library game_package;

class Player {
  var team = '';
  var role = '';
  var status = "Alive";
  var saved = false;
  var name;

  Player(String name) {
    this.name = name;
  }

  Player setRole(r) {
    if (r == 'Doctor') return Doctor(name);
    if (r == 'Mafia') return Mafia(name);
    if (r == 'Innocent') return Innocent(name);
    throw "No Valid Role";
  }

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

  void killPlayer(Player player) {
    if (role == "Mafia") {
      player.setDead();
    }
  }

}

class Mafia extends Player {
  var team = 'Mafia';
  var role = 'Mafia';
  Mafia(name):super(name);
}


class Doctor extends Player{
  var team = 'Town';
  var role = 'Doctor';
  Doctor(name):super(name);
}

class Innocent extends Player {
  var team = 'Town';
  var role = 'Innocent';
  Innocent(name):super(name);
}


main() {
  final player1 = Player("Wyatt").setRole('Doctor');
  final player2 = Player("Talon").setRole('Mafia');
  player1.displayDetails();
  player2.displayDetails();
  player2.killPlayer(player1);
  player1.displayDetails();

}