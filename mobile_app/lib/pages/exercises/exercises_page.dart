import 'package:flutter/material.dart';
import 'package:tfg_app/models/exercise.dart';
import 'package:tfg_app/models/patient.dart';
import 'package:tfg_app/pages/exercises/exercise_item.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:tfg_app/pages/exercises/exercises_help.dart';
import 'package:tfg_app/services/auth.dart';
import 'package:tfg_app/widgets/exercise_completed_popup.dart';

class ExercisePage extends StatefulWidget {
  _ExercisePageState createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  List<Exercise> _exercises = [];

  @override
  void initState() {
    _exercises = AuthService().user.patient.exercises;
    super.initState();
  }

  Widget _buildGrid() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: StaggeredGridView.countBuilder(
        // Create a grid with 2 columns. If you change the scrollDirection to
        // horizontal, this produces 2 rows.
        itemCount: _exercises.length,
        crossAxisCount: 4,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
        staggeredTileBuilder: (int index) => StaggeredTile.fit(2),
        itemBuilder: (BuildContext context, int index) {
          return ExerciseItem(_exercises[index], () {
            setState(() {});
          });
        },
      ),
    );
  }

  Widget _buildInfoPage(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: width * 0.07, vertical: height * 0.01),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/3658240.jpg',
            height: MediaQuery.of(context).size.height * 0.3,
            fit: BoxFit.contain,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          RichText(
            textAlign: TextAlign.justify,
            text: TextSpan(
              text: "Cuando completes los pasos previos de la terepia te asignaremos un listado de  ",
              style: Theme.of(context).textTheme.bodyText2,
              children: <TextSpan>[
                TextSpan(
                  text: 'ejercicios ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: " que te ayudarán a exponerte de manera gradual a las situaciones temidas."
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      // new
      appBar: AppBar(
        title: Text('Ejercicios'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () {
                Navigator.pushNamed(context, ExerciseHelp.route);
            },
          ),
        ],
      ),
      body: AuthService().user.patient.status != PatientStatus.in_exercise
          ? _buildInfoPage(context)
          : _buildGrid(),
    );
  }
}
