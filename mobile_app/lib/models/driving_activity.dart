import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class DrivingActivity extends Equatable {
  final String id;
  final Timestamp startTime;
  final Timestamp endTime;
  final GeoPoint startLocation;
  final GeoPoint endLocation;
  final int distance;
  final LocationDetails startLocationDetails;
  final LocationDetails endLocationDetails;

  DrivingActivity(
      {this.id,
      this.distance,
      this.startTime,
      this.startLocation,
      this.endLocationDetails,
      this.endTime,
      this.endLocation,
      this.startLocationDetails});

  factory DrivingActivity.fromDocument(DocumentSnapshot doc) {
    return DrivingActivity(
      id: doc.id,
      distance: doc.data()['distance'] ?? 0,
      startTime: doc.data()['start_time'],
      startLocation: doc.data()['start_location'],
      startLocationDetails: (doc.data()['start_location_details'] != null)
          ? LocationDetails.fromMap(doc.data()['start_location_details'])
          : null,
      endTime: doc.data()['end_time'],
      endLocation: doc.data()['end_location'],
      endLocationDetails: (doc.data()['end_location_details'] != null)
          ? LocationDetails.fromMap(doc.data()['end_location_details'])
          : null,
    );
  }

  @override
  String toString() {
    return 'id: $id, startAt: ${startTime.toDate().toIso8601String()}';
  }

  @override
  List<Object> get props => [id, startTime, endTime, distance];

  /// Returns a string representation of this object.
  @override
  bool get stringify => true;
}

class LocationDetails extends Equatable {
  final String city;
  final String country;
  final String countryCode;
  final String formattedAddress;
  final String provider;
  final double latitude;
  final double longitude;

  LocationDetails(
      {this.city,
      this.country,
      this.countryCode,
      this.formattedAddress,
      this.provider,
      this.latitude,
      this.longitude});

  factory LocationDetails.fromMap(Map map) {
    return LocationDetails(
      city: map['city'],
      country: map['country'],
      countryCode: map['countryCode'],
      formattedAddress: map['formattedAddress'],
      provider: map['provider'],
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }

  @override
  List<Object> get props => [
        city,
        country,
        countryCode,
        formattedAddress,
        provider,
        latitude,
        longitude
      ];

  /// Returns a string representation of this object.
  @override
  bool get stringify => true;
}
