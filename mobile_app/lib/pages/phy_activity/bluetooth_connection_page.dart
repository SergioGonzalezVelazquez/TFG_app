import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/buttons.dart';
import '../../widgets/progress.dart';
import '../../widgets/snackbar.dart';
import '../root_page.dart';

class BluetoothConnectionInterface extends StatefulWidget {
  static const route = "/bluetoothConnectionPage";
  @override
  _BluetoothConnectionInterfaceState createState() =>
      _BluetoothConnectionInterfaceState();
}

class _BluetoothConnectionInterfaceState
    extends State<BluetoothConnectionInterface> {
  // Create a global key that uniquely identifies the Scaffold widget,
  // and allows to display snackbars.
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<BluetoothDevice> _devicesList = <BluetoothDevice>[];
  FlutterBlue _flutterBlue;
  final bool _blueNotAvailable = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    try {
      _flutterBlue = FlutterBlue.instance;
      _askPermission();
    } on Exception catch (_) {
      Navigator.pop(context, -1);
    }
  }

  Future<void> _activate() async {
    setState(() {
      _isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("phy_activity_enabled", true);
    Navigator.of(context)
        .pushNamedAndRemoveUntil(RootPage.route, (route) => false);
  }

  Future<void> _cancel() async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("phy_activity_enabled", false);

    Navigator.of(context)
        .pushNamedAndRemoveUntil(RootPage.route, (route) => false);
  }

  /// Request location permissions
  void _askPermission() async {
    Map<Permission, PermissionStatus> statuses =
        await [Permission.locationAlways].request();

    bool granted = statuses.values
        .every((permission) => permission == PermissionStatus.granted);

    if (granted) {
      _bluetoothManagement();
    } else {
      await _cancel();
    }
  }

  // Bluetooth Management (Asking for permission, scan, etc...) //
  void _bluetoothManagement() {
    // Meter lo del bluetooth
    FlutterBlue.instance.state.listen((state) {
      if (state == BluetoothState.off) {
        //Alert user to turn on bluetooth.
        final snackBar = customSnackbar(context,
            "Activa el Bluetooth para poder sincronizar con la pulsera");
        _scaffoldKey.currentState.showSnackBar(snackBar);
      } else if (state == BluetoothState.on) {
        // if bluetooth is enabled then go ahead.
        // Make sure user's device gps is on.
        _flutterBlue.connectedDevices.asStream().listen((devices) {
          for (BluetoothDevice device in devices) {
            _addDeviceTolist(device);
          }
        });
        _flutterBlue.scanResults.listen((results) {
          for (ScanResult result in results) {
            _addDeviceTolist(result.device);
          }
        });
        _flutterBlue.startScan();
      }
    });
  }

  // Interface Management (showing detected devices, etc...) //
  void _addDeviceTolist(final BluetoothDevice device) {
    if (!_devicesList.contains(device)) {
      setState(() {
        _devicesList.add(device);
      });
    }
  }

  // Service Management (pass the device's direction to mibandlib in android)
  void _startServiceInPlatform(String macAddress) async {
    var methodChannel = MethodChannel("emovi/methodChannel");
    await _activate();
    await methodChannel.invokeMethod("startService", {
      "macAddress": macAddress,
    });
  }

  // Widgets

  Widget _deviceItem(BluetoothDevice device) {
    return Column(
      children: [
        ListTile(
          title: Text(device.name == '' ? '(Unknown Device)' : device.name),
          subtitle: Text(device.id.toString()),
          trailing: primaryButton(
            context,
            () {
              _flutterBlue.stopScan();
              _startServiceInPlatform(device.id.toString());
            },
            "Conectar",
            width: MediaQuery.of(context).size.width * 0.2,
            fontSizeFactor: 0.8,
          ),
        ),
        Divider(
          height: 4,
        )
      ],
    );
  }

  Widget _buildListViewOfDevices() {
    return ListView.builder(
        padding: EdgeInsets.all(8.0),
        itemBuilder: (_, index) => _deviceItem(_devicesList[index]),
        itemCount: _devicesList.length);
  }

  Widget _buildBlueNotAvailable() {
    return Text("Bluetooth no disponible en este dispostivo");
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
            "Dispositivos disponibles",
          ),
        ),
        body: _isLoading
            ? circularProgress(context)
            : (_blueNotAvailable
                ? _buildBlueNotAvailable()
                : _buildListViewOfDevices()),
      );
}
