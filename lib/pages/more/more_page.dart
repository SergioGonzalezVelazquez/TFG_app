import 'package:flutter/material.dart';

class MorePage extends StatefulWidget {

  _MorePageState createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        // new
        appBar: AppBar(
          title: Text('More'),
          actions: <Widget>[],
        ),
        body: Center(child: Text('More')));
  }
}
