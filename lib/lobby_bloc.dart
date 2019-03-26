import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';


class LobbyProvider extends InheritedWidget {
  final LobbyBloc lobbyBloc;

  LobbyProvider({this.lobbyBloc, Widget child}) : super(child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static LobbyProvider of(BuildContext context) => context.inheritFromWidgetOfExactType(LobbyProvider);

}


class LobbyBloc {
  // Initial data
  List<Widget> _partyWidgets = [];
  List<Widget> get partyWidgets => _partyWidgets;

  // Input sink
  Sink<Widget> get newParty => _newPartyController.sink;
  final _newPartyController = StreamController<Widget>();

  // Output stream

  // Current list of the "party" or ListTile widgets
  Stream<List<Widget>> get parties => _partiesSubject.stream;
  final _partiesSubject = BehaviorSubject<List<Widget>>();

  // Number of lobbies
  Stream<int> get numRooms => _numRoomsSubject.stream;
  final _numRoomsSubject = BehaviorSubject<int>();

  LobbyBloc() {
    _newPartyController.stream.listen(_handle);
  }

  void _handle(Widget room) {
    // Input
    _partyWidgets.add(room);

    // Output
    _partiesSubject.add(_partyWidgets);
    _numRoomsSubject.add(_partyWidgets.length);

  }

  void dispose() {
    _newPartyController.close();
    _partiesSubject.close();
    _numRoomsSubject.close();
  }


}