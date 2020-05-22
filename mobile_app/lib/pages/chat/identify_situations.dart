import 'package:flutter/material.dart';
import 'package:tfg_app/pages/chat/chat_message.dart';
import 'package:tfg_app/services/auth.dart';
import 'package:flutter_dialogflow/dialogflow_v2.dart';

class SituationsPage extends StatefulWidget {
  static const route = "/situations";
  SituationsPage({Key key}) : super(key: key);

  /// Creates a StatelessElement to manage this widget's location in the tree.
  _SituationsPageState createState() => _SituationsPageState();
}

class _SituationsPageState extends State<SituationsPage> {
  // Create controllers for handle changes in text fields
  final TextEditingController _textController = new TextEditingController();

  AuthService _authService;

  final List<ChatMessage> _messages = <ChatMessage>[];
  Dialogflow _dialogFlow;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
  }

  /**
   * Functions used to handle events in this screen 
   */
  Widget _buildPage() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: <Widget>[
          RichText(
            text: TextSpan(
              text: 'Nuestro terapeuta virtual te ayudará a elegir entre 10 y 12 ',
              style: Theme.of(context).textTheme.bodyText2,
              children: <TextSpan>[
                TextSpan(
                  text: 'Básico limitado ciudad sin estacionamiento.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: ' Tendrás que exponerte a situaciones de '),
              ],
            ),
          ),
          Text(
            "Situaciones restantes:",
            style:
                Theme.of(context).textTheme.bodyText1.apply(fontWeightDelta: 2),
          ),
          Text(
            "Situaciones identificadas:",
            style:
                Theme.of(context).textTheme.bodyText1.apply(fontWeightDelta: 2),
          ),
        ],
      ),
    );
  }

  /**
   * Widgets (ui components) used in this screen 
   */

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
          title: Text(
        "Identificando situaciones",
      )),
      body: SafeArea(
        child: _buildPage(),
      ),
    );
  }
}
