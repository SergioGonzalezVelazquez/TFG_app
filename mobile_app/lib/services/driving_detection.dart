import 'dart:async';

import 'package:flutter/services.dart';

/// Risky driving event detection service using the phone sensors.
/// If it is active, it will work on background to capture risky driving events and report back
/// to the driver at the end of the drive.
///
/// It detect the drive's starting location and time, and also the drive´s ending location and time,
/// without user intervention or input. It also provide accurately the vehicle`s las parked location.
class DrivingDetectionService {
  /// Flutter platform client used to invoke native Android code
  MethodChannel _methodChannel =
      const MethodChannel('driving_detection/methodChannel');

  // Factory constructor which returns a singleton instance
  // of the service
  DrivingDetectionService._();
  static final DrivingDetectionService _instance = DrivingDetectionService._();
  factory DrivingDetectionService() => _instance;
  bool _initialized = false;

  Future<void> init() async {
    if (!_initialized) {
      _initialized = true;
    }
  }

  void dispose() {
    _initialized = false;
  }

  /// Start AutoDriveDetection service in background
  Future<void> startBackgroundService() async {
    await _methodChannel.invokeMethod('startDrivingDetectionService');
  }
}
