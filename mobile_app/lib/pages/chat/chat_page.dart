import 'package:animator/animator.dart';
import 'package:flutter/material.dart';
import 'package:tfg_app/models/message.dart';
import 'package:tfg_app/models/patient.dart';
import 'package:tfg_app/pages/chat/chat_message.dart';
import 'package:tfg_app/pages/chat/identify_situations.dart';
import 'package:tfg_app/services/auth.dart';
import 'package:tfg_app/services/dialogflow.dart';
import 'package:tfg_app/themes/custom_icon_icons.dart';
import 'package:flutter_dialogflow/dialogflow_v2.dart';

///
/// References:
/// https://pub.dev/packages/flutter_dialogflow#-readme-tab-
/// https://hashnode.com/post/build-a-chatbot-in-20-minutes-using-flutter-and-dialogflow-cjy5ge9hr0018z7s10cbmaofi
/// https://medium.com/flutterdevs/chatbot-in-flutter-using-dialogflow-70e28665a827
///
class ChatPage extends StatefulWidget {
  static const route = "/chat";
  ChatPage({Key key}) : super(key: key);

  /// Creates a StatelessElement to manage this widget's location in the tree.
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // Create controllers for handle changes in text fields
  final TextEditingController _textController = new TextEditingController();

  AuthService _authService;

  final List<ChatMessage> _messages = <ChatMessage>[];
  Dialogflow _dialogFlow;
  ListSuggestionDialogflow _suggestions;

  bool _showBotWritingAnimation = true;
  bool _showTextInput = false;
  bool _showChipInput = false;
  bool _conversationEnd = false;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _initializeChat();
  }

  /**
   * Functions used to handle events in this screen 
   */

  /// Trigger the initial intent using dialogflow events.
  /// Send auth user name as parameter
  Future<void> _initializeChat() async {
    setState(() {
      _showBotWritingAnimation = true;
    });

    _dialogFlow =
        await initializeSession("assets/credentials.json", Language.spanish);

    AIResponse response;

    String name = _authService.user.name;
    PatientStatus patientStatus = await AuthService().patietStatus;
    if ([
      PatientStatus.identify_categories_pending,
      PatientStatus.identify_situations_pending
    ].contains(patientStatus)) {
      response = await _dialogFlow.activateIntent('FIRST_SESSION',
          parameters: {'username': name.split(" ").first});
    } else {
      response = await _dialogFlow.activateIntent('FIRST_SESSION',
          parameters: {'username': name.split(" ").first});
    }

    _handleAgentResponse(response);
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    ChatMessage message = new ChatMessage(userMessage: UserMessage(text));
    setState(
      () {
        _messages.insert(0, message);
      },
    );

    _sendMessage(text);
  }

  /// Send query as response to DialogFlow Agent
  Future<void> _sendMessage(String query) async {
    _textController.clear();
    setState(() {
      _showBotWritingAnimation = true;
    });
    AIResponse responses = await _dialogFlow.detectIntent(query);
    _handleAgentResponse(responses);
  }

  /// Handle Agent response
  void _handleAgentResponse(AIResponse responses) async {
    setState(() {
      _showTextInput = false;
      _showChipInput = false;
    });

    List messages = responses.getListMessage();
    print("messages:");
    print(messages);
    TypeMessage typeMessage;

    for (int i = 0; i < messages.length; i++) {
      print(messages[i]);
      typeMessage = TypeMessage(messages[i]);
      print("tipo de mensaje: ");
      print(typeMessage.type);

      if (typeMessage.type == 'text') {
        setState(() {
          _showBotWritingAnimation = true;
          _showTextInput = true;
        });
        ChatMessage message = new ChatMessage(
          botTextResponse: TextDialogflow(messages[i]['text']),
          showInfo: i == 0,
        );

        // Nº of words in this message
        int messageLength = message.botTextResponse.text.split(' ').length;

        await new Future.delayed(
          Duration(
            milliseconds: (300 * messageLength),
          ),
        );
        print("lo añades");
        print(message);
        setState(
          () {
            _showBotWritingAnimation = false;
            _messages.insert(0, message);
          },
        );
      } else if (typeMessage.type == 'suggestion') {
        print("no lo añades");
        setState(
          () {
            _suggestions = ListSuggestionDialogflow(messages[i]['payload']);
            _showBotWritingAnimation = false;
            _showChipInput = true;
          },
        );
      }
    }

    print("outputContexts: " +
        responses.queryResult.outputContexts.length.toString());
    // End of conversation
    if (responses.queryResult.outputContexts.isEmpty) {
      setState(() {
        _showTextInput = false;
        _showChipInput = false;
        _showBotWritingAnimation = false;
        _conversationEnd = true;
      });
    } 
    /*else if (responses.queryResult.outputContexts.length == 1) {
      List<String> contextNameSplit =
          responses.queryResult.outputContexts[0]["name"].split("/");
      String context = contextNameSplit[contextNameSplit.length - 1];
      if (context == 'end') {
        setState(() {
          _showTextInput = false;
          _showChipInput = false;
          _showBotWritingAnimation = false;
          _conversationEnd = true;
        });
      }
      print(context);
    }
    */
  }

  /**
   * Widgets (ui components) used in this screen 
   */

  Widget _textComposer() {
    return Column(
      children: <Widget>[
        Divider(
          height: 1.0,
        ),
        Container(
          decoration: BoxDecoration(color: Theme.of(context).cardColor),
          child: IconTheme(
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
                      decoration: InputDecoration.collapsed(
                          hintText: "Escribe un mensaje"),
                    ),
                  ),
                  Visibility(
                    visible: true,
                    child: IconButton(
                      icon: Icon(CustomIcon.list),
                      onPressed: () =>
                          Navigator.pushNamed(context, SituationsPage.route),
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
                          onPressed: () =>
                              _handleSubmitted(_textController.text),
                        ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _suggestionsComposer() {
    List<Widget> chips = [];
    chips.add(Divider(
      height: 1.0,
    ));
    chips.add(SizedBox(
      height: 8.0,
    ));
    _suggestions.listSuggestions.forEach((suggestion) {
      Widget chip = new Padding(
        padding: const EdgeInsets.only(bottom: 8.0, right: 10, left: 20),
        child: InkWell(
          onTap: () {
            _messages.insert(
                0, new ChatMessage(userMessage: UserMessage(suggestion.text)));
            _sendMessage(suggestion.value);
          },
          child: Align(
              alignment: Alignment.topRight,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                decoration: BoxDecoration(
                  //color: Color(0xffE4DFFD),
                  color: Colors.white,
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Text(
                  suggestion.text,
                  style: Theme.of(context).textTheme.bodyText2.apply(
                      color: Theme.of(context).primaryColor,
                      fontSizeFactor: .75),
                ),
              )),
        ),
      );
      chips.add(chip);
    });

    return Column(crossAxisAlignment: CrossAxisAlignment.end, children: chips);
  }

  Widget _endComposer() {
    return Column(
      children: <Widget>[
        Divider(
          height: 1.0,
        ),
        Text("Fin de la conversación")
      ],
    );
  }

  Widget _answerComposer() {
    Widget composer = Text("");
    if (_showChipInput && _suggestions != null) {
      composer = _suggestionsComposer();
    } else if (_showTextInput) {
      composer = _textComposer();
    } else if (_conversationEnd) {
      composer = _endComposer();
    }
    return composer;
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
              _showBotWritingAnimation
                  ? _botWritingAnimation()
                  : _answerComposer(),
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return _chatPage();
  }
}
