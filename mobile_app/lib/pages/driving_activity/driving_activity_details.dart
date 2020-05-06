import 'dart:async';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter/material.dart';
import 'package:tfg_app/models/driving_activity.dart';
import 'package:tfg_app/models/driving_event.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tfg_app/services/firestore.dart';
import 'package:tfg_app/widgets/progress.dart';
import 'package:tfg_app/themes/custom_icon_icons.dart';

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
  bool _isLoadingMap = true;

  List<DrivingEvent> _eventsData;

  @override
  void initState() {
    super.initState();
    // Get all the driving routes inside the mLocationList
    _buildDrivingRoute();
  }

  Future<void> _buildDrivingRoute() async {
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
          color: Theme.of(context).primaryColor,
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
      print("route complete");
      _isLoadingMap = false;
    });
  }

  // Initialize Google Maps setting the UI properties, such as zoom control,
  // zoom gesture, and rotation gesture.

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
      child: ListView(children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _detailsItem(context, "Duración", ""),
            _detailsItem(
              context,
              "Distancia",
              (widget._activity.distance / 1000).toStringAsFixed(1) + " km",
            ),
            _detailsItem(context, "Eventos", _eventsData.length.toString())
          ],
        )
      ]),
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
            _isLoadingMap
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
