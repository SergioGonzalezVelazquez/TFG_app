import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfg_app/models/exercise.dart';
import 'package:tfg_app/models/therapy.dart';

class Patient {
  final String id;
  final String type;
  final PatientStatus status;
  final DateTime identifySituationsDate;
  final DateTime hierarchyCompletedDate;
  final String identifySituationsSessionId;
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
      this.identifySituationsSessionId});

  /// Converts Firestore Document into a User object
  factory Patient.fromDocument(DocumentSnapshot doc) {
    return Patient(
        id: doc['id'],
        type: doc['type'],
        identifySituationsDate: doc['identifySituationsDate']?.toDate(),
        hierarchyCompletedDate: doc['hierarchyCompletedDate']?.toDate(),
        identifySituationsSessionId: doc['identifySituationsSessionId'],
        status: PatientStatus.values.firstWhere(
            (e) => e.toString() == 'PatientStatus.' + doc['status']),
        exercises: []);
  }

  /// Returns a string representation of this object.
  @override
  String toString() {
    return 'id: $id, type: $type, status: ${status.toString().split(".")[1]}';
  }
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
