import 'package:cloud_firestore/cloud_firestore.dart';

// A 'UserMessage' contains basic details of a message
//sent by the user to the agent.
class UserMessage {
  // instance attributes
  String id;
  Timestamp timestamp;
  String text;

  // default constructor
  UserMessage(this.text, {this.id, this.timestamp}) {
    if (this.timestamp == null) this.timestamp = Timestamp.now();
  }

  // return 'String' value format of the 'UserMessage' object
  @override
  String toString() {
    return 'user message with text: $text, timestamp: ${timestamp.toDate().toIso8601String()}';
  }
}

enum MessageSource {
  user,
  bot,
}
