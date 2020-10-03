import 'package:flutter/material.dart';

import '../../models/driving_activity.dart';
import '../../services/firestore.dart';
import '../../themes/custom_icon_icons.dart';
import '../../widgets/progress.dart';
import 'driving_activity_item.dart';
import 'driving_activity_settings.dart';

class DrivingActivityPage extends StatefulWidget {
  _DrivingActivityPageState createState() => _DrivingActivityPageState();
}

class _DrivingActivityPageState extends State<DrivingActivityPage>
    with SingleTickerProviderStateMixin {
  List<DrivingActivity> _activities;
  bool _isLoading = true;

  /// TabBar Controller will control the movement between the Tabs
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _getDrivingActivities();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  _getDrivingActivities() async {
    List activities = await getDrivingActivities();
    if (mounted) {
      setState(() {
        _activities = activities;
        _isLoading = false;
      });
    }
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
      itemBuilder: (context, index) {
        return DrivingActivityItem(_activities[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rutas registradas'),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, DrivingActivitySettings.route);
              },
              child: Icon(
                CustomIcon.cog,
                size: 20.0,
              ),
            ),
          ),
        ],
        bottom: TabBar(
          unselectedLabelColor: Colors.black38,
          labelColor: Theme.of(context).primaryColor,
          tabs: [
            Tab(
              icon: Icon(CustomIcon.list),
              text: "Todas",
            ),
            Tab(icon: Icon(CustomIcon.month), text: "Semana"),
            Tab(
              icon: Icon(CustomIcon.week),
              text: "Mes",
            ),
          ],
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorSize: TabBarIndicatorSize.tab,
        ),
        bottomOpacity: 1,
      ),
      body: TabBarView(
        children: [
          _buildActivities(),
          Text("Este mes"),
          Text("Todas"),
        ],
        controller: _tabController,
      ),
    );
  }
}
