import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tfg_app/main.dart';
import 'package:tfg_app/models/message.dart';
import 'package:flutter_dialogflow/dialogflow_v2.dart';

class ChatMessage extends StatelessWidget {
  final UserMessage userMessage;
  final TextDialogflow botTextResponse;
  final bool padding;

  final ExactAssetImage botImage = ExactAssetImage("assets/images/doctor.png");

  // Flag to controls whether msg date and source photo should be displayed
  // It is used when there are several continuous messages of the same type
  final bool showInfo;

  // Constructor
  ChatMessage(
      {this.userMessage,
      this.botTextResponse,
      this.showInfo = false,
      this.padding = true});

  Widget buildBotTextResponse(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        padding
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Opacity(
                  opacity: showInfo ? 1 : 0,
                  child: new Container(
                    margin: const EdgeInsets.only(right: 16.0),
                    child: Center(
                      child: new CircleAvatar(
                        backgroundImage: botImage,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  ),
                ),
              )
            : SizedBox(
                width: 5.0,
              ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * .7),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    botTextResponse.text,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .apply(color: Colors.black87),
                  ),
                  SizedBox(
                    height: 3,
                  ),
                  Text(
                    timeFormatter.format(botTextResponse.timestamp),
                    style: TextStyle(fontSize: 9),
                  ),
                ],
              ),
            ),
          ],
        ),
      ]),
    );
  }

  Widget buildUserMessage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, right: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * .6),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            decoration: BoxDecoration(
              //color: Color(0xffE4DFFD),
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(10),
                bottomLeft: Radius.circular(10),
                topLeft: Radius.circular(10),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  userMessage.text,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2
                      .apply(color: Colors.white),
                ),
                Text(
                  timeFormatter.format(userMessage.timestamp),
                  style: TextStyle(
                      fontSize: 9, color: Colors.white.withOpacity(0.8)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget widget;
    if (userMessage != null)
      widget = buildUserMessage(context);
    else
      widget = buildBotTextResponse(context);
    return widget;
  }
}
