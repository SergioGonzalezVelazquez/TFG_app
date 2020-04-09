import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tfg_app/models/message.dart';
import 'package:intl/intl.dart';

class ChatMessage extends StatelessWidget {
  final Message message;

  // Flag to controls whether msg date and source photo should be displayed
  // It is used when there are several continuous messages of the same type
  final bool showInfo;

  final DateFormat timeFormat = DateFormat(DateFormat.HOUR24_MINUTE);

  ChatMessage({this.message, this.showInfo = true});

  Widget botMessages(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Opacity(
          opacity: showInfo ? 1 : 0,
          child: new Container(
            margin: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: new CircleAvatar(
                backgroundImage: ExactAssetImage("assets/images/doctor.png"),
                backgroundColor: Colors.transparent,
              ),
            ),
          ),
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
                    message.text,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .apply(color: Colors.black87),
                  ),
                  SizedBox(
                    height: 3,
                  ),
                  Text(
                    timeFormat.format(message.timestamp.toDate()),
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

  Widget myMessages(BuildContext context) {
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
                  message.text,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2
                      .apply(color: Colors.white),
                ),
                Text(
                  timeFormat.format(message.timestamp.toDate()),
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
    return message.source == MessageSource.bot
        ? botMessages(context)
        : myMessages(context);
  }
}
