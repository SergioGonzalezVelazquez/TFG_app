import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfg_app/models/questionnaire_group.dart';
import 'package:tfg_app/models/questionnaire_item.dart';
import 'package:tfg_app/services/auth.dart';

final signUpQuestionnaireRef =
    Firestore.instance.collection('pretest_questionnaire');
final signUpQuestionnaireResponseRef =
    Firestore.instance.collection('pretest_questionnaire_response');

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
        .getDocuments();
    questionGroups[i].items = items.documents
        .map((item) => QuestionnaireItem.fromDocument(item))
        .toList();
  }

  return questionGroups;
}

Future<void> sendSignUpResponse(QuestionnaireItem item,
    {bool create = false}) async {
  if (create &&
      !(await signUpQuestionnaireResponseRef.document(user.id).get()).exists) {
    await signUpQuestionnaireResponseRef
        .document(user.id)
        .setData({item.id: item.answerValue});
  } else {
    await signUpQuestionnaireResponseRef
        .document(user.id)
        .updateData({item.id: item.answerValue});
  }
}
