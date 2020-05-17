import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter/material.dart';
import 'package:tfg_app/models/driving_activity.dart';
import 'package:tfg_app/models/driving_event.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tfg_app/models/phy_activity.dart';
import 'package:tfg_app/services/firestore.dart';
import 'package:tfg_app/services/phy_activity_service.dart';
import 'package:tfg_app/widgets/hear_rate_chart.dart';
import 'package:tfg_app/widgets/progress.dart';

class DrivingActivityDetails extends StatefulWidget {
  final DrivingActivity _activity;
  DrivingActivityDetails(this._activity);

  @override
  State<DrivingActivityDetails> createState() => DrivingActivityDetailsState();
}

class DrivingActivityDetailsState extends State<DrivingActivityDetails> {
  /// GoogleMaps camera
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  bool _isLoading = true;

  PhyActivityService _phyActivityService = PhyActivityService();

  // List of phyActivities from 5 minutes before start driving until 5 minutes after finishing driving
  List<PhyActivity> _heartRate;

  // key/value pair used to map each PhyActivity object with it hh:mm time (key)
  Map<String, PhyActivity> _timeHeartRate = new Map();

  List<DrivingEvent> _eventsData;

  @override
  void initState() {
    super.initState();
    // Get all the driving routes inside the mLocationList
    _buildDrivingRoute();
  }

  Future<void> _getHeartRate() async {
    List<PhyActivity> result = [];
    Map<String, PhyActivity> timeHeartRateMap = new Map();

    if (widget._activity.endTime != null) {
      // Get heart rate 5 minutes before start driving, and 5 minutes after.
      DateTime dateFrom = widget._activity.startTime.toDate();
      dateFrom = dateFrom.subtract(Duration(minutes: 5));
      DateTime dateTo = widget._activity.endTime.toDate();
      dateTo = dateTo.add(Duration(minutes: 5));

      result = await _phyActivityService.read(dateFrom, dateTo, fillWithNull: true);

      // Build map with pair of time (hh:mm)-PhyActicity object
      result.forEach((item) {
        DateTime time = item.timestamp.toDate().toLocal();
        print(item.toString());
        String roundMinute =
            (time.second < 30 ? time.minute : time.minute + 1).toString();
        String hour = time.hour.toString() + ":" + roundMinute;

        timeHeartRateMap[hour] = item;
      });

      print("keys");
      print(timeHeartRateMap.keys);
    }

    setState(() {
      _timeHeartRate = timeHeartRateMap;
      _heartRate = result;
    });
  }

  Color _buildLocationColor(Timestamp timestamp) {
    DateTime time = timestamp.toDate().toLocal();
    String roundMinute =
        (time.second < 30 ? time.minute : time.minute + 1).toString();
    String hour = time.hour.toString() + ":" + roundMinute;

    if (!_timeHeartRate.containsKey(hour)) {
      return Colors.grey;
    }

    PhyActivity activity = _timeHeartRate[hour];
    if (activity.heartRate < 80) {
      return Colors.green;
    } else if (activity.heartRate < 100) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Future<void> _buildDrivingRoute() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Check on shared preferences if user has phyActivity enabled
    bool phyActivity = prefs.getBool("phy_activity_enabled");

    if (phyActivity) {
      await _getHeartRate();
    }

    //_locationList = await getDrivingRoutes(widget._activity.id);
    List locationData = await getDrivingRoutes(widget._activity.id);
    _eventsData = await getDrivingEvents(widget._activity.id);
    int sizeLocationDataList = locationData.length - 1;

    for (int i = 0; i < sizeLocationDataList; i++) {
      LatLng point1 = new LatLng(locationData[i]['location'].latitude,
          locationData[i]['location'].longitude);
      LatLng point2 = new LatLng(locationData[i + 1]['location'].latitude,
          locationData[i + 1]['location'].longitude);

      _polylines.add(
        Polyline(
          color: phyActivity
              ? _buildLocationColor(locationData[i]['timestamp'])
              : Theme.of(context).primaryColor,
          visible: true,
          width: 4,
          geodesic: true,
          points: [point1, point2],
          polylineId: PolylineId(locationData[i]['time'].toString()),
        ),
      );
    }
    // Add start driving marker
    _markers.add(
      Marker(
        markerId: MarkerId("driving-start"),
        infoWindow: InfoWindow(
            title: "Comienzo de la conducción",
            snippet: widget._activity.startLocationDetails.formattedAddress),
        position: LatLng(widget._activity.startLocation.latitude,
            widget._activity.startLocation.longitude),
      ),
    );

    setState(() {
      _isLoading = false;
    });
  }

  String _printDuration() {
    String duration = '';
    if (widget._activity.endTime != null) {
      Duration duration = widget._activity.endTime
          .toDate()
          .difference(widget._activity.startTime.toDate());
      return duration.inMinutes.toString() + " min";
    }

    return duration;
  }

  /// Time series chart with range annotation for heart rate
  Widget _buildHeartRateChart(BuildContext context) {
    // list which is what will define what data goes into the graph
    List<Widget> childs;
    if (_heartRate == null || _heartRate.isEmpty) {
      childs = [Text("No hay disponibles datos de frecuencia cardiaca")];
    } else {
      Map<String, int> result = _phyActivityService.calculateMinMaxMedian(_heartRate);
      int max = result['max'];
      int median = result['median'];
      int min = result['min'];

      childs = [
        Container(
          height: 200,
          child: HeartRateChart.withHeartRateData(
            _heartRate,
            widget._activity.startTime.toDate(),
            widget._activity.endTime.toDate(),
            rangeAnnotationStart: widget._activity.startTime.toDate(),
            rangeAnnotationEnd: widget._activity.endTime.toDate(),
          ),
        ),
        SizedBox(
          height: 15,
        ),
        SizedBox(
          height: 15,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _detailsItem(context, "BPM máximo", max.toString()),
            _detailsItem(context, "BPM mínimo", min.toString()),
            _detailsItem(context, "BPM promedio", median.toString()),
          ],
        ),
      ];
    }
    return Column(
      children: childs,
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  /// Initialize Google Maps setting the UI properties, such as zoom control,
  /// zoom gesture, and rotation gesture.
  Widget _buildMap() {
    return SlidingUpPanel(
      // Slider line
      header: Container(
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.center,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.1,
          child: Divider(
            color: Colors.black38,
            thickness: 1.2,
          ),
        ),
      ),
      backdropEnabled: true,
      maxHeight: MediaQuery.of(context).size.height * 0.85,
      minHeight: MediaQuery.of(context).size.height * 0.15,
      borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(10.0),
          topRight: const Radius.circular(10.0)),
      panelBuilder: (ScrollController sc) => _buildDetails(context, sc),
      body: GoogleMap(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.2),
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: LatLng(widget._activity.startLocation.latitude,
              widget._activity.startLocation.longitude),
          zoom: 14.4746,
        ),
        markers: _markers,
        polylines: _polylines,
      ),
    );
  }

  Widget _buildDetails(BuildContext context, ScrollController sc) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.03,
          horizontal: MediaQuery.of(context).size.width * 0.05),
      child: ListView(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _detailsItem(context, "Duración", _printDuration()),
              _detailsItem(
                context,
                "Distancia",
                (widget._activity.distance / 1000).toStringAsFixed(1) + " km",
              ),
              _detailsItem(context, "Eventos", _eventsData.length.toString())
            ],
          ),
          Divider(
            height: 30,
            color: Theme.of(context).primaryColor,
            thickness: 1.3,
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            "Ritmo cardiaco durante la conducción (BPM)",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 15,
          ),
          _buildHeartRateChart(context),
          Divider(
            height: 30,
            color: Theme.of(context).primaryColor,
            thickness: 1.3,
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            "Eventos significativos",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }

  Widget _detailsItem(BuildContext context, String title, String value) {
    return Column(
      children: <Widget>[
        Text(
          value,
          style: Theme.of(context).textTheme.headline6,
        ),
        Text(title)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            _isLoading
                ? Center(
                    child: circularProgress(context, text: "Recuperando ruta"))
                : _buildMap(),
            new Positioned(
              top: 0.0,
              left: 0.0,
              child: new IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: () => Navigator.of(context).pop()),
            )
          ],
        ),
      ),
    );
  }
}
