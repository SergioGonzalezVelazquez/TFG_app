import 'package:flutter/material.dart';
import 'package:tfg_app/themes/custom_icon_icons.dart';

class ProgressPage extends StatefulWidget {
  _ProgressPageState createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;

  /// TabBar Controller will control the movement between the Tabs
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progreso'),
        actions: <Widget>[
         
        ],
        bottom: TabBar(
          unselectedLabelColor: Colors.black38,
          labelColor: Theme.of(context).primaryColor,
          tabs: [
            new Tab(
              icon: new Icon(CustomIcon.alarm),
              text: "Terapia",
            ),
            new Tab(
              icon: new Icon(CustomIcon.book),
              text: "Diario",
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
          new Text("Terapia"),
          new Text("Diario"),
        ],
        controller: _tabController,
      ),
    );
  }
}
