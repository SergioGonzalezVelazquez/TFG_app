import 'package:cloud_firestore/cloud_firestore.dart';

class PhyActivity {
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
  String toString() {
    return 'heartRate: $heartRate,  intensity:$intensity, timestamp: ${timestamp.toDate().toString()}';
  }
}
