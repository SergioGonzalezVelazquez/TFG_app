import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfg_app/models/patient.dart';

class User {
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
  User({this.id, this.email, this.photoUrl, this.name, this.createdAt});

  /// Converts Firestore Document into a User object
  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
        id: doc['id'],
        email: doc['email'],
        photoUrl: doc['photo'],
        name: doc['name'],
        createdAt: doc['created_at']);
  }

  /// Returns a string representation of this object.
  @override
  String toString() {
    return 'id: $id, email: $email, photoUrl: $photoUrl, name: $name, createdAt: ${createdAt.toDate().toIso8601String()}';
  }
}
