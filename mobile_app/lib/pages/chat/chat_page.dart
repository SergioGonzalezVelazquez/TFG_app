import 'dart:convert';
import 'dart:io';

import 'package:animator/animator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogflow/dialogflow_v2.dart';
import 'package:tfg_app/models/message.dart';
import 'package:tfg_app/pages/chat/chat_message.dart';
import 'package:tfg_app/services/auth.dart';
import 'package:tfg_app/services/dialogflow.dart';
import 'package:tfg_app/themes/custom_icon_icons.dart';
import 'package:uuid/uuid.dart';
///
/// References:
/// https://pub.dev/packages/flutter_dialogflow#-readme-tab-
/// https://hashnode.com/post/build-a-chatbot-in-20-minutes-using-flutter-and-dialogflow-cjy5ge9hr0018z7s10cbmaofi
/// https://medium.com/flutterdevs/chatbot-in-flutter-using-dialogflow-70e28665a827
///
class ChatPage extends StatefulWidget {
  ChatPage({Key key}) : super(key: key);

  /// Creates a StatelessElement to manage this widget's location in the tree.
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // Create controllers for handle changes in text fields
  final TextEditingController _textController = new TextEditingController();

  final List<ChatMessage> _messages = <ChatMessage>[];
  AuthGoogle _authGoogle;
  Dialogflow _dialogFlow;

  bool _showBotWritingAnimation = true;

  @override
  void initState() {
    super.initState();

    _initializeChat();
  }

  /**
   * Functions used to handle events in this screen 
   */

  ///
  Future<void> _initializeChat() async {
    setState(() {
      _showBotWritingAnimation = true;
    });
    String sessionId = Uuid().v4();
    _authGoogle = await AuthGoogle(
            fileJson: "assets/credentials.json", sessionId: sessionId)
        .build();

    // Create document in 'dialogflow_sessions' document
    createDialogflowSession(sessionId);

    _dialogFlow =
        Dialogflow(authGoogle: _authGoogle, language: Language.spanish);

    // Check if this conversation will be the first for this user
    if (therapySessions.isEmpty) {
      print("therapySessions.isEmpty");
      AIResponse responses = await activateIntent("FIRST_SESSION",
          parameters: {'username': user.name.split(" ").first});
      print("llega response de activar evento");
      _handleAgentResponse(responses);
    } else {
      print("therapySessions.isNotEmpty");
      AIResponse responses = await activateIntent("FIRST_SESSION",
          parameters: {'username': user.name.split(" ").first});
      print("llega response de activar evento");
      _handleAgentResponse(responses);
      //_sendMessage("hola");
    }
  }

  ///
  void _handleSubmitted(String text) {
    _textController.clear();
    ChatMessage message = new ChatMessage(
        message: Message(
          source: MessageSource.user,
          text: text,
          timestamp: Timestamp.now(),
        ),
        showInfo: _messages.isEmpty ||
            _messages[0].message.source != MessageSource.user);
    setState(
      () {
        _messages.insert(0, message);
      },
    );

    _sendMessage(text);
  }

  /// Esta función sirve cómo un complemento a la librería flutter_dialogflow,
  /// pues no soporta eventos de DialogFlow. Utilizando eventos, se puede activar
  /// un intent sin necesidad de una expresión del usuario final.
  Future<AIResponse> activateIntent(String eventName,
      {Map parameters = const {}}) async {
    String url =
        "https://dialogflow.googleapis.com/v2/projects/${_authGoogle.getProjectId}/agent/sessions/${_authGoogle.getSessionId}:detectIntent";

    String encodedParameters = json.encode(parameters);
    var response = await _authGoogle.post(url,
        headers: {
          HttpHeaders.authorizationHeader: "Bearer ${_authGoogle.getToken}"
        },
        body:
            "{'queryInput':{'event':{'name': '$eventName', 'parameters': $encodedParameters, 'languageCode': '${_dialogFlow.language}'}}}");
    print("response:");
    print(response.statusCode);
    print(response.body);
    return AIResponse(body: json.decode(response.body));
  }

  ///
  Future<void> _sendMessage(String query) async {
    _textController.clear();
    setState(() {
      _showBotWritingAnimation = true;
    });
    AIResponse responses = await _dialogFlow.detectIntent(query);
    _handleAgentResponse(responses);
  }

  void _handleAgentResponse(AIResponse responses) async {
    List messages = responses.getListMessage();
    print("messages:");
    print(messages);

    for (int i = 0; i < messages.length; i++) {
      setState(() {
        _showBotWritingAnimation = true;
      });
      await new Future.delayed(const Duration(milliseconds: 900));
      ChatMessage message = new ChatMessage(
        message: Message(
          source: MessageSource.bot,
          text: messages[i]['text']['text'][0],
          timestamp: Timestamp.now(),
        ),
        showInfo: _messages.isEmpty ||
            _messages[0].message.source != MessageSource.bot,
      );

      print("msg: " + messages[i]['text']['text'][0]);
      setState(
        () {
          _showBotWritingAnimation = false;
          _messages.insert(0, message);
        },
      );
    }
  }

  /**
   * Widgets (ui components) used in this screen 
   */

  Widget _textComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).primaryColor),
      child: new Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        child: new Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                controller: _textController,
                textInputAction: TextInputAction.send,
                // Force Flutter to rebuild this widget when user writes.
                // This will change the iconButon to send message icon.
                onChanged: (val) {
                  setState(() {});
                },
                onSubmitted: _handleSubmitted,
                decoration:
                    InputDecoration.collapsed(hintText: "Escribe un mensaje"),
              ),
            ),
            _textController.text.isEmpty
                ? Material(
                    borderRadius: BorderRadius.circular(4),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(4),
                      splashColor: Colors.red,

                      radius: 25,
                      onTap: () => print("record"),
                      child: Container(
                        child: Icon(
                          CustomIcon.microfono,
                          color: Theme.of(context).primaryColor,
                          size: 24,
                        ),
                      ),
                    ),
                  )
                : IconButton(
                    icon: Icon(CustomIcon.send3),
                    onPressed: () => _handleSubmitted(_textController.text),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _botWritingAnimation() {
    return Visibility(
      visible: _showBotWritingAnimation,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: new CircleAvatar(
                  backgroundImage: ExactAssetImage("assets/images/doctor.png"),
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
            Row(
              children: <Widget>[
                Animator(
                  duration: Duration(milliseconds: 1000),
                  cycles: 0,
                  builder: (anim) => Container(
                    width: 10 * anim.value,
                    height: 10 * anim.value,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColorLight,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Animator(
                  duration: Duration(milliseconds: 1100),
                  cycles: 0,
                  builder: (anim) => Container(
                    width: 10 * anim.value,
                    height: 10 * anim.value,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Animator(
                  duration: Duration(milliseconds: 1200),
                  cycles: 0,
                  builder: (anim) => Container(
                    width: 10 * anim.value,
                    height: 10 * anim.value,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColorDark,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _chatPage() {
    return new Scaffold(
        bottomNavigationBar: null,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Flexible(
                child: ListView.builder(
                    padding: EdgeInsets.all(8.0),
                    reverse: true,
                    itemBuilder: (_, int index) => _messages[index],
                    itemCount: _messages.length),
              ),
              _botWritingAnimation(),
              Divider(
                height: 1.0,
              ),
              Container(
                decoration: BoxDecoration(color: Theme.of(context).cardColor),
                child: _textComposer(),
              )
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return _chatPage();
  }
}
