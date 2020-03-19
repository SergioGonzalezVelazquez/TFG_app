import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String username;
  final String email;
  final String photoUrl;
  final String name;

  User({this.id, this.username, this.email, this.photoUrl, this.name});

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      id: doc['id'],
      email: doc['email'],
      username: doc['username'],
      photoUrl: doc['photo'],
      name: doc['displayName'],
    );
  }

  @override
  String toString() {
    return 'id: $id, email: $email, username: $username, photoUrl: $photoUrl, name: $name';
  }
}
