import 'package:cloud_firestore/cloud_firestore.dart';

class Patient {
  final String id;
  final String type;
  final Timestamp createdAt;

  /// Default class constructor
  Patient({this.id, this.type, this.createdAt});

  /// Converts Firestore Document into a User object
  factory Patient.fromDocument(DocumentSnapshot doc) {
    return Patient(
        id: doc['id'], type: doc['type'], createdAt: doc['created_at']);
  }

  /// Returns a string representation of this object.
  @override
  String toString() {
    return 'id: $id, type: $type, createdAt: ${createdAt.toDate().toIso8601String()}';
  }
}
