import 'package:cloud_firestore/cloud_firestore.dart';

// Question within a Questionnaire
class QuestionnaireItem {
  // Document id in firestore
  final String id;

  // Unique id for item in questionnaire
  final int linkId;

  // Primary text for the item
  final String text;

  // Whether the item must be included in data results
  final bool mandatory;

  // List of AND clauses that determine whether the question should be displayed or not
  final List enableWhenClauses;

  // Indicates data type for questions.
  final QuestionnaireItemType type;

  // Permitted answers. Only 'choice' and 'multiple-choice' items can have answerValueSet
  final List<AnswerValue> answerValueSet;

  // Captures the response of the user to a questionnaire item
  // Type of value vary depending upon the item type.
  dynamic answerValue;

  QuestionnaireItem({
    this.id,
    this.linkId,
    this.text,
    this.type,
    this.mandatory,
    this.enableWhenClauses,
    this.answerValueSet,
  });

  factory QuestionnaireItem.fromDocument(DocumentSnapshot doc) {
    return QuestionnaireItem(
      id: doc.documentID,
      linkId: doc['linkId'],
      type: QuestionnaireItemType.values.firstWhere(
          (e) => e.toString() == 'QuestionnaireItemType.' + doc['type']),
      text: doc['text'],
      mandatory: doc['mandatory'] ?? false,
      enableWhenClauses: doc['enableWhen'] != null
          ? doc['enableWhen']
              .map((answerValue) => EnableWhen.fromMap(answerValue))
              .toList()
              .cast<EnableWhen>()
          : [],
      answerValueSet: doc['answerValueSet'] != null
          ? doc['answerValueSet']
              .map((answerValue) => AnswerValue.fromMap(answerValue))
              .toList()
              .cast<AnswerValue>()
          : [],
    );
  }

  @override
  String toString() {
    return 'id: $id, type: $type, text: $text, mandatory: $mandatory';
  }
}

// Type of questionnaire item
enum QuestionnaireItemType {
  display,
  boolean,
  choice,
  multiple_choice,
  date,
  text
}

// Permitted answers for a questionnaire item
class AnswerValue {
  // Text for this permitted answer (computer friendly)
  final String value;

  //  Text for this permitted answer (human friendly)
  final String text;

  AnswerValue({
    this.value,
    this.text,
  });

  factory AnswerValue.fromMap(Map map) {
    return AnswerValue(
      value: map['value'],
      text: map['text'],
    );
  }
}

// AND clause that determines whether the question should be displayed or not
class EnableWhen {
  // Unique id for question that determines whether item is enabled
  final int linkId;

  // The criteria by which a question is enabled.
  final EnableWhenOperator comparator;

  //	Value for question comparison based on operator
  final dynamic value;

  EnableWhen({this.value, this.linkId, this.comparator});

  factory EnableWhen.fromMap(Map map) {
    return EnableWhen(
      value: map['value'],
      linkId: map['linkId'],
      comparator: EnableWhenOperator.values.firstWhere(
          (e) => e.toString() == 'EnableWhenOperator.' + map['operator']),
    );
  }
}

// The criteria by which a question is enabled.
enum EnableWhenOperator {
  equals,
  not_equals,
  greater,
  less,
  less_equals,
  greater_equals
}
