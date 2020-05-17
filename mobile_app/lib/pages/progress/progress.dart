import 'package:flutter/material.dart';

class ProgressPage extends StatefulWidget {
  _ProgressPageState createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      // new
      appBar: AppBar(
        title: Text('Progreso'),
        actions: <Widget>[],
      ),
      body: Center(
        child: Text('Progreso'),
      ),
    );
  }
}
