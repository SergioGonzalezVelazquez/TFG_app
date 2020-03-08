import 'package:flutter/material.dart';
import 'package:flutter_dialogflow/dialogflow_v2.dart';
import 'package:tfg_app/pages/chat/chat_message.dart';
import 'package:tfg_app/themes/custom_icon_icons.dart';

///
/// References:
/// https://pub.dev/packages/flutter_dialogflow#-readme-tab-
/// https://hashnode.com/post/build-a-chatbot-in-20-minutes-using-flutter-and-dialogflow-cjy5ge9hr0018z7s10cbmaofi
/// https://medium.com/flutterdevs/chatbot-in-flutter-using-dialogflow-70e28665a827
///
class ChatPage extends StatefulWidget {
  ChatPage({Key key}) : super(key: key);
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _textController = new TextEditingController();
  final List<ChatMessage> _messages = <ChatMessage>[];

  @override
  void initState() {
    super.initState();
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).primaryColor),
      child: new Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        child: new Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: _handleSubmitted,
                decoration:
                    InputDecoration.collapsed(hintText: "Escribe un mensaje"),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                  icon: Icon(CustomIcon.send2),
                  onPressed: () => _handleSubmitted(_textController.text)),
            )
          ],
        ),
      ),
    );
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    ChatMessage message =
        new ChatMessage(text: text, name: "Client", type: true);
    setState(() {
      _messages.insert(0, message);
    });

    sendMessage(text);
  }

  void sendMessage(String query) async {
    _textController.clear();
    AuthGoogle authGoogle =
        await AuthGoogle(fileJson: "assets/credentials.json").build();

    Dialogflow dialogFlow =
        Dialogflow(authGoogle: authGoogle, language: Language.spanish);
    AIResponse response = await dialogFlow.detectIntent(query);
    ChatMessage message = new ChatMessage(
        text: response.getMessage() ??
            new CardDialogflow(response.getListMessage()[0]).title,
        name: "Bot",
        type: false);
    setState(() {
      _messages.insert(0, message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        // new
        appBar: AppBar(
          title: Text('Chat'),
          actions: <Widget>[],
        ),
        body: Column(
          children: <Widget>[
            Flexible(
                child: ListView.builder(
              padding: EdgeInsets.all(8.0),
              reverse: true,
              itemBuilder: (_, int index) => _messages[index],
              itemCount: _messages.length
            )),
            Divider(
              height: 1.0,
            ),
            Container(
              decoration: BoxDecoration(color: Theme.of(context).cardColor),
              child: _buildTextComposer(),
            )
          ],
        ));
  }
}
