import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dialogflow/dialogflow_v2.dart';
import 'package:tfg_app/pages/chat/chat_message.dart';
import 'package:tfg_app/services/auth.dart';
import 'package:tfg_app/services/dialogflow.dart';
import 'package:tfg_app/themes/custom_icon_icons.dart';
import 'package:tfg_app/widgets/buttons.dart';
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
    ChatMessage message =
        new ChatMessage(text: text, name: "Client", type: true);
    setState(() {
      _messages.insert(0, message);
    });

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
    AIResponse responses = await _dialogFlow.detectIntent(query);
    _handleAgentResponse(responses);
  }

  void _handleAgentResponse(AIResponse responses) {
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
  }

  /**
   * Widgets (ui components) used in this screen 
   */
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
                      itemCount: _messages.length)),
              Divider(
                height: 1.0,
              ),
              Container(
                decoration: BoxDecoration(color: Theme.of(context).cardColor),
                child: _buildTextComposer(),
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
