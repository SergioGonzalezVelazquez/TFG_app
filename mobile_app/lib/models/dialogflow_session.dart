import 'package:cloud_firestore/cloud_firestore.dart';

class DialogflowSession {
  final String id;
  final DateTime startAt;
  List<DialogflowMessage> messages;

  DialogflowSession({this.id, this.startAt, this.messages});

  factory DialogflowSession.fromDocument(DocumentSnapshot doc) {
    return DialogflowSession(
      id: doc.data()['id'],
      startAt: doc.data()['start_at'].toDate(),
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
      id: doc.id,
      type: doc.data()['type'],
      text: doc.data()['text'],
      index: doc.data()['index'],
      timestamp: doc.data()['timestamp'].toDate(),
    );
  }
}
