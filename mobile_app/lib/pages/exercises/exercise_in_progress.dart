import 'package:flutter/material.dart';
import 'package:tfg_app/models/exercise.dart';

class Countdown extends AnimatedWidget {
  Countdown({Key key, this.animation}) : super(key: key, listenable: animation);
  Animation<int> animation;

  @override
  build(BuildContext context) {
    return new Text(
      animation.value.toString(),
      style:
          new TextStyle(fontSize: 150.0, color: Theme.of(context).primaryColor),
    );
  }
}

class ExerciseInProgressPage extends StatefulWidget {
  final Exercise exercise;
  ExerciseInProgressPage(this.exercise);
  _ExerciseInProgressPageState createState() => _ExerciseInProgressPageState();
}

class _ExerciseInProgressPageState extends State<ExerciseInProgressPage>
    with TickerProviderStateMixin {
  // https://stackoverflow.com/questions/44302588/flutter-create-a-countdown-widget
  AnimationController _controller;

  static const int kStartValue = 4;

  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(
      vsync: this,
      duration: new Duration(seconds: kStartValue),
    );

    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Container(
        child: new Center(
          child: new Countdown(
            animation: new StepTween(
              begin: kStartValue,
              end: 0,
            ).animate(_controller),
          ),
        ),
      ),
    );
  }
}
