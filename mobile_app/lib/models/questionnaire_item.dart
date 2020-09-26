import 'package:cloud_firestore/cloud_firestore.dart';

/// Question within a Questionnaire
class QuestionnaireItem {
  /// Document id in firestore
  final String id;

  /// Unique id for item in questionnaire
  final int linkId;

  /// Primary text for the item
  final String text;

  /// Whether the item must be included in data results
  final bool mandatory;

  /// List of AND clauses that determine whether the question should be displayed or not
  final List enableWhenClauses;

  /// Indicates data type for questions.
  final QuestionnaireItemType type;

  /// Permitted answers. Only 'choice' and 'multiple-choice' items can have answerValueSet
  final List<AnswerValue> answerValueSet;

  /// Captures the response of the user to a questionnaire item
  /// Type of value vary depending upon the item type.
  dynamic _answerValue;

  /// Check if the answer has been updated by the user
  bool _updated = false;

  /// Getters used to retrieve the values of class fields
  dynamic get answerValue => this._answerValue;
  bool get updated => this._updated;

  /// Setters used to initialize the values of class fields
  set answerValue(dynamic value) {
    this._updated = this._answerValue != null && this._answerValue != value;
    this._answerValue = value;
  }

  /// Mark question answer as deleted (null)
  void deleteAnswer() {
    this._answerValue = null;
    this._updated = false;
  }

  /// Default class constructor
  QuestionnaireItem({
    this.id,
    this.linkId,
    this.text,
    this.type,
    this.mandatory,
    this.enableWhenClauses,
    this.answerValueSet,
  });

  /// Converts Firestore Document into a QuestionnaireItem object
  factory QuestionnaireItem.fromDocument(DocumentSnapshot doc) {
    return QuestionnaireItem(
      id: doc.id,
      linkId: doc.data()['linkId'],
      type: QuestionnaireItemType.values.firstWhere(
          (e) => e.toString() == 'QuestionnaireItemType.' + doc.data()['type']),
      text: doc.data()['text'],
      mandatory: doc.data()['mandatory'] ?? false,
      enableWhenClauses: doc.data()['enableWhen'] != null
          ? doc.data()['enableWhen']
              .map((answerValue) => EnableWhen.fromMap(answerValue))
              .toList()
              .cast<EnableWhen>()
          : [],
      answerValueSet: doc.data()['answerValueSet'] != null
          ? doc.data()['answerValueSet']
              .map((answerValue) => AnswerValue.fromMap(answerValue))
              .toList()
              .cast<AnswerValue>()
          : [],
    );
  }

  /// Returns a string representation of this object.
  @override
  String toString() {
    return 'id: $id, type: $type, text: $text, mandatory: $mandatory';
  }
}

/// Type of questionnaire item
enum QuestionnaireItemType {
  boolean,
  choice,
  multiple_choice,
  slider
}

/// Permitted answers for a questionnaire item
class AnswerValue {
  /// Text for this permitted answer (computer friendly)
  final String value;

  ///  Text for this permitted answer (human friendly)
  final String text;

  /// Default class constructor
  AnswerValue({
    this.value,
    this.text,
  });

  /// Converts Firestore Document into a AnswerValue object
  factory AnswerValue.fromMap(Map map) {
    return AnswerValue(
      value: map['value'],
      text: map['text'],
    );
  }
}

/// AND clause that determines whether the question should be displayed or not
class EnableWhen {
  /// Unique id for question that determines whether item is enabled
  final int linkId;

  /// The criteria by which a question is enabled.
  final EnableWhenOperator comparator;

  //	Value for question comparison based on operator
  final dynamic value;

  /// Default class constructor
  EnableWhen({this.value, this.linkId, this.comparator});

  /// Converts Firestore Document into a EnableWhen object
  factory EnableWhen.fromMap(Map map) {
    return EnableWhen(
      value: map['value'],
      linkId: map['linkId'],
      comparator: EnableWhenOperator.values.firstWhere(
          (e) => e.toString() == 'EnableWhenOperator.' + map['operator']),
    );
  }
}

/// The criteria by which a question is enabled.
enum EnableWhenOperator { equals, not_equals, contained_in, not_contained_in }
