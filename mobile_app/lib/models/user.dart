import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfg_app/models/patient.dart';

class MUser {
  final String id;
  final String email;
  final String photoUrl;
  final String name;
  final Timestamp createdAt;
  Patient _patient;

  /// Getters used to retrieve the values of class fields
  Patient get patient => this._patient;

  /// Setters used to initialize the values of class fields
  set patient(Patient patient) => this._patient = patient;

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

  /// Returns a string representation of this object.
  @override
  String toString() {
    return 'id: $id, email: $email, photoUrl: $photoUrl, name: $name, createdAt: ${createdAt.toDate().toIso8601String()}';
  }
}
