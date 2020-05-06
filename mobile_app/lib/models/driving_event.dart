import 'package:cloud_firestore/cloud_firestore.dart';

class DrivingEvent {
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
          .firstWhere((e) => e.toString() == 'DrivingEventType.' + map['type']),
/*
                acceleration:
          map['acceleration'] != null ? double.parse(map['acceleration']) : 0,
      drivingSpeed:
          map['driving_speed'] != null ? double.parse(map['driving_speed']) : 0,
*/
    );
  }

  @override
  String toString() {
    return 'type: ${type.toString()}, latitude: ${location.latitude}, longitude: ${location.longitude}, time: ${timestamp.toDate().toIso8601String()}';
  }
}

enum DrivingEventType {
  PHONE_DISTRACTION,
  HARD_TURN,
  HARD_ACCELERATION,
  HARD_BRAKING,
  SPEEDING,
  PARKING
}
