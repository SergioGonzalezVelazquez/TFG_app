import 'package:flutter/material.dart';
import 'package:tfg_app/models/driving_activity.dart';
import 'package:tfg_app/pages/driving_activity/driving_activity_item.dart';
import 'package:tfg_app/themes/custom_icon_icons.dart';
import 'package:tfg_app/widgets/progress.dart';
import 'package:tfg_app/services/firestore.dart';

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
    _tabController = new TabController(length: 3, vsync: this);
    _getDrivingActivities();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  _getDrivingActivities() async {
    List activities = await getDrivingActivities();
    if (this.mounted) {
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
      itemBuilder: (BuildContext context, int index) {
        return DrivingActivityItem(_activities[index]);
      },
    );
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rutas registradas'),
        bottom: TabBar(
          unselectedLabelColor: Colors.black38,
          labelColor: Theme.of(context).primaryColor,
          tabs: [
            new Tab(icon: new Icon(CustomIcon.month), text: "Semana"),
            new Tab(
              icon: new Icon(CustomIcon.week),
              text: "Mes",
            ),
            new Tab(
              icon: new Icon(CustomIcon.list),
              text: "Todas",
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
          new Text("This is chat Tab View"),
          new Text("This is notification Tab View"),
        ],
        controller: _tabController,
      ),
    );
  }
}
