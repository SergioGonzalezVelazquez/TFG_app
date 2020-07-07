import 'package:cloud_firestore/cloud_firestore.dart';

class DialogflowSession {
  final String id;
  final DateTime startAt;
  List<DialogflowMessage> messages;

  DialogflowSession({this.id, this.startAt, this.messages});

  factory DialogflowSession.fromDocument(DocumentSnapshot doc) {
    return DialogflowSession(
      id: doc['id'],
      startAt: doc['start_at'].toDate(),
      messages: [],
    );
  }

  @override
  String toString() {
    return 'id: $id, startAt: ${startAt.toString()}';
  }
}

class DialogflowMessage {
  final String id;
  final String type;
  final String text;
  final DateTime timestamp;
  final int index;

  DialogflowMessage({this.id, this.type, this.text, this.timestamp, this.index});

  factory DialogflowMessage.fromDocument(DocumentSnapshot doc) {
    return DialogflowMessage(
      id: doc.documentID,
      type: doc['type'],
      text: doc['text'],
      index: doc['index'],
      timestamp: doc['timestamp'].toDate(),
    );
  }
}
