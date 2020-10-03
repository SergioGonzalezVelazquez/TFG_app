// ignore_for_file: constant_identifier_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class DrivingEvent extends Equatable {
  final Timestamp timestamp;
  final GeoPoint location;
  final bool isFused;
  final double acceleration;
  final double drivingSpeed;
  final DrivingEventType type;

  DrivingEvent(
      {this.timestamp,
      this.location,
      this.isFused,
      this.acceleration,
      this.drivingSpeed,
      this.type});

  factory DrivingEvent.fromMap(Map<String, dynamic> map) {
    return DrivingEvent(
      timestamp: map['timestamp'],
      location: map['location'],
      isFused: map['isFused'],
      type: DrivingEventType.values
          .firstWhere((e) => e.toString() == 'DrivingEventType.${map['type']}'),
    );
  }

  @override
  String toString() {
    return """type: ${type.toString()}, latitude: ${location.latitude}, 
      longitude: ${location.longitude}, 
      time: ${timestamp.toDate().toIso8601String()}""";
  }

  @override
  List<Object> get props =>
      [type, location.latitude, location.longitude, timestamp];

  /// Returns a string representation of this object.
  @override
  bool get stringify => true;
}

enum DrivingEventType {
  PHONE_DISTRACTION,
  HARD_TURN,
  HARD_ACCELERATION,
  HARD_BRAKING,
  SPEEDING,
  PARKING
}
