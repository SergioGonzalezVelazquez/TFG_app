import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String text;
  final Timestamp timestamp;
  final MessageSource source;

  Message({this.id, this.text, this.source, this.timestamp});

  factory Message.fromDocument(DocumentSnapshot doc) {
    return Message(
      id: doc['id'],
      text: doc['text'],
      source: MessageSource.values
          .firstWhere((e) => e.toString() == 'MessageSource.' + doc['source']),
      timestamp: doc['timestamp'],
    );
  }

  @override
  String toString() {
    return 'text: $text, source: ${source.toString()}, startAt: ${timestamp.toDate().toIso8601String()}';
  }
}

enum MessageSource {
  user,
  bot,
}
