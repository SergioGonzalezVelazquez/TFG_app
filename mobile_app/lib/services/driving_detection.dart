import 'dart:async';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Risky driving event detection service using the phone sensors.
/// If it is active, it will work on background to capture risky driving events and report back
/// to the driver at the end of the drive.
///
/// It detect the drive's starting location and time, and also the drive´s ending location and time,
/// without user intervention or input. It also provide accurately the vehicle`s las parked location.
class DrivingDetectionService {
  /// Flutter platform client used to invoke native Android code
  final MethodChannel _methodChannel =
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

  /// Request permissions and check their status.
  /// Returns true if all required permissions has been
  /// granted
  Future<bool> _askPermission() async {
    Map<Permission, PermissionStatus> statuses =
        await [Permission.locationAlways].request();
    print("statuses");
    print(statuses);
    bool granted = statuses.values
        .every((permission) => permission == PermissionStatus.granted);
    print("ask Permission: " + granted.toString());
    return granted;
  }

  /// Start AutoDriveDetection service in background
  Future<bool> startBackgroundService() async {
    bool permissions = await _askPermission();
    if (permissions) {
      await _methodChannel.invokeMethod('startDrivingDetectionService');
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("drive_detection_enabled", permissions);
    return permissions;
  }

  /// Stop AutoDriveDetection service
  Future<void> stopBackgroundService() async {
    await _methodChannel.invokeMethod('stopDrivingDetectionService');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("drive_detection_enabled", false);
  }

  /// Check if AutoDriveService is running
  Future<bool> isRunning() async {
    print("is Running?");
    return await _methodChannel
        .invokeMethod('isDrivingDetectionServiceRunning');
  }
}
