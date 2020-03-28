import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String email;
  final String photoUrl;
  final String name;
  final Timestamp createdAt;

  User({this.id, this.email, this.photoUrl, this.name, this.createdAt});

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
        id: doc['id'],
        email: doc['email'],
        photoUrl: doc['photo'],
        name: doc['name'],
        createdAt: doc['created_at']);
  }

  @override
  String toString() {
    return 'id: $id, email: $email, photoUrl: $photoUrl, name: $name, createdAt: ${createdAt.toDate().toIso8601String()}';
  }
}
