import 'package:flutter/material.dart';
import 'package:flutter_dialogflow/dialogflow_v2.dart';
import 'package:tfg_app/pages/chat/chat_message.dart';
import 'package:tfg_app/themes/custom_icon_icons.dart';
import 'package:tfg_app/widgets/buttons.dart';

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
  AuthGoogle _authGoogle;
  Dialogflow _dialogFlow;

  bool _chatStarted = false;

  @override
  void initState() {
    super.initState();

    //initializeChat();
  }

  Future<void> initializeChat() async {
    _authGoogle = await AuthGoogle(fileJson: "assets/credentials.json").build();
    _dialogFlow =
        Dialogflow(authGoogle: _authGoogle, language: Language.spanish);

    sendMessage("hola");
  }

  Widget startChatScreen() {
    return new Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
        actions: <Widget>[],
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 12.0, left: 15, right: 15),
        child: Center(
          child: primaryButton(context, () async {
            await initializeChat();
            setState(() {
              this._chatStarted = true;
            });
          }, "Empezar chat"),
        ),
      ),
    );
  }

  Widget inChatScreen() {
    return new Scaffold(
        bottomNavigationBar: null,
        body: Column(
          children: <Widget>[
            Flexible(
                child: ListView.builder(
                    padding: EdgeInsets.all(8.0),
                    reverse: true,
                    itemBuilder: (_, int index) => _messages[index],
                    itemCount: _messages.length)),
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
    AIResponse responses = await dialogFlow.detectIntent(query);

    //DEBUG
    List messages = responses.getListMessage();
    print("messages:");
    print(messages);

    //End debug
    responses.getListMessage().forEach((msg) {
      ChatMessage message = new ChatMessage(
          text: msg['text']['text'][0], name: "Bot", type: false);

      print("msg: " + msg['text']['text'][0]);
      setState(() {
        _messages.insert(0, message);
      });
    });

    /*
    //Iterate over all responses
    responses.getListMessage().forEach((msg) {
      ChatMessage message = new ChatMessage(
          text:  CardDialogflow(msg).title,
          name: "Bot",
          type: false);

      print("msg: " );
      setState(() {
        _messages.insert(0, message);
      });
    });
    */
  }

  @override
  Widget build(BuildContext context) {
    return _chatStarted ? inChatScreen() : startChatScreen();
  }
}
