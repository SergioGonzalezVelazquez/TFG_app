import 'package:flutter/material.dart';

class ExercisePage extends StatefulWidget {

  _ExercisePageState createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        // new
        appBar: AppBar(
          title: Text('Exercises'),
          actions: <Widget>[],
        ),
        body: Center(child: Text('Exercises')));
  }
}
