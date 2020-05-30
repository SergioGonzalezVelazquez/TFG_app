import 'dart:async';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:tfg_app/models/exercise.dart';
import 'dart:math' as math;

import 'package:tfg_app/widgets/custom_dialog.dart';

class ExerciseRunningPage extends StatefulWidget {
  final Exercise exercise;
  final Duration exerciseDuration;
  ExerciseRunningPage(this.exercise, this.exerciseDuration);
  _ExerciseRunningPageState createState() => _ExerciseRunningPageState();
}

class _ExerciseRunningPageState extends State<ExerciseRunningPage>
    with TickerProviderStateMixin {
  // https://stackoverflow.com/questions/44302588/flutter-create-a-countdown-widget
  AnimationController _initialCountDownController;
  AnimationController _timerController;
  FlutterTts _flutterTts = new FlutterTts();

  bool _initialCountDownCompleted = false;
  bool _timerCompleted = false;
  bool _inPause = false;
  bool _volumeOff = false;
  bool _hasAudio;
  final int _initialCountDownDuration = 4;
  Stopwatch _stopwatch;

  /// Instantiate an AudioPlayer instance
  AudioCache _audioCache;
  AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _hasAudio = widget.exercise.audio != null;
    if (_hasAudio) {
      _audioCache = AudioCache();
      _audioPlayer = AudioPlayer();
    }

    // Controller for initial countdown
    _initialCountDownController = new AnimationController(
      vsync: this,
      duration: new Duration(seconds: _initialCountDownDuration),
    );
    _initialCountDownController.forward(from: 0.0);
    _initialCountDownController
        .addStatusListener(_initialCountDownStatusListener);

    // Controller for timer countdown
    _timerController = AnimationController(
      vsync: this,
      duration: widget.exerciseDuration,
    );
    _timerController.addStatusListener(_timerStatusListener);

    // Controller for stopwatch
    _stopwatch = new Stopwatch();
  }

  void _initialCountDownStatusListener(AnimationStatus status) async {
    if (status == AnimationStatus.completed) {
      setState(() {
        _initialCountDownCompleted = true;
      });
      _timerController.reverse(
          from: _timerController.value == 0.0 ? 1.0 : _timerController.value);
      _stopwatch.start();

      if (_hasAudio) {
        await _audioPlayer.play(widget.exercise.audio);
      }
    }
  }

  /// Method used to used handle the system back button.
  /// Return true if the route to be popped
  Future<bool> _willPopCallback() async {
    bool close = false;
    await showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
        title: "¿Seguro que quieres salir?",
        description: "No se guardará nada sobre la exposición actual",
        buttonText2: "Salir",
        buttonFunction2: () {
          close = true;
          Navigator.pop(context);
        },
        buttonFunction1: () {
          close = false;
          Navigator.pop(context);
        },
        buttonText1: "Cancelar",
      ),
    );
    return close;
  }

  Future<void> speak() async {
    print("speak");
    if (_hasAudio) {
      _audioPlayer.stop();
    }
    await _flutterTts.speak(
        'Duración fijada alcanzada. Si lo deseas, puedes continuar con la exposición.');
    if (_hasAudio) {
      await Future.delayed(Duration(seconds: 5));
      _audioPlayer.resume();
    }
  }

  void _timerStatusListener(AnimationStatus status) async {
    print("timerStatusListenter: " + status.toString());
    if (status == AnimationStatus.dismissed) {
      setState(() {
        _timerCompleted = true;
      });
      print("dimissed");
      await speak();
    }
  }

  void _onPause() {
    setState(() {
      _inPause = true;
    });
    _stopwatch.stop();
    if (!_timerCompleted) {
      _timerController.stop();
    }

    if (_hasAudio) {
      _audioPlayer.pause();
    }
  }

  void _onPlay() {
    setState(() {
      _inPause = false;
    });
    _stopwatch.start();
    if (!_timerCompleted) {
      _timerController.reverse(
          from: _timerController.value == 0.0 ? 1.0 : _timerController.value);
    }

    if (_hasAudio) {
      _audioPlayer.resume();
    }
  }

  void _onReplay() {
    _stopwatch.reset();
    setState(() {
      _timerCompleted = false;
      _timerController.dispose();
      _timerController = AnimationController(
        vsync: this,
        duration: widget.exerciseDuration,
      );
      _timerController.reverse(
          from: _timerController.value == 0.0 ? 1.0 : _timerController.value);
    });
  }

  void _onStop() {
    Duration duration = _stopwatch.elapsed;
    print(duration.inSeconds);
  }

  @override
  void dispose() {
    if (_hasAudio) {
      _audioPlayer.stop();
    }

    _timerController.dispose();
    _initialCountDownController.dispose();
    _stopwatch.stop();

    super.dispose();
  }

  Widget _timerWidget() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Align(
            alignment: FractionalOffset.center,
            child: AspectRatio(
              aspectRatio: 1,
              child: Stack(
                children: <Widget>[
                  Visibility(
                    visible: _initialCountDownCompleted,
                    child: AnimatedBuilder(
                        animation: _timerController,
                        builder: (context, child) {
                          return Center(
                            child: Container(
                              height: MediaQuery.of(context).size.width * 0.8,
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: CustomPaint(
                                painter: CustomTimerPainter(
                                    animation: _timerController,
                                    backgroundColor:
                                        Theme.of(context).primaryColorLight,
                                    color: Theme.of(context).primaryColorDark),
                              ),
                            ),
                          );
                        }),
                  ),
                  Align(
                    alignment: FractionalOffset.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Visibility(
                          visible: false,
                          child: Text(
                            "1 h",
                            style: TextStyle(
                                fontSize: 40.0, color: Colors.black45),
                          ),
                        ),
                        Column(
                          children: [
                            TimerText(
                              stopwatch: _stopwatch,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Duración orientativa: ",
                              style: TextStyle(
                                  fontSize: 15.0, color: Colors.black45),
                            ),
                            Text(
                              widget.exerciseDuration.inMinutes > 1
                                  ? (widget.exerciseDuration.inMinutes
                                          .toString() +
                                      " min")
                                  : (widget.exerciseDuration.inSeconds
                                          .toString() +
                                      " seg"),
                              style: TextStyle(
                                  fontSize: 15.0, color: Colors.black45),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountDown() {
    return new Container(
      color: Theme.of(context).primaryColor,
      child: new Center(
        child: new Countdown(
          animation: new StepTween(
            begin: _initialCountDownDuration,
            end: 0,
          ).animate(_initialCountDownController),
        ),
      ),
    );
  }

  Widget _circleButton(
      IconData icon, Function onPressed, Color color, double diameter,
      {double iconSize = 30}) {
    return Container(
      width: diameter,
      height: diameter,
      child: RaisedButton(
        onPressed: onPressed,
        shape: CircleBorder(),
        color: color,
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Icon(
          icon,
          size: iconSize,
        ),
      ),
    );
  }

  Widget _buildPause() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _circleButton(
            _volumeOff ? Icons.volume_up : Icons.volume_off,
            widget.exercise.audio != null
                ? () {
                    setState(() {
                      _volumeOff = !_volumeOff;
                      if (_hasAudio) {
                        if (_volumeOff) {
                          _audioPlayer.pause();
                        } else {
                          _audioPlayer.resume();
                        }
                      }
                    });
                  }
                : null,
            Theme.of(context).primaryColorLight,
            MediaQuery.of(context).size.width * 0.18),
        _circleButton(Icons.pause, _onPause, Theme.of(context).primaryColorDark,
            MediaQuery.of(context).size.width * 0.30,
            iconSize: 60),
        _circleButton(
            Icons.replay,
            _onReplay,
            Theme.of(context).primaryColorLight,
            MediaQuery.of(context).size.width * 0.18),
      ],
    );
  }

  Widget _buildPlay() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _circleButton(
            Icons.play_arrow,
            _onPlay,
            Theme.of(context).primaryColorDark,
            MediaQuery.of(context).size.width * 0.30,
            iconSize: 60),
        _circleButton(Icons.stop, _onStop, Theme.of(context).primaryColorLight,
            MediaQuery.of(context).size.width * 0.30,
            iconSize: 60),
      ],
    );
  }

  Widget _buildRunning() {
    return Padding(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
      child: ListView(
        children: [
          Text(
            widget.exercise.itemStr,
            style: Theme.of(context)
                .textTheme
                .headline6
                .apply(fontSizeFactor: 0.8),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          _timerWidget(),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          _inPause ? _buildPlay() : _buildPause(),
        ],
      ),
    );
  }

  Widget _buildPage() {
    Widget child;
    if (!_initialCountDownCompleted) {
      child = _buildCountDown();
    } else {
      child = _buildRunning();
    }
    return child;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _willPopCallback,
      child: SafeArea(
        child: new Scaffold(
          body: _buildPage(),
        ),
      ),
    );
  }
}

class Countdown extends AnimatedWidget {
  Countdown({Key key, this.animation}) : super(key: key, listenable: animation);
  Animation<int> animation;

  @override
  build(BuildContext context) {
    return new Text(
      animation.value.toString(),
      style: new TextStyle(fontSize: 150.0, color: Colors.white),
    );
  }
}

/// Circular progress bar using Custom paint
/// https://medium.com/flutterdevs/creating-a-countdown-timer-using-animation-in-flutter-2d56d4f3f5f1
class CustomTimerPainter extends CustomPainter {
  CustomTimerPainter({
    this.animation,
    this.backgroundColor,
    this.color,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color backgroundColor, color;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(size.center(Offset.zero), size.width / 2.0, paint);
    paint.color = color;
    double progress = (1.0 - animation.value) * 2 * math.pi;
    canvas.drawArc(Offset.zero & size, math.pi * 1.5, progress, false, paint);
  }

  @override
  bool shouldRepaint(CustomTimerPainter old) {
    return animation.value != old.animation.value ||
        color != old.color ||
        backgroundColor != old.backgroundColor;
  }
}

/// https://medium.com/free-code-camp/how-fast-is-flutter-i-built-a-stopwatch-app-to-find-out-9956fa0e40bd
/// Creating a separate TimerText class to encapsulate the timer logic is less CPU-intensive.
class TimerText extends StatefulWidget {
  TimerText({this.stopwatch});
  final Stopwatch stopwatch;

  TimerTextState createState() => new TimerTextState(stopwatch: stopwatch);
}

class TimerTextState extends State<TimerText> {
  Timer timer;
  final Stopwatch stopwatch;

  TimerTextState({this.stopwatch}) {
    timer = new Timer.periodic(new Duration(seconds: 1), callback);
  }

  String get stopWatchMMSSString {
    Duration duration = stopwatch.elapsed;
    return '${(duration.inMinutes % 60).toString()}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  String get stopWatchHHString {
    Duration duration = stopwatch.elapsed;
    int hours = duration.inHours.toInt();
    if (hours == 0) {
      return '';
    } else if (hours == 1) {
      return '1 hora';
    } else {
      return '${hours.toString()} horas';
    }
  }

  void dispose() {
    super.dispose();
    timer.cancel();
  }

  void callback(Timer timer) {
    if (stopwatch.isRunning && this.mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return new RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: stopWatchHHString + "\n",
        style: TextStyle(fontSize: 20.0, color: Colors.black45),
        children: <TextSpan>[
          TextSpan(
            text: stopWatchMMSSString,
            style: TextStyle(fontSize: 90.0, color: Colors.black45),
          ),
        ],
      ),
    );
  }
}
