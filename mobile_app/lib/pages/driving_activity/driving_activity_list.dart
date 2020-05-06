import 'package:flutter/material.dart';
import 'package:tfg_app/models/driving_activity.dart';
import 'package:tfg_app/pages/driving_activity/driving_activity_item.dart';
import 'package:tfg_app/widgets/progress.dart';
import 'package:tfg_app/services/firestore.dart';

class DrivingActivityListPage extends StatefulWidget {
  _DrivingActivityListPageState createState() =>
      _DrivingActivityListPageState();
}

class _DrivingActivityListPageState extends State<DrivingActivityListPage> {
  List<DrivingActivity> _activities;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getDrivingActivities();
  }

  _getDrivingActivities() async {
    List activities = await getDrivingActivities();
    print("activities");
    print(activities);
    setState(() {
      _activities = activities;
      _isLoading = false;
    });
  }

  _buildActivities() {
    if (_isLoading) {
      return circularProgress(context);
    } else if (_activities.isEmpty) {
      return Center(
        child: Text("No hay niguna actividad registrada"),
      );
    }
    return ListView.builder(
      itemCount: _activities.length,
      itemBuilder: (BuildContext context, int index) {
        return DrivingActivityItem(_activities[index]);
      },
    );
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driving Activities'),
        actions: <Widget>[],
      ),
      body: _buildActivities(),
    );
  }
}
