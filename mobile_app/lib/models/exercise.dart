import 'package:cloud_firestore/cloud_firestore.dart';

class Exercise {
  final String id;
  final String itemCode;
  final String itemStr;
  final String situationCode;
  final String situationStr;
  final String levelStr;
  final String levelCode;
  final String variantStr;
  final String variantCode;
  final String image;
  final String audio;
  final int originalUsas;
  final int index;
  final ExerciseStatus status;

  /// Default class constructor
  Exercise(
      {this.id,
      this.itemCode,
      this.itemStr,
      this.situationCode,
      this.situationStr,
      this.levelStr,
      this.index,
      this.variantCode,
      this.variantStr,
      this.audio,
      this.image,
      this.originalUsas,
      this.status,
      this.levelCode});

  /// Converts Firestore Document into a Situation object
  factory Exercise.fromDocument(DocumentSnapshot doc) {
    return Exercise(
        id: doc.documentID,
        itemCode: doc['itemCode'],
        itemStr: doc['item'],
        situationCode: doc['situation'],
        situationStr: doc['situationStr'],
        levelCode: doc['level'],
        variantStr: doc['variantStr'],
        variantCode: doc['variant'],
        originalUsas: doc['originalUSAs'],
        image: doc['itemImg'],
        audio: doc['itemAudio'],
        index: doc['index'],
        status: ExerciseStatus.values.firstWhere(
            (e) => e.toString() == 'ExerciseStatus.' + doc['status']),
        levelStr: doc['levelStr']);
  }

  /// Returns a string representation of this object.
  @override
  String toString() {
    return 'itemCode: $itemCode, itemStr: $itemStr, situationCode: $situationCode, situationStr: $situationStr';
  }
}

enum ExerciseStatus { in_progress, waiting, completed }
