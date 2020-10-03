import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'questionnaire_item.dart';

class QuestionnaireItemGroup extends Equatable {
  final String id;
  final String name;
  final int index;
  List<QuestionnaireItem> items;

  QuestionnaireItemGroup({this.id, this.name, this.index, this.items});

  factory QuestionnaireItemGroup.fromDocument(DocumentSnapshot doc) {
    return QuestionnaireItemGroup(
      id: doc.id,
      index: doc.data()['index'],
      name: doc.data()['name'],
      items: [],
    );
  }

  @override
  String toString() {
    return 'id: $id, index: $index, name: $name';
  }

  @override
  List<Object> get props => [id, index, name];

  /// Returns a string representation of this object.
  @override
  bool get stringify => true;
}
