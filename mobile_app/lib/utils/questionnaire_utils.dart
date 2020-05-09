import 'package:tfg_app/models/questionnaire_item.dart';
import 'package:tfg_app/services/firestore.dart';

// Calculate next enable question in a list of questions,
// based on its enableWhen clauses and it current answer.
// Returns -1 if there are not more active questions
int getNextEnableQuestion(List<QuestionnaireItem> items, int currentIndex) {
  for (int i = currentIndex + 1; i < items.length; i++) {
    if (evaluteItemEnableWhen(items[i], items)) {
      return items[i].linkId;
    } 
  }

  return -1;
}

// Calculate previous enable question in a list of questions,
// based on its enableWhen clauses and it current answer.
// Returns -1 if there are not previous active questions
int getPreviousEnableQuestion(List<QuestionnaireItem> items, int currentIndex) {
  for (int i = currentIndex - 1; i >= 0; i--) {
    if (evaluteItemEnableWhen(items[i], items)) {
      return items[i].linkId;
    } 
  }
  return -1;
}

bool evaluteItemEnableWhen(
    QuestionnaireItem item, List<QuestionnaireItem> items) {
  //If question has not enable when clauses, show it
  if (item.enableWhenClauses.isEmpty) return true;

  // If question has a single clause, evaluate it
  if (item.enableWhenClauses.length == 1) {
    EnableWhen clause = item.enableWhenClauses[0];
    QuestionnaireItem itemToCompare = items[clause.linkId - 1];
    if (itemToCompare == null ||
        !evalueEnableWhenClause(clause, itemToCompare.answerValue)) {
      return false;
    }
  }
  //If question has mutiple clauses (AND), evaluate all of them.
  else {
    for (int i = 0; i < item.enableWhenClauses.length; i++) {
      EnableWhen clause = item.enableWhenClauses[i];
      QuestionnaireItem itemToCompare = items[clause.linkId - 1];
      if (itemToCompare == null ||
          !evalueEnableWhenClause(clause, itemToCompare.answerValue)) {
        return false;
      }
    }
  }

  return true;
}

bool evalueEnableWhenClause(EnableWhen clause, dynamic value) {
  print("evaluador con value ");
  print(value);
  switch (clause.comparator) {
    case EnableWhenOperator.equals:
      return value == clause.value;
      break;
    case EnableWhenOperator.not_equals:
      return value != clause.value;
      break;
    case EnableWhenOperator.contained_in:
      return clause.value.contains(value);
      break;
    case EnableWhenOperator.not_contained_in:
      return !(clause.value.contains(value));
      break;
  }
  return false;
}

/// Used when a question answer is updated. For next questions in items lists,
/// look for questions which depends on updated question and delete them answer
void evaluateAndDeleteAnswers(
    QuestionnaireItem updatedItem, List<QuestionnaireItem> items) {
  List<QuestionnaireItem> subList = items.sublist(updatedItem.linkId);
  subList.forEach((element) {
    if (element.answerValue != null && element.enableWhenClauses.isNotEmpty) {
      for (EnableWhen clause in element.enableWhenClauses) {
        if (clause.linkId == updatedItem.linkId) {
          if (!evalueEnableWhenClause(clause, updatedItem.answerValue)) {
            element.deleteAnswer();
            deleteSignUpResponse(element);
          }
        }
      }
    } 
  });
}
