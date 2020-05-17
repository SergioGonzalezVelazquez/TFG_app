import 'package:cloud_firestore/cloud_firestore.dart';

class Patient {
  final String id;
  final String type;
  final Timestamp createdAt;
  final PatientStatus status;

  /// Default class constructor
  Patient({this.id, this.type, this.createdAt, this.status});

  /// Converts Firestore Document into a User object
  factory Patient.fromDocument(DocumentSnapshot doc) {
    return Patient(
      id: doc['id'],
      type: doc['type'],
      createdAt: doc['created_at'],
      status: PatientStatus.values
          .firstWhere((e) => e.toString() == 'PatientStatus.' + doc['status']),
    );
  }

  /// Returns a string representation of this object.
  @override
  String toString() {
    return 'id: $id, type: $type, createdAt: ${createdAt.toDate().toIso8601String()}';
  }
}

/// The criteria by which a question is enabled.
enum PatientStatus {
  pretest_pending,
  pretest_in_progress,
  pretest_completed,
  identify_categories_pending,
  identify_categories_in_progress,
  identify_situations_pending,
  identify_situations_in_progress
}
