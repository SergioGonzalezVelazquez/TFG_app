import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ExposureExercise extends Equatable {
  String _exerciseId;
  String _id;
  Timestamp start;
  Timestamp end;
  int presetDuration; // seconds
  int realDuration; // seconds

  // True if this exposure complete an exercise
  bool completedExercise;

  // Respuestas al cuestionario antes
  int usasBefore;
  int selfEfficacyBefore;
  List<String> panicBefore = [];

  // Respuestas al cuestionario después
  int usasAfter;
  List<String> panicAfter = [];

  /// Default class constructor
  ExposureExercise(
      {String exerciseId,
      String id,
      int usasAfter,
      int selfEfficacyBefore,
      List<String> panicBefore,
      List<String> panicAfter,
      int usasBefore,
      Timestamp start,
      Timestamp end,
      bool completedExercise,
      int presetDuration,
      int realDuration}) {
    this.start;
    this.end;
    _exerciseId = exerciseId;
    _id = id;
    this.presetDuration;
    this.realDuration;
    this.usasBefore;
    this.panicBefore;
    this.selfEfficacyBefore;
    this.completedExercise;
    this.usasAfter;
    this.panicAfter;
  }

  // Getters

  /// Converts Firestore Document into a Situation object
  factory ExposureExercise.fromDocument(DocumentSnapshot doc) {
    List<String> panicAfterList = [];
    var data = doc.data();
    print(data);
    if (doc.data()['panicAfter'] != null) {
      doc.data()['panicAfter'].forEach((item) => panicAfterList.add(item));
    }
    List<String> panicBeforeList = [];
    if (doc.data()['panicBefore'] != null) {
      doc.data()['panicBefore'].forEach((item) => panicBeforeList.add(item));
    }
    return ExposureExercise(
        id: doc.id,
        exerciseId: doc.data()['exerciseId'],
        start: doc.data()['start'],
        end: doc.data()['end'],
        presetDuration: doc.data()['presetDuration'],
        realDuration: doc.data()['realDuration'],
        usasAfter: doc.data()['usasAfter'],
        panicAfter: panicAfterList,
        panicBefore: panicBeforeList,
        selfEfficacyBefore: doc.data()['selfEfficacyBefore'],
        usasBefore: doc.data()['usasBefore'],
        completedExercise: doc.data()['completedExercise'] ?? false);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    map['exerciseId'] = _exerciseId;
    map['usasAfter'] = usasAfter;
    map['usasBefore'] = usasBefore;
    map['selfEfficacyBefore'] = selfEfficacyBefore;
    map['panicAfter'] = panicAfter;
    map['panicBefore'] = panicBefore;
    map['start'] = start;
    map['end'] = end;
    map['presetDuration'] = presetDuration;
    map['realDuration'] = realDuration;
    map['completedExercise'] = completedExercise ?? false;

    return map;
  }

  @override
  List<Object> get props => [
        _exerciseId,
        _id,
        start,
        end,
        presetDuration,
        realDuration,
        usasBefore,
        panicBefore,
        selfEfficacyBefore,
        completedExercise,
        usasAfter,
        panicAfter,
      ];

  /// Returns a string representation of this object.
  @override
  bool get stringify => true;
}
