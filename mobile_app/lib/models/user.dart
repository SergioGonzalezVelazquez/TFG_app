import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'patient.dart';

class MUser extends Equatable {
  final String id;
  final String email;
  final String photoUrl;
  final String name;
  final Timestamp createdAt;
  Patient patient;

  /// Default class constructor
  MUser({this.id, this.email, this.photoUrl, this.name, this.createdAt});

  /// Converts Firestore Document into a User object
  factory MUser.fromDocument(DocumentSnapshot doc) {
    return MUser(
        id: doc.id,
        email: doc.data()['email'],
        photoUrl: doc.data()['photo'],
        name: doc.data()['name'],
        createdAt: doc.data()['created_at']);
  }

  @override
  List<Object> get props => [id, email, photoUrl, name, createdAt, patient];

  /// Returns a string representation of this object.
  @override
  bool get stringify => true;
}
