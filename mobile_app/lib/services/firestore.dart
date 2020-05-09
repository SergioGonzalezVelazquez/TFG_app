import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfg_app/models/questionnaire_group.dart';
import 'package:tfg_app/models/questionnaire_item.dart';
import 'package:tfg_app/services/auth.dart';

final signUpQuestionnaireRef =
    Firestore.instance.collection('pretest_questionnaire');
final signUpQuestionnaireResponseRef =
    Firestore.instance.collection('pretest_questionnaire_response');

final drivingActivityRef = Firestore.instance.collection('driving_activity');
final drivingEventDetailsRef =
    Firestore.instance.collection('driving_event_details');
final drivingRoutesRef = Firestore.instance.collection('driving_routes');

AuthService _authService = AuthService();

/// Get pretest questions
Future<List<QuestionnaireItemGroup>> getSignupQuestionnaire() async {
  // Get groups of questions
  QuerySnapshot snapshot = await signUpQuestionnaireRef
      .orderBy('index', descending: false)
      .getDocuments();

  List<QuestionnaireItemGroup> questionGroups = snapshot.documents
      .map((doc) => QuestionnaireItemGroup.fromDocument(doc))
      .toList();
  for (int i = 0; i < questionGroups.length; i++) {
    QuerySnapshot items = await signUpQuestionnaireRef
        .document(questionGroups[i].id.toString())
        .collection('questions')
        .orderBy("linkId", descending: false)
        .getDocuments();
    questionGroups[i].items = items.documents
        .map((item) => QuestionnaireItem.fromDocument(item))
        .toList();
  }

  return questionGroups;
}

/// create document on pretest_questionnaire_response collection for
/// current auth user
Future<void> createSignUpResponse() async {
  await signUpQuestionnaireResponseRef
      .document(_authService.user.id)
      .setData({"start_at": DateTime.now()});
}

/// add question response for current user document at
/// pretest_questionnaire_response collection
Future<void> addSignUpResponse(QuestionnaireItem item) async {
  await signUpQuestionnaireResponseRef
      .document(_authService.user.id)
      .updateData({item.id: item.answerValue});
}

/// delete question response in current user document at
/// pretest_questionnaire_response collection
Future<void> deleteSignUpResponse(QuestionnaireItem item) async {
  print("delete response para " + item.id);
  await signUpQuestionnaireResponseRef
      .document(_authService.user.id)
      .updateData({item.id: FieldValue.delete()});
}
