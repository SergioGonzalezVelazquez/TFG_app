import 'package:flutter/material.dart';
import 'package:flutter_dialogflow/dialogflow_v2.dart';

import '../../main.dart';
import '../../models/dialogflow_session.dart';
import '../../models/message.dart';
import '../../services/dialogflow.dart';
import '../../widgets/progress.dart';
import 'chat_message.dart';

class ChatResume extends StatefulWidget {
  final String sessionId;
  ChatResume(this.sessionId);

  /// Creates a StatelessElement to manage this widget's location in the tree.
  _ChatResumeState createState() => _ChatResumeState();
}

class _ChatResumeState extends State<ChatResume> {
  bool _isLoading;
  DialogflowSession _session;

  final List<ChatMessage> _messages = <ChatMessage>[];

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  /// Functions used to handle events in this screen

  Future<void> _fetchMessages() async {
    setState(() {
      _isLoading = true;
    });
    DialogflowSession session =
        await getDialogflowSessionById(widget.sessionId);
    if (session != null) {
      session.messages.forEach((element) {
        if (element.type == "user") {
          _messages.insert(
            0,
            ChatMessage(
              userMessage:
                  UserMessage(element.text, timestamp: element.timestamp),
            ),
          );
        } else {
          TextDialogflow textDialogflow = TextDialogflow(null);
          textDialogflow.timestamp = element.timestamp;
          textDialogflow.text = element.text;
          _messages.insert(
            0,
            ChatMessage(
              botTextResponse: textDialogflow,
              padding: false,
            ),
          );
        }
      });
      setState(() {
        _session = session;
        print(_session.messages.length);
        _isLoading = false;
      });
    } else {
      Navigator.pop(context);
    }
  }

  /// Widgets (ui components) used in this screen

  Widget _buildPage(BuildContext context) {
    return Column(
      children: <Widget>[
        Flexible(
          child: ListView.builder(
              padding: EdgeInsets.all(8.0),
              reverse: true,
              itemBuilder: (_, index) => _messages[index],
              itemCount: _messages.length),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isLoading
          ? null
          : AppBar(
              title: Text(
                dateFormatter.format(
                  _session.startAt,
                ),
              ),
              actions: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: CircleAvatar(
                    backgroundColor: Color(0xffE8E1ED),
                    backgroundImage: AssetImage("assets/images/doctor.png"),
                  ),
                )
              ],
            ),
      body: _isLoading ? circularProgress(context) : _buildPage(context),
    );
  }
}
