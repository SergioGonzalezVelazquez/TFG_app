import 'package:flutter/material.dart';

import '../../services/driving_detection.dart';
import '../../widgets/buttons.dart';
import '../../widgets/progress.dart';

class DrivingActivitySettings extends StatefulWidget {
  static const route = """/drivingActivitySettings""";

  @override
  State<DrivingActivitySettings> createState() =>
      DrivingActivitySettingsState();
}

class DrivingActivitySettingsState extends State<DrivingActivitySettings> {
  // Controller to manipulate which page is visible in a PageView
  bool _isLoading = true;
  bool _isRunning = false;

  DrivingDetectionService _service;

  @override
  void initState() {
    super.initState();
    _service = DrivingDetectionService();
    _checkIsRunning();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Functions used to handle events in this screen
  Future<void> _checkIsRunning() async {
    bool running = await _service.isRunning();
    setState(() {
      _isRunning = running;
      _isLoading = false;
    });
  }

  Future<void> _turnOn() async {
    setState(() {
      _isLoading = true;
    });
    bool enabled = await _service.startBackgroundService();
    if (enabled) {
      enabled = await _service.isRunning();
    }
    setState(() {
      _isLoading = false;
      _isRunning = enabled;
    });
  }

  Future<void> _turnOff() async {
    setState(() {
      _isLoading = true;
    });
    _service.stopBackgroundService();
    setState(() {
      _isLoading = false;
      _isRunning = false;
    });
  }

  ///  Widgets (ui components) used in this screen

  Widget _buildPage(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: width * 0.04, vertical: height * 0.01),
      child: ListView(
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          Text(
            """Detección automática de la conducción""",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline6,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.04,
          ),
          Text(
            """Con esta función activada, STOPMiedo hace uso de los sensores de movimiento y localización para averiguar automáticamente si estás conduciendo.""",
            textAlign: TextAlign.justify,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.03,
          ),
          Text(
            """De esta forma podemos reconocer algunos eventos significativos en la conducción tales como frenazos, giros bruscos, acelerones, exceso de velocidad y distracciones con el teléfono.""",
            textAlign: TextAlign.justify,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.03,
          ),
          Text(
            """Además, a través de la utilización de mapas, podrás hacer un seguimiento de tus rutas en coche.""",
            textAlign: TextAlign.justify,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          Text(
            """Estado: """,
            textAlign: TextAlign.justify,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 7.0,
                height: 7.0,
                decoration: BoxDecoration(
                  color: _isRunning ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                _isRunning ? """En ejecución""" : """Desactivado""",
                style: TextStyle(
                  color: _isRunning ? Colors.green : Colors.red,
                ),
              )
            ],
          )
        ],
      ),
    );
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
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              """Salir""",
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold),
            ),
          ),
          _isRunning
              ? primaryButton(context, _turnOff, """Desactivar""",
                  width: MediaQuery.of(context).size.width * 0.25)
              : primaryButton(context, _turnOn, """Aceptar""",
                  width: MediaQuery.of(context).size.width * 0.25),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("""Configuración"""),
      ),
      body: SafeArea(
        child: _isLoading ? circularProgress(context) : _buildPage(context),
      ),
      bottomNavigationBar: _isLoading ? null : _bottonNavigationBar(context),
    );
  }
}
