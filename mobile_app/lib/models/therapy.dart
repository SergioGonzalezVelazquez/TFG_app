import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'situation.dart';

class Therapy extends Equatable {
  final String id;
  final Situation neutral;
  final Situation anxiety;
  final List<Situation> situations;

  /// Default class constructor
  Therapy({
    this.id,
    this.neutral,
    this.anxiety,
    this.situations,
  });

  /// Converts Firestore Document into a Therapy object
  factory Therapy.fromDocument(DocumentSnapshot doc) {
    return Therapy(
      id: doc.id,
      neutral: Situation.fromMap(doc.data()['neutra']),
      anxiety: Situation.fromMap(doc.data()['anxiety']),
      situations: doc
          .data()['situations']
          .map((situation) => Situation.fromMap(situation))
          .toList()
          .cast<Situation>(),
    );
  }

  @override
  List<Object> get props => [id, neutral, anxiety, situations];

  /// Returns a string representation of this object.
  @override
  bool get stringify => true;
}
