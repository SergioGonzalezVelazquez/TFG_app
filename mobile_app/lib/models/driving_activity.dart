import 'package:cloud_firestore/cloud_firestore.dart';

class DrivingActivity {
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
      id: doc.documentID,
      distance: doc['distance'] ?? 0,
      startTime: doc['start_time'],
      startLocation: doc['start_location'],
      startLocationDetails: (doc['start_location_details'] != null)
          ? LocationDetails.fromMap(doc['start_location_details'])
          : null,
      endTime: doc['end_time'],
      endLocation: doc['start_location'],
      endLocationDetails: (doc['end_location_details'] != null)
          ? LocationDetails.fromMap(doc['end_location_details'])
          : null,
    );
  }

  @override
  String toString() {
    return 'id: $id, startAt: ${startTime.toDate().toIso8601String()}';
  }
}

class LocationDetails {
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

  factory LocationDetails.fromMap(Map doc) {
    return LocationDetails(
      city: doc['city'],
      country: doc['country'],
      countryCode: doc['countryCode'],
      formattedAddress: doc['formattedAddress'],
      provider: doc['provider'],
      latitude: doc['latitude'],
      longitude: doc['longitude'],
    );
  }
}
