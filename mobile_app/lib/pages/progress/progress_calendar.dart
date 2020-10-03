import 'package:flutter/material.dart';

import '../../main.dart';
import '../../models/exercise.dart';
import '../../models/exposure_exercise.dart';
import '../../services/firestore.dart';
import '../exercises/exercise_details.dart';

/// Code from:
/// https://github.com/lohanidamodar/flutter_calendar/blob/part3/lib/main.dart
///
/// Using:
/// https://pub.dev/packages/table_calendar#-readme-tab-
class ProgressCalendar extends StatefulWidget {
  @override
  _ProgressCalendarState createState() => _ProgressCalendarState();
}

class _ProgressCalendarState extends State<ProgressCalendar> {
  //CalendarController _controller;

  @override
  void initState() {
    super.initState();

    //_controller = CalendarController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Histórico de exposiciones'),
      ),
      body: StreamBuilder<List<ExposureExercise>>(
        stream: getExposuresAsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            print("snapshot has data");
            if (snapshot.data.isNotEmpty) {
            } else {}
          }
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                /*
                TableCalendar(
                  events: _events,
                  locale: "es_ES",
                  availableCalendarFormats: const {
                    CalendarFormat.month: 'Mes',
                    CalendarFormat.week: 'Semana',
                    CalendarFormat.twoWeeks: 'Dos semanas'
                  },
                  initialCalendarFormat: CalendarFormat.week,
                  calendarStyle: CalendarStyle(
                      canEventMarkersOverflow: true,
                      todayColor: Theme.of(context).primaryColor,
                      selectedColor: Theme.of(context).primaryColor,
                      todayStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          color: Colors.white)),
                  headerStyle: HeaderStyle(
                    centerHeaderTitle: true,
                    formatButtonDecoration: BoxDecoration(
                      color: Theme.of(context).primaryColorLight,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    formatButtonTextStyle: TextStyle(color: Colors.white),
                    formatButtonShowsNext: false,
                  ),
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  onDaySelected: (date, events) {
                    print("om day selected: " + date.toString());
                    print(events.length);
                    setState(() {
                      _selectedEvents = events;
                    });
                  },
                  builders: CalendarBuilders(
                    selectedDayBuilder: (context, date, events) => Container(
                        margin: const EdgeInsets.all(4.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColorLight,
                            borderRadius: BorderRadius.circular(10.0)),
                        child: Text(
                          date.day.toString(),
                          style: TextStyle(color: Colors.white),
                        )),
                    todayDayBuilder: (context, date, events) => Container(
                        margin: const EdgeInsets.all(4.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColorDark,
                            borderRadius: BorderRadius.circular(10.0)),
                        child: Text(
                          date.day.toString(),
                          style: TextStyle(color: Colors.white),
                        )),
                  ),
                  calendarController: _controller,
                ),
                ..._selectedEvents.map(
                  (exposure) => ExposureItem(
                    exposure,
                    _authService.user.patient.getExercise(exposure.exerciseId),
                  ),
                ),
                */
              ],
            ),
          );
        },
      ),
    );
  }
}

class ExposureItem extends StatelessWidget {
  final ExposureExercise exposure;
  final Exercise exercise;

  String getDuration() {
    Duration duration = Duration(seconds: exposure.realDuration);
    int minutes = duration.inMinutes % 60;
    int hours = duration.inHours % 60;
    int seconds = exposure.realDuration;
    seconds = seconds % 60;

    String str = '';
    if (hours > 0) str += '${hours.toString()} h ';
    if (minutes > 0) str += '${minutes.toString()} min ';
    if (seconds > 0) str += '${seconds.toString()} seg';

    return str;
  }

  ExposureItem(this.exposure, this.exercise);

  Widget _buildItem(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * 0.05,
          right: MediaQuery.of(context).size.width * 0.05,
          top: 10),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExerciseDetails(exercise),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              timeFormatter.format(exposure.start.toDate()) +
                  "\t(" +
                  getDuration() +
                  ")",
              style: Theme.of(context)
                  .textTheme
                  .subtitle2
                  .copyWith(color: Colors.black45),
            ),
            Text(exercise.itemStr,
                style: Theme.of(context).textTheme.subtitle1),
            SizedBox(
              height: 3,
            ),
            Text(
              "Ejercicio " +
                  exercise.index.toString() +
                  " - " +
                  exercise.levelStr,
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  .copyWith(color: Colors.black87)
                  .apply(fontSizeFactor: 0.8),
            ),
            SizedBox(
              height: 3,
            ),
            Divider(
              height: 5,
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildItem(context);
  }
}
