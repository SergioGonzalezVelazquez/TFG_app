import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {

  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        // new
        appBar: AppBar(
          title: Text('Chat'),
          actions: <Widget>[],
        ),
        body: Center(child: Text('Chat')));
  }
}
