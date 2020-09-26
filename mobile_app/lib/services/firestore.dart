import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfg_app/models/driving_activity.dart';
import 'package:tfg_app/models/driving_event.dart';
import 'package:tfg_app/models/exercise.dart';
import 'package:tfg_app/models/exposure_exercise.dart';
import 'package:tfg_app/models/patient.dart';
import 'package:tfg_app/models/questionnaire_group.dart';
import 'package:tfg_app/models/questionnaire_item.dart';
import 'package:tfg_app/models/situation.dart';
import 'package:tfg_app/models/therapy.dart';
import 'dart:async';
import 'package:tfg_app/services/auth.dart';

/// Entry point for accesing firestore.
/// Gets the instance of Firestore for the default Firebase app
FirebaseFirestore database = FirebaseFirestore.instance;

/// Gets a CollectionReference for pretest_questionnaire path.
final signUpQuestionnaireRef = database.collection('pretest_questionnaire');

/// Gets a CollectionReference for pretest_questionnaire_response path.
final signUpQuestionnaireResponseRef =
    database.collection('pretest_questionnaire_response');

/// Gets a CollectionReference for pretest_questionnaire_response path.
final exposureRef = database.collection('exposure');

Stream<List<ExposureExercise>> getExposuresAsStream() {
  return FirebaseFirestore.instance
      .collection('exposure')
      .doc(_authService.user.id)
      .collection('exposures')
      .orderBy("start", descending: false)
      .get()
      .then((snapshot) {
    try {
      return snapshot.docs
          .map((doc) => ExposureExercise.fromDocument(doc))
          .toList();
    } catch (e) {
      print(e);
      return null;
    }
  }).asStream();
}

Stream<List<Exercise>> getExercisesAsStream() {
  String userId = _authService.user.id;
  String therapyId = _authService.user.patient.currentTherapy.id;

  return patientRef
      .doc(userId)
      .collection('userTherapies')
      .doc(therapyId)
      .collection('exercises')
      .orderBy("index", descending: false)
      .get()
      .then((snapshot) {
    try {
      return snapshot.docs.map((doc) => Exercise.fromDocument(doc)).toList();
    } catch (e) {
      print(e);
      return null;
    }
  }).asStream();
}

/// Gets Collection References for driving activity path.
final drivingActivityRef = database.collection('driving_activity');
final drivingEventRef = database.collection('driving_event_details');
final drivingRoutesRef = database.collection('driving_routes');

/// Gets Collection References for patient path.
final patientRef = database.collection('patient');

AuthService _authService = AuthService();

/// Get pretest questions
Future<List<QuestionnaireItemGroup>> getSignupQuestionnaire() async {
  // Get groups of questions
  QuerySnapshot snapshot =
      await signUpQuestionnaireRef.orderBy('index', descending: false).get();

  List<QuestionnaireItemGroup> questionGroups = snapshot.docs
      .map((doc) => QuestionnaireItemGroup.fromDocument(doc))
      .toList();
  for (int i = 0; i < questionGroups.length; i++) {
    QuerySnapshot items = await signUpQuestionnaireRef
        .doc(questionGroups[i].id.toString())
        .collection('questions')
        .orderBy("linkId", descending: false)
        .get();
    questionGroups[i].items =
        items.docs.map((item) => QuestionnaireItem.fromDocument(item)).toList();
  }

  return questionGroups;
}

/// create doc on pretest_questionnaire_response collection for
/// current auth user
Future<void> createSignUpResponse() async {
  await signUpQuestionnaireResponseRef
      .doc(_authService.user.id)
      .set({"start_at": DateTime.now()});
}

/// delete doc on pretest_questionnaire_response collection for
/// current auth user
Future<void> deleteSignUpResponse() async {
  await signUpQuestionnaireResponseRef.doc(_authService.user.id).delete();
}

/// add question response for current user doc at
/// pretest_questionnaire_response collection
Future<void> addSignUpResponse(QuestionnaireItem item) async {
  await signUpQuestionnaireResponseRef
      .doc(_authService.user.id)
      .update({item.id: item.answerValue});
}

/// delete question response in current user doc at
/// pretest_questionnaire_response collection
Future<void> deleteSignUpResponseItem(QuestionnaireItem item) async {
  print("delete response para " + item.id);
  await signUpQuestionnaireResponseRef
      .doc(_authService.user.id)
      .update({item.id: FieldValue.delete()});
}

Future<void> createExposureExercise(ExposureExercise exposure) async {
  await exposureRef
      .doc(_authService.user.id)
      .collection('exposures')
      .doc()
      .set(exposure.toMap());
}

Future<void> updateExerciseStatus(String id, ExerciseStatus newStatus) async {
  String userId = _authService.user.id;
  String therapyId = _authService.user.patient.currentTherapy.id;

  await patientRef
      .doc(userId)
      .collection('userTherapies')
      .doc(therapyId)
      .collection('exercises')
      .doc(id)
      .update({'status': newStatus.toString().split('.')[1]});
}

Future<void> updateExercise(String id, Map<String, dynamic> data) async {
  String userId = _authService.user.id;
  String therapyId = _authService.user.patient.currentTherapy.id;

  await patientRef
      .doc(userId)
      .collection('userTherapies')
      .doc(therapyId)
      .collection('exercises')
      .doc(id)
      .update(data);
}

Future<List<ExposureExercise>> getExerciseExposures(String exerciseId) async {
  List<ExposureExercise> exposures = [];
  QuerySnapshot snapshot = await exposureRef
      .doc(_authService.user.id)
      .collection('exposures')
      .where("exerciseId", isEqualTo: exerciseId)
      .orderBy("start", descending: false)
      .get();

  exposures =
      snapshot.docs.map((doc) => ExposureExercise.fromDocument(doc)).toList();

  return exposures;
}

Future<Therapy> getPatientCurrentTherapy() async {
  String userId = _authService.user.id;
  QuerySnapshot docs = await patientRef
      .doc(userId)
      .collection('userTherapies')
      .where("active", isEqualTo: true)
      .get();

  return Therapy.fromDocument(docs.docs[0]);
}

Future<List<Exercise>> getPatientExercises() async {
  String userId = _authService.user.id;
  String therapyId = _authService.user.patient.currentTherapy.id;
  List<Exercise> exercises = [];

  QuerySnapshot docs = await patientRef
      .doc(userId)
      .collection('userTherapies')
      .doc(therapyId)
      .collection('exercises')
      .orderBy('index')
      .get();

  if (docs.docs.isNotEmpty) {
    exercises = docs.docs.map((doc) => Exercise.fromDocument(doc)).toList();
  }
  return exercises;
}

Future<void> setHierarchy(List<Situation> situation) async {
  List<Map<String, dynamic>> hierarchy = [];

  situation.forEach((element) {
    hierarchy.add(element.toMap());
  });

  String userId = _authService.user.id;
  String therapyId = _authService.user.patient.currentTherapy.id;
  await patientRef
      .doc(userId)
      .collection('userTherapies')
      .doc(therapyId)
      .update({'situations': hierarchy});

  await _authService.updatePatientStatus(PatientStatus.hierarchy_completed);
}

/// fetch questionnaire response and set each answer to it question.
/// It is used when user has a questionnaire in progress
Future<Map<String, dynamic>> getQuestionnaireResponses() async {
  DocumentSnapshot doc =
      await signUpQuestionnaireResponseRef.doc(_authService.user.id).get();

  return doc.exists ? doc.data() : null;
}

Future<List<DrivingActivity>> getDrivingActivities() async {
  QuerySnapshot activitiesDocs = await drivingActivityRef
      .doc(_authService.user.id)
      .collection('user_driving_activity')
      .get();

  return activitiesDocs.docs
      .map((doc) => DrivingActivity.fromDocument(doc))
      .toList();
}

Future<List<dynamic>> getDrivingRoutes(String driveId) async {
  DocumentSnapshot doc = await drivingRoutesRef.doc(driveId).get();
  List<dynamic> list = [];
  if (doc.exists) {
    return doc.data()['route'];
  }
  return list;
}

Future<List<DrivingEvent>> getDrivingEvents(String driveId) async {
  DocumentSnapshot doc = await drivingEventRef.doc(driveId).get();
  List<DrivingEvent> list = [];
  if (doc.exists) {
    doc.data()['events'].forEach((event) {
      print(event);
      list.add(DrivingEvent.fromMap(event));
    });
  }
  return list;
}
