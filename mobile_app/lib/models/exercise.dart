// ignore_for_file: constant_identifier_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'exposure_exercise.dart';

class Exercise extends Equatable {
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
  int afterCompleteAttempts;
  ExerciseStatus status;

  ExposureExercise currentExposure;
  List<ExposureExercise> exposures = [];

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
      this.afterCompleteAttempts,
      this.levelCode});

  /// Converts Firestore Document into a Situation object
  factory Exercise.fromDocument(DocumentSnapshot doc) {
    return Exercise(
        id: doc.id,
        itemCode: doc.data()['itemCode'],
        itemStr: doc.data()['item'],
        situationCode: doc.data()['situation'],
        situationStr: doc.data()['situationStr'],
        levelCode: doc.data()['level'],
        variantStr: doc.data()['variantStr'],
        variantCode: doc.data()['variant'],
        originalUsas: doc.data()['originalUSAs'],
        image: doc.data()['itemImg'],
        audio: doc.data()['itemAudio'],
        index: doc.data()['index'],
        afterCompleteAttempts: doc.data()['afterCompleteAttempts'],
        status: ExerciseStatus.values.firstWhere(
            (e) => e.toString() == 'ExerciseStatus.' + doc.data()['status']),
        levelStr: doc.data()['levelStr']);
  }

  /// Returns a string representation of this object.
  @override
  String toString() {
    return """itemCode: $itemCode, itemStr: $itemStr, 
    situationCode: $situationCode, situationStr: $situationStr""";
  }

  @override
  List<Object> get props => [
        itemCode,
        itemStr,
        situationCode,
        situationStr,
      ];

  /// Returns a string representation of this object.
  @override
  bool get stringify => true;
}

enum ExerciseStatus { in_progress, waiting, completed }
