import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfg_app/models/situation.dart';

class Therapy {
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
        id: doc.documentID,
        neutral: Situation.fromMap(doc['neutra']),
        anxiety: Situation.fromMap(doc['anxiety']),
        situations: doc['situations']
            .map((situation) => Situation.fromMap(situation))
            .toList()
            .cast<Situation>());
  }
}
