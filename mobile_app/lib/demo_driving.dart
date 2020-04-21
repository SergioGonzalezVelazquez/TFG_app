import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tfg_app/widgets/buttons.dart';

class DemoDrivingPage extends StatefulWidget {
  DemoDrivingPage({Key key}) : super(key: key);

  /// Creates a StatelessElement to manage this widget's location in the tree.
  _DemoDrivingPageState createState() => _DemoDrivingPageState();
}

class _DemoDrivingPageState extends State<DemoDrivingPage> {
  StreamController _activityStreamController = StreamController();
  StreamSubscription _activityUpdateStreamSubscription;
  Duration oneSec = const Duration(seconds: 1);

  static const MethodChannel _methodChannel =
      const MethodChannel('driving_detection/methodChannel');

  static const EventChannel _eventChannel =
      const EventChannel('driving_detection/activityUpdates');
  List messages = [];
  bool enabledAutoDetectionService = false;
  bool enabledEventDetectionService = false;
  Timer timer;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(Duration(seconds: 60), (Timer t) => _isRunning());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> _startBackground() async {
    if (_activityUpdateStreamSubscription != null) return;

    if (Platform.isAndroid) {
      _activityUpdateStreamSubscription = _eventChannel
          .receiveBroadcastStream()
          .listen(_onActivityUpdateReceived);

      _methodChannel.invokeMethod('startDrivingDetectionService');
    }

    setState(() {
      enabledAutoDetectionService = true;
    });
  }

  Future<void> _isRunning() async {
    print("is Running?");
    if (Platform.isAndroid) {
      bool autoDrive =
          await _methodChannel.invokeMethod('isDrivingDetectionServiceRunning');
      bool eventService =
          await _methodChannel.invokeMethod('isEventDetectionServiceRunning');
      setState(() {
        enabledAutoDetectionService = autoDrive;
        enabledEventDetectionService = eventService;
      });
    }
  }

  Future<void> _stopBackground() async {
    if (Platform.isAndroid) {
      String data =
          await _methodChannel.invokeMethod('stopDrivingDetectionService');
      if (_activityUpdateStreamSubscription != null) {
        _activityUpdateStreamSubscription.cancel();
        _activityUpdateStreamSubscription = null;
      }
      print(data);
    }
    setState(() {
      enabledAutoDetectionService = false;
    });
  }

  void _onActivityUpdateReceived(dynamic activity) {
    print("Flutter: onActivityUpdateReceived");
    DateTime date = DateTime.now();
    setState(() {
      messages.insert(
          0,
          Text(
            date.toString() + " :" + activity,
            style: TextStyle(fontSize: 10),
          ));
    });
  }

  Widget _buildPage() {
    return new Scaffold(
      bottomNavigationBar: null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  child: ListView.builder(
                      padding: EdgeInsets.all(8.0),
                      reverse: true,
                      itemBuilder: (_, int index) => messages[index],
                      itemCount: messages.length),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width * 0.35,
                      child: primaryButton(
                          context,
                          enabledAutoDetectionService ? null : _startBackground,
                          "Start"),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.35,
                      child: primaryButton(
                          context,
                          !enabledAutoDetectionService ? null : _stopBackground,
                          "Stop"),
                    ),
                  ],
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width * 0.35,
                        child:
                            primaryButton(context, _isRunning, "Check status"),
                      ),
                      Column(
                        children: <Widget>[
                          Text(
                            "AutoDriveService: " +
                                (enabledAutoDetectionService
                                    ? 'running'
                                    : 'stopped'),
                            style: TextStyle(
                                fontSize: 11,
                                color: enabledAutoDetectionService
                                    ? Colors.green
                                    : Colors.red),
                          ),
                          Text(
                            "EventDetectionService: " +
                                (enabledEventDetectionService
                                    ? 'running'
                                    : 'stopped'),
                            style: TextStyle(
                                fontSize: 11,
                                color: enabledEventDetectionService
                                    ? Colors.green
                                    : Colors.red),
                          ),
                        ],
                      )
                    ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildPage();
  }
}
