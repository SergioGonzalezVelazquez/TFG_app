import 'package:flutter/material.dart';
import 'package:tfg_app/models/exercise.dart';
import 'package:tfg_app/models/patient.dart';
import 'package:tfg_app/pages/progress/progress_calendar.dart';
import 'package:tfg_app/pages/progress/progress_medals.dart';
import 'package:tfg_app/services/auth.dart';

class ProgressPage extends StatefulWidget {
  _ProgressPageState createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  AuthService _authService;
  int _daysCompleted = 0;
  int _streak = 0;

  int _completedExercises = 0;

  @override
  void initState() {
    _authService = AuthService();
    _completedExercises = _authService.user.patient.completedExercises;
    _daysCompleted = _authService.user.patient.currentDailyStreak;
    _streak = _authService.user.patient.bestDailyStreak;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _dailyCircle(bool completed, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.65 / 7,
              height: MediaQuery.of(context).size.width * 0.65 / 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    completed ? Theme.of(context).primaryColor : Colors.white,
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 2.0,
                ),
              ),
              child: Center(
                child: Visibility(
                  visible: completed,
                  child: Icon(
                    Icons.done,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Visibility(
              visible: index != 7,
              child: Container(
                  height: 1.5,
                  width: MediaQuery.of(context).size.width * 0.15 / 6,
                  color: Theme.of(context).primaryColor),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * 0.037, top: 2),
          child: Text(index.toString()),
        )
      ],
    );
  }

  Widget _dailyProgress() {
    List<Widget> daily = [];
    for (int i = 1; i <= 7; i++) {
      daily.add(
        new Row(
          children: [
            _dailyCircle(_daysCompleted >= i, i),
          ],
        ),
      );
    }
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: daily);
  }

  Widget _buildDaysSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Días seguidos",
          textAlign: TextAlign.center,
          style:
              Theme.of(context).textTheme.headline6.apply(fontSizeFactor: 0.85),
        ),
        SizedBox(
          height: 2,
        ),
        RichText(
          textAlign: TextAlign.justify,
          text: TextSpan(
            text: "Intenta hacer la exposición ",
            style: Theme.of(context).textTheme.bodyText2,
            children: <TextSpan>[
              TextSpan(
                text: 'a diario. ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                  text:
                      "Practicar también los días que no te encuentres bien es importante, ya que te permite aprender a hacer frente al malestar sin acobardarte.")
            ],
          ),
        ),
        SizedBox(
          height: 16,
        ),
        _dailyProgress(),
        SizedBox(
          height: 14,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "Racha actual:\t",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              width: 2,
            ),
            Text(
              _daysCompleted.toString() +
                  " " +
                  (_daysCompleted != 1 ? "días" : "día"),
              style: Theme.of(context)
                  .textTheme
                  .bodyText2
                  .apply(fontWeightDelta: 2, fontSizeFactor: 1.25),
            ),
          ],
        ),
        SizedBox(
          height: 5,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "Mejor racha:  \t",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              width: 2,
            ),
            Text(
              _streak.toString() + " " + (_streak != 1 ? "días" : "día"),
              style: Theme.of(context)
                  .textTheme
                  .bodyText2
                  .apply(fontWeightDelta: 2, fontSizeFactor: 1),
            ),
          ],
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: FlatButton(
            textColor: Theme.of(context).primaryColor,
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => ProgressCalendar()));
            },
            child: Text("Ver detalles"),
            padding: EdgeInsets.zero,
          ),
        )
      ],
    );
  }

  Widget _medalItem(Exercise exercise) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.2,
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Container(
            width: MediaQuery.of(context).size.width * 0.15,
            height: MediaQuery.of(context).size.width * 0.15,
            decoration: new BoxDecoration(
              border: Border.all(color: new Color(0xff808080), width: 1.25),
              shape: BoxShape.circle,
              image: new DecorationImage(
                colorFilter: exercise.status != ExerciseStatus.completed
                    ? ColorFilter.mode(
                        Colors.grey,
                        BlendMode.saturation,
                      )
                    : null,
                fit: BoxFit.fitHeight,
                image: exercise.image != null
                    ? NetworkImage(exercise.image)
                    : AssetImage("assets/images/noimage.jpg"),
              ),
            ),
          ),
          SizedBox(
            height: 3,
          ),
          new Text(
            exercise.itemStr,
            textScaleFactor: 0.75,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    );
  }

  Widget _buildMedalsList() {
    if (_authService.user.patient.exercises.isNotEmpty) {
      return Container(
        height: MediaQuery.of(context).size.width * 0.3,
        child: GridView.count(
          crossAxisCount: 3,
          mainAxisSpacing: 8.0,
          children: [
            ProgressMedalItem(_authService.user.patient.exercises[0]),
            ProgressMedalItem(_authService.user.patient.exercises[1]),
            ProgressMedalItem(_authService.user.patient.exercises[2]),
          ],
        ),
      );
    }
    return Text('');
  }

  Widget _buildExercisesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Logros",
          textAlign: TextAlign.center,
          style:
              Theme.of(context).textTheme.headline6.apply(fontSizeFactor: 0.85),
        ),
        SizedBox(
          height: 2,
        ),
        _authService.user.patient.status != PatientStatus.in_exercise
            ? Text(
                'Aún no tienes asignado ningún ejercicio de exposición',
                textAlign: TextAlign.justify,
              )
            : Text(_completedExercises.toString() +
                " de " +
                _authService.user.patient.exercises.length.toString() +
                " situationes superadas"),
        SizedBox(
          height: 15,
        ),
        _buildMedalsList(),
        SizedBox(
          height: 5,
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: FlatButton(
            textColor: Theme.of(context).primaryColor,
            onPressed: _authService.user.patient.exercises.isEmpty
                ? null
                : () {
                    Navigator.pushNamed(context, ProgressMedals.route);
                  },
            child: Text("Ver todos"),
            padding: EdgeInsets.zero,
          ),
        )
      ],
    );
  }

  Widget _buildPage(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return ListView(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: width * 0.05, vertical: height * 0.01),
          child: _buildDaysSection(),
        ),
        Divider(
          height: 5,
        ),
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: width * 0.05, vertical: height * 0.01),
          child: _buildExercisesSection(),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Progreso'),
          actions: <Widget>[],
        ),
        body: _buildPage(context));
  }
}
