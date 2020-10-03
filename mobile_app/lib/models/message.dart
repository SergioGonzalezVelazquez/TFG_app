import 'package:equatable/equatable.dart';

/// A 'UserMessage' contains basic details of a message
/// sent by the user to the agent.
class UserMessage extends Equatable {
  /// instance attributes
  String id;
  DateTime timestamp;
  String text;

  /// default constructor
  UserMessage(this.text, {this.id, this.timestamp}) {
    if (timestamp == null) timestamp = DateTime.now();
  }

  @override
  List<Object> get props => [text, timestamp, id];

  /// Returns a string representation of this object.
  @override
  bool get stringify => true;
}

enum MessageSource {
  user,
  bot,
}
