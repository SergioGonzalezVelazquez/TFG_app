// ignore_for_file: constant_identifier_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'exercise.dart';
import 'therapy.dart';

class Patient extends Equatable {
  final String id;
  final String type;
  final PatientStatus status;
  final DateTime identifySituationsDate;
  final DateTime hierarchyCompletedDate;
  final String identifySituationsSessionId;
  final DateTime lastExerciseCompleted;
  final int bestDailyStreak;
  int currentDailyStreak;
  Therapy currentTherapy;
  List<Exercise> exercises;

  /// Default class constructor
  Patient(
      {this.id,
      this.type,
      this.status,
      this.currentTherapy,
      this.exercises,
      this.hierarchyCompletedDate,
      this.identifySituationsDate,
      this.lastExerciseCompleted,
      this.bestDailyStreak,
      this.currentDailyStreak,
      this.identifySituationsSessionId});

  /// Converts Firestore Document into a User object
  factory Patient.fromDocument(DocumentSnapshot doc) {
    return Patient(
        id: doc.data()['id'],
        type: doc.data()['type'],
        identifySituationsDate: doc.data()['identifySituationsDate']?.toDate(),
        hierarchyCompletedDate: doc.data()['hierarchyCompletedDate']?.toDate(),
        lastExerciseCompleted: doc.data()['lastExerciseCompleted']?.toDate(),
        bestDailyStreak: doc.data()['bestDailyStreak'],
        currentDailyStreak: doc.data()['currentDailyStreak'],
        identifySituationsSessionId: doc.data()['identifySituationsSessionId'],
        status: PatientStatus.values.firstWhere(
            (e) => e.toString() == 'PatientStatus.' + doc.data()['status']),
        exercises: []);
  }

  Exercise getExercise(String id) {
    print("get Exercise " + id);
    return exercises.firstWhere((element) => element.id == id, orElse: null);
  }

  int get completedExercises {
    int completed = 0;
    for (var exercise in exercises) {
      completed += exercise.status == ExerciseStatus.completed ? 1 : 0;
    }
    return completed;
  }

  @override
  List<Object> get props => [id, type, status];

  /// Returns a string representation of this object.
  @override
  bool get stringify => true;
}

/// The criteria by which a question is enabled.
enum PatientStatus {
  pretest_pending,
  pretest_in_progress,
  pretest_completed,
  identify_categories_pending,
  identify_situations_pending,
  hierarchy_pending,
  hierarchy_completed,
  in_exercise
}
