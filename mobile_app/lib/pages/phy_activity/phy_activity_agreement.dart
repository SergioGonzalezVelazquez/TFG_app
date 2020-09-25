import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tfg_app/pages/phy_activity/bluetooth_connection_page.dart';
import 'package:tfg_app/pages/root_page.dart';
import 'package:tfg_app/widgets/progress.dart';
import 'package:tfg_app/widgets/buttons.dart';

class PhyActivityAgreement extends StatefulWidget {
  static const route = "/phyActivityAgreement";

  static List<String> compatibleDevices = ["Xiaomi MiBand 2", "Xiaomi MiBand 3"];

  @override
  State<PhyActivityAgreement> createState() => PhyActivityAgreementState();
}

class PhyActivityAgreementState extends State<PhyActivityAgreement> {
  // Controller to manipulate which page is visible in a PageView
  PageController _pageController = PageController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  Future<void> _cancel() async {
    setState(() {
      _isLoading = true;
    });
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("phy_activity_enabled", false);

    Navigator.of(context).pushNamedAndRemoveUntil(
        RootPage.route, (Route<dynamic> route) => false);
  }

  /**
  * Widgets (ui components) used in this screen 
  */

  Widget _buildPage(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: width * 0.07, vertical: height * 0.01),
      child: ListView(
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          Text(
            "Monitorización del ritmo cardiaco",
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headline5
                .apply(fontSizeFactor: 0.95),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          Image.asset(
            'assets/images/3802284.png',
            height: MediaQuery.of(context).size.height * 0.3,
            fit: BoxFit.contain,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.07,
          ),
          Text(
            "Conecta una pulsera de actividad física para obtener informes de tu pulso cardíaco durante la conducción",
            textAlign: TextAlign.justify,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          Text(
            "Dispositivos compatibles: ",
            textAlign: TextAlign.justify,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.005,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildCompatibleDevicesList(),
            ),
          )
        ],
      ),
    );
  }

  List<Widget> _buildCompatibleDevicesList() {
    List<Widget> items = [];
    PhyActivityAgreement.compatibleDevices.forEach((element) {
      items.add(
        new Row(
          children: [
            Icon(
              Icons.donut_large,
              size: 6,
            ),
            SizedBox(
              width: 10,
            ),
            Text(element)
          ],
        ),
      );
    });
    return items;
  }

  Widget _bottonNavigationBar(BuildContext parentContext) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: width * 0.07, vertical: height * 0.02),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          FlatButton(
            padding: EdgeInsets.all(0),
            onPressed: () async {
              await _cancel();
            },
            child: Text(
              "Saltar",
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold),
            ),
          ),
          primaryButton(
              context,
              () => Navigator.pushNamed(
                  context, BluetoothConnectionInterface.route),
              "Conectar",
              width: MediaQuery.of(context).size.width * 0.25),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor:  Color(0xffe8eaf6),
      body: _isLoading ? circularProgress(context) : _buildPage(context),
      bottomNavigationBar: _isLoading ? null : _bottonNavigationBar(context),
    );
  }
}
