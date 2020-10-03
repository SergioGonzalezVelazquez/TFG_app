import 'dart:async';

import 'package:flutter/services.dart';

class BluetoothService {
  /// Flutter platform client used to invoke native Android code
  final MethodChannel _methodChannel =
      const MethodChannel('driving_detection/methodChannel');

  // Factory constructor which returns a singleton instance
  // of the service
  BluetoothService._();
  static final BluetoothService _instance = BluetoothService._();
  factory BluetoothService() => _instance;
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
