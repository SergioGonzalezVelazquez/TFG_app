import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {

  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          title: Text('Mi cuenta'),
          actions: <Widget>[],
        ),
        body: Center(child: Text('Cuenta')));
  }
}
