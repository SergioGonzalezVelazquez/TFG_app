import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:tfg_app/models/exercise.dart';
import 'package:tfg_app/services/auth.dart';

class ProgressMedals extends StatelessWidget {
  static final route = "/exerciseMedals";
  final List<Exercise> exercises = AuthService().user.patient.exercises;

  Widget _medalItem(BuildContext context, Exercise exercise) {
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
            style: Theme.of(context).textTheme.bodyText2.apply(fontSizeFactor: 0.9),
          )
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.count(
        // Create a grid with 2 columns. If you change the scrollDirection to
        // horizontal, this produces 2 rows.
        crossAxisCount: 3,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
        children: List.generate(
          exercises.length,
          (index) => _medalItem(context, exercises[index]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logros'),
      ),
      body: _buildGrid(context),
    );
  }
}
