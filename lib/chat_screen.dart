import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'game_database.dart';
import 'globals.dart' as globals;
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_database/firebase_database.dart';


class ChatScreen extends StatefulWidget {
  ChatScreen({Key key, this.uid}) : super(key: key);

  final String uid;

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  TextEditingController chatInput = TextEditingController();
  ScrollController listScrollController = new ScrollController();

  @override
  void initState() {
    GameDatabase.queryPartyChat(widget.uid).then((Query query) {
      setState(() {
        globals.chatQuery = query;
      });
    });

    super.initState();
  }

  Future<void> _messageSubmitted(String text) async {
    chatInput.clear();
    GameDatabase.sendPartyChat(widget.uid, globals.user, text);
    //listScrollController.animateTo(20, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Party Chat"),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              child: FirebaseAnimatedList(
                reverse: true,
                controller: listScrollController,
                query: globals.chatQuery,
                itemBuilder: (
                    BuildContext context,
                    DataSnapshot snapshot,
                    Animation<double> animation,
                    int index,
                    ) {
                  String key = snapshot.key;
                  Map map = snapshot.value;
                  String name = map['name'] as String;
                  String message = map['message'] as String;
                  String photoUrl = map['photoUrl'] as String;
                  return new Column(
                    children: <Widget>[
                      ListTile(
                        leading: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(35.0),
                              border: Border.all(width: .5, color: Colors.black12)),
                          child: CircleAvatar(
                            radius: 18.0,
                            backgroundImage: NetworkImage(photoUrl),
                          ),
                        ),
                        title: Text(name, textScaleFactor: .65,),
                        subtitle: Text(message, textScaleFactor: 1.35,),
                      )
                    ],
                  );
                },
              ),
            ),

            // chat input goes here
            Container(
              color: Colors.black12,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 5.0),
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: TextField(
                        controller: chatInput,
                        onChanged: (String messageText) {
                          setState(() {
                            //_isComposingMessage = messageText.length > 0;
                          });
                        },
                        decoration: InputDecoration.collapsed(hintText: "Send a message"),
                      ),
                    ),
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: IconButton(
                          icon: Icon(MdiIcons.send),
                          onPressed: () => _messageSubmitted(chatInput.text),
                        )
                    ),
                  ],
                ),
              ),
            )

          ],
        )
    );
  }

}