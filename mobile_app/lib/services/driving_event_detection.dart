/// Risky driving event detection service using the phone sensors.
/// If it is active, it will capture risky driving events and report back
/// to the driver at the end of the drive.
class DrivingEventDetection {
  DrivingEventDetection._();

  // Factory constructor which returns a singleton instance
  // of the service
  static final DrivingEventDetection _instance = DrivingEventDetection._();
  factory DrivingEventDetection() => _instance;
  bool _initialized = false;

  Future<void> init() async {
    if (!_initialized) {
      _initialized = true;
    }
  }

  void dispose() {
    _initialized = false;
  }

}