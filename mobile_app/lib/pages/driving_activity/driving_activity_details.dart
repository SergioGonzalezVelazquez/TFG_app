import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../models/driving_activity.dart';
import '../../models/driving_event.dart';
import '../../models/phy_activity.dart';
import '../../services/firestore.dart';
import '../../services/phy_activity_service.dart';
import '../../widgets/hear_rate_chart.dart';
import '../../widgets/progress.dart';

class DrivingActivityDetails extends StatefulWidget {
  final DrivingActivity _activity;
  DrivingActivityDetails(this._activity);

  @override
  State<DrivingActivityDetails> createState() => DrivingActivityDetailsState();
}

class DrivingActivityDetailsState extends State<DrivingActivityDetails> {
  /// GoogleMaps camera
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};
  bool _isLoading = true;

  final PhyActivityService _phyActivityService = PhyActivityService();

  // List of phyActivities from 5 minutes before start driving
  // until 5 minutes after finishing driving
  List<PhyActivity> _heartRate;

  // key/value pair used to map each PhyActivity object with it hh:mm time (key)
  Map<String, PhyActivity> _timeHeartRate = {};

  List<DrivingEvent> _eventsData;
  final List<DrivingEvent> _hardTurnEvents = [];
  final List<DrivingEvent> _hardBrakingEvents = [];
  final List<DrivingEvent> _phoneDistractionEvents = [];
  final List<DrivingEvent> _parkingEvents = [];
  final List<DrivingEvent> _speedEvents = [];
  final List<DrivingEvent> _hardAccelerationEvents = [];

  // Icons for markers
  Uint8List _startIcon;
  Uint8List _hardTurnIcon;
  Uint8List _hardBrakingIcon;
  Uint8List _phoneDistractionIcon;
  Uint8List _parkingIcon;
  Uint8List _speedIcon;
  Uint8List _hardAccelerationIcon;

  @override
  void initState() {
    super.initState();
    // Get all the driving routes inside the mLocationList
    _buildDrivingRoute();
  }

  Future<void> _getHeartRate() async {
    List<PhyActivity> result = [];
    Map<String, PhyActivity> timeHeartRateMap = {};

    if (widget._activity.endTime != null) {
      // Get heart rate 5 minutes before start driving, and 5 minutes after.
      DateTime dateFrom = widget._activity.startTime.toDate();
      dateFrom = dateFrom.subtract(Duration(minutes: 5));
      DateTime dateTo = widget._activity.endTime.toDate();
      dateTo = dateTo.add(Duration(minutes: 5));

      result =
          await _phyActivityService.read(dateFrom, dateTo, fillWithNull: true);

      // Build map with pair of time (hh:mm)-PhyActicity object
      result.forEach((item) {
        DateTime time = item.timestamp.toDate().toLocal();
        print(item.toString());
        String roundMinute =
            (time.second < 30 ? time.minute : time.minute + 1).toString();
        String hour = time.hour.toString() + ":" + roundMinute;

        timeHeartRateMap[hour] = item;
      });
    }

    setState(() {
      _timeHeartRate = timeHeartRateMap;
      _heartRate = result;
    });
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
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
    if (activity != null && activity.heartRate != null) {
      if (activity.heartRate < 80) {
        return Colors.green;
      } else if (activity.heartRate < 100) {
        return Colors.orange;
      } else {
        return Colors.red;
      }
    }
    return Colors.blue;
  }

  Color _buildLocationColor2(int i) {
    if (i > 1110 && i < 1197) return Colors.red;
    return Colors.orange;
  }

  Future<void> _decodeIcons() async {
    _startIcon = await getBytesFromAsset('assets/images/pin.png', 60);

    _hardTurnIcon =
        await getBytesFromAsset('assets/images/ubicacion_turn.png', 60);
    _hardBrakingIcon =
        await getBytesFromAsset('assets/images/ubicacion_braking.png', 60);
    _phoneDistractionIcon =
        await getBytesFromAsset('assets/images/ubicacion_phone.png', 60);
    _parkingIcon =
        await getBytesFromAsset('assets/images/ubicacion_parking.png', 60);
    _speedIcon =
        await getBytesFromAsset('assets/images/ubicacion_speed.png', 60);
    _hardAccelerationIcon =
        await getBytesFromAsset('assets/images/ubicacion_acceleration.png', 60);
  }

  Future<void> _buildDrivingRoute() async {
    // Check on shared preferences if user has phyActivity enabled
    /*
    bool phyActivity = prefs.getBool("phy_activity_enabled");

    if (phyActivity) {
     await _getHeartRate();
    }
    */
    await _decodeIcons();
    await _getHeartRate();

    //_locationList = await getDrivingRoutes(widget._activity.id);
    List locationData = await getDrivingRoutes(widget._activity.id);

    // Fin Borrar
    _eventsData = await getDrivingEvents(widget._activity.id);
    _buildEventsLists();
    int sizeLocationDataList = locationData.length - 1;
    print("size: " + sizeLocationDataList.toString());

    for (int i = 0; i < sizeLocationDataList; i++) {
      if (locationData[i]['location'] != null &&
          locationData[i + 1]['location'] != null) {
        LatLng point1 = LatLng(locationData[i]['location'].latitude,
            locationData[i]['location'].longitude);
        LatLng point2 = LatLng(locationData[i + 1]['location'].latitude,
            locationData[i + 1]['location'].longitude);

        print(i);
        _polylines.add(
          Polyline(
            color: widget._activity.id == "drive_1593112415623"
                ? _buildLocationColor2(i)
                : _buildLocationColor(locationData[i]['timestamp']),
            visible: true,
            width: 4,
            geodesic: true,
            points: [point1, point2],
            polylineId: PolylineId(locationData[i]['time'].toString()),
          ),
        );
      }
    }
    // Add start driving marker
    _markers.add(
      Marker(
        markerId: MarkerId("driving-start"),
        icon: BitmapDescriptor.fromBytes(_startIcon),
        infoWindow: InfoWindow(
            title: "Comienzo de la conducción",
            snippet: widget._activity.startLocationDetails.formattedAddress),
        position: LatLng(locationData[0]['location'].latitude,
            locationData[0]['location'].longitude),
      ),
    );

    // Add end driving marker
    /*
    _markers.add(
      Marker(
        markerId: MarkerId("driving-end"),
        icon: BitmapDescriptor.fromBytes(_endIcon),
        infoWindow: InfoWindow(
            title: "Fin de la conducción",
            snippet:
                widget._activity.endLocationDetails?.formattedAddress ?? ""),
        position: LatLng(widget._activity.endLocation.latitude,
            widget._activity.endLocation.longitude),
      ),
    );
    */
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Marker _buildEventMarker(DrivingEvent event, Uint8List icon) {
    return Marker(
      markerId:
          MarkerId(event.type.toString() + "_" + event.timestamp.toString()),
      icon: BitmapDescriptor.fromBytes(icon),
      position: LatLng(event.location.latitude, event.location.longitude),
    );
  }

  void _buildEventsLists() {
    _eventsData.forEach((event) {
      if (event.location != null) {
        Uint8List icon;
        if (event.type == DrivingEventType.HARD_ACCELERATION) {
          _hardAccelerationEvents.add(event);
          icon = _hardAccelerationIcon;
        } else if (event.type == DrivingEventType.HARD_BRAKING) {
          _hardBrakingEvents.add(event);
          icon = _hardBrakingIcon;
        } else if (event.type == DrivingEventType.HARD_TURN) {
          _hardTurnEvents.add(event);
          icon = _hardTurnIcon;
        } else if (event.type == DrivingEventType.PARKING) {
          _parkingEvents.add(event);
          icon = _parkingIcon;
        } else if (event.type == DrivingEventType.PHONE_DISTRACTION) {
          _phoneDistractionEvents.add(event);
          icon = _phoneDistractionIcon;
        } else if (event.type == DrivingEventType.SPEEDING) {
          _speedEvents.add(event);
          icon = _speedIcon;
        }

        _markers.add(_buildEventMarker(event, icon));
      }
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
      Map<String, int> result =
          _phyActivityService.calculateMinMaxMedian(_heartRate);
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
      panelBuilder: (sc) => _buildDetails(context, sc),
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
          _eventCount("Estacionamiento", "parking.png", _parkingEvents.length),
          _eventCount("Frenazos", "brake.png", _hardBrakingEvents.length),
          _eventCount(
              "Acelerones", "speed.png", _hardAccelerationEvents.length),
          _eventCount(
              "Giros bruscos", "steering-wheel.png", _hardTurnEvents.length),
          _eventCount("Distracciones", "smartphone.png",
              _phoneDistractionEvents.length),
          _eventCount("Exceso de velocidad", "fast.png", _speedEvents.length),
        ],
      ),
    );
  }

  Widget _eventCount(String text, String image, int count) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(text),
                  SizedBox(
                    height: 7,
                  ),
                  Image.asset(
                    'assets/images/' + image,
                    width: MediaQuery.of(context).size.width * 0.12,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
            Text(
              count.toString(),
              style: Theme.of(context)
                  .textTheme
                  .bodyText2
                  .apply(fontSizeFactor: 1.5),
            )
          ],
        ),
        Divider(),
      ],
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
            Positioned(
              top: 0.0,
              left: 0.0,
              child: IconButton(
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
