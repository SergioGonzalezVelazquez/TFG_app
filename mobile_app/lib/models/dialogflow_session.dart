import 'package:cloud_firestore/cloud_firestore.dart';

class TherapySession {
  final String id;
  final Timestamp startAt;
  final Timestamp endAt;

  TherapySession({this.id, this.startAt, this.endAt});

  factory TherapySession.fromDocument(DocumentSnapshot doc) {
    return TherapySession(
      id: doc['id'],
      startAt: doc['start_at'],
      endAt: doc['end_at'],
    );
  }

  @override
  String toString() {
    return 'id: $id, startAt: ${startAt.toDate().toIso8601String()}';
  }
}
