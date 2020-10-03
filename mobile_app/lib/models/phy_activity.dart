import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class PhyActivity extends Equatable {
  int heartRate;
  int intensity;
  Timestamp timestamp;

  /// Default class constructor
  PhyActivity({
    this.heartRate,
    this.intensity,
    this.timestamp,
  });

  factory PhyActivity.fromMap(Map<String, dynamic> map) {
    return PhyActivity(
      heartRate: map['heartRate'],
      intensity: map['intensity'],
      timestamp: map['timestamp'],
    );
  }

  @override
  List<Object> get props => [heartRate, intensity, timestamp];

  /// Returns a string representation of this object.
  @override
  bool get stringify => true;
}
