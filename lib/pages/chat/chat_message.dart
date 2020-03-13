import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  final String text;
  final String name;
  final bool type;

  ChatMessage({this.text, this.name, this.type});

  Widget botMessages(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        new Container(
          margin: const EdgeInsets.only(right: 16.0),
          child: new CircleAvatar(
            backgroundImage: ExactAssetImage("assets/images/doctor.png"),
            backgroundColor: Colors.transparent,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              name,
              style: Theme.of(context).textTheme.caption,
            ),
            Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * .6),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: Text(
                text,
                style: Theme.of(context)
                    .textTheme
                    .body1
                    .apply(color: Colors.black87),
              ),
            )
          ],
        ),
      ]),
    );
  }

  Widget myMessages(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, right: 5.0),
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * .6),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  decoration: BoxDecoration(
                    //color: Color(0xffE4DFFD),
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                      topLeft: Radius.circular(10),
                    ),
                  ),
                  child: Text(
                    text,
                    style: Theme.of(context)
                        .textTheme
                        .body1
                        .apply(color: Colors.white),
                  ),
                )
              ],
            ),
          ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return this.type ? myMessages(context) : botMessages(context);
  }
}
