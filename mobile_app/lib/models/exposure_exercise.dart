import 'package:cloud_firestore/cloud_firestore.dart';

class ExposureExercise {
  String _exerciseId;
  String _id;
  Timestamp _start;
  Timestamp _end;
  int _presetDuration; // seconds
  int _realDuration; // seconds

  // Respuestas al cuestionario antes
  int _usasBefore;
  int _selfEfficacyBefore;
  List<String> _panicBefore = [];

  // Respuestas al cuestionario después
  int _usasAfter;
  List<String> _panicAfter = [];

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
      int presetDuration,
      int realDuration}) {
    this._exerciseId = exerciseId;
    this._id = id;
    this._start = start;
    this._end = end;
    this._presetDuration = presetDuration;
    this._realDuration = realDuration;
    this._usasBefore = usasBefore;
    this._panicBefore = panicBefore;
    this._selfEfficacyBefore = selfEfficacyBefore;
    this._usasAfter = usasAfter;
    this._panicAfter = panicAfter;
  }

  // Getters
  String get id => this._id;
  String get exerciseId => this._exerciseId;
  int get usasAfter => this._usasAfter;
  int get usasBefore => this._usasBefore;
  int get presetDuration => this._presetDuration;
  int get realDuration => this._realDuration;
  int get selfEfficacyBefore => this._selfEfficacyBefore;
  List<String> get panicBefore => this._panicBefore;
  List<String> get panicAfter => this._panicAfter;
  Timestamp get start => this._start;
  Timestamp get end => this._end;

  // Setters
  set start(Timestamp timestamp) => this._start = timestamp;
  set end(Timestamp timestamp) => this._end = timestamp;
  set usasAfter(int usas) => this._usasAfter = usas;
  set usasBefore(int usas) => this._usasBefore = usas;
  set selfEfficacyBefore(int n) => this._selfEfficacyBefore = n;
  set presetDuration(int seconds) => this._presetDuration = seconds;
  set realDuration(int seconds) => this._realDuration = seconds;
  set exerciseId(String execId) => this._exerciseId = execId;
  set panicAfter(List<String> panic) => this._panicAfter = panic;
  set panicBefore(List<String> panic) => this._panicBefore = panic;

  /// Converts Firestore Document into a Situation object
  factory ExposureExercise.fromDocument(DocumentSnapshot doc) {
    List<String> panicAfterList = [];
    if (doc['panicAfter'] != null) {
      doc['panicAfter'].forEach((item) => panicAfterList.add(item));
    }
    List<String> panicBeforeList = [];
    if (doc['panicBefore'] != null) {
      doc['panicBefore'].forEach((item) => panicBeforeList.add(item));
    }
    return ExposureExercise(
      id: doc.documentID,
      exerciseId: doc['exerciseId'],
      start: doc['start'],
      end: doc['end'],
      presetDuration: doc['presetDuration'],
      realDuration: doc['realDuration'],
      usasAfter: doc['usasAfter'],
      panicAfter: panicAfterList,
      panicBefore: panicBeforeList,
      selfEfficacyBefore: doc['selfEfficacyBefore'],
      usasBefore: doc['usasBefore'],
    );
  }

  factory ExposureExercise.fromDS(String id, Map<String, dynamic> data) {
    List<String> panicAfterList = [];
    if (data['panicAfter'] != null) {
      data['panicAfter'].forEach((item) => panicAfterList.add(item));
    }
    List<String> panicBeforeList = [];
    if (data['panicBefore'] != null) {
      data['panicBefore'].forEach((item) => panicBeforeList.add(item));
    }
    return ExposureExercise(
      id: id,
      exerciseId: data['exerciseId'],
      start: data['start'],
      end: data['end'],
      presetDuration: data['presetDuration'],
      realDuration: data['realDuration'],
      usasAfter: data['usasAfter'],
      panicAfter: panicAfterList,
      panicBefore: panicBeforeList,
      selfEfficacyBefore: data['selfEfficacyBefore'],
      usasBefore: data['usasBefore'],
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = new Map();
    map['exerciseId'] = _exerciseId;
    map['usasAfter'] = _usasAfter;
    map['usasBefore'] = _usasBefore;
    map['selfEfficacyBefore'] = _selfEfficacyBefore;
    map['panicAfter'] = _panicAfter;
    map['panicBefore'] = _panicBefore;
    map['start'] = _start;
    map['end'] = _end;
    map['presetDuration'] = _presetDuration;
    map['realDuration'] = _realDuration;

    return map;
  }
}
