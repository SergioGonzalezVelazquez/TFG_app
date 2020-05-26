import 'package:flutter/material.dart';
import 'package:tfg_app/models/exercise.dart';
import 'package:tfg_app/pages/exercises/exercise_item.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:tfg_app/services/auth.dart';

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
            return ExerciseItem(_exercises[index]);
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      // new
      appBar: AppBar(
        title: Text('Ejercicios'),
        actions: <Widget>[],
      ),
      body: _buildGrid(),
    );
  }
}
