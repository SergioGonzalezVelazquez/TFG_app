import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/exercise.dart';
import '../../services/auth.dart';

class ProgressMedalItem extends StatelessWidget {
  final Exercise exercise;

  ProgressMedalItem(this.exercise);

  Widget _buildIncompleteMedal(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Stack(
            children: [
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.18,
                  height: MediaQuery.of(context).size.width * 0.18,
                  foregroundDecoration: BoxDecoration(
                    color: Colors.white,
                    backgroundBlendMode: BlendMode.saturation,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xff808080), width: 1.55),
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.fitHeight,
                      image: exercise.image != null
                          ? NetworkImage(exercise.image)
                          : AssetImage("assets/images/noimage.jpg"),
                    ),
                  ),
                ),
              ),
              Center(
                child: ClipOval(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.18,
                    height: MediaQuery.of(context).size.width * 0.18,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 2,
                        sigmaY: 2,
                      ),
                      child: Container(
                        color: Colors.black.withOpacity(0),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 3,
          ),
          Text(
            exercise.itemStr,
            textScaleFactor: 0.75,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .bodyText2
                .apply(fontSizeFactor: 0.9),
          )
        ],
      ),
    );
  }

  Widget _buildCompletedMedal(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Stack(
            children: [
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.18,
                  height: MediaQuery.of(context).size.width * 0.18,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xffDAA520), width: 1.55),
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.fitHeight,
                      image: exercise.image != null
                          ? NetworkImage(exercise.image)
                          : AssetImage("assets/images/noimage.jpg"),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 20,
                child: Container(
                  height: 20.0,
                  width: 20.0,
                  child: Image.asset("assets/images/medalla.png"),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 3,
          ),
          Text(
            exercise.itemStr,
            textScaleFactor: 0.75,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .bodyText2
                .apply(fontSizeFactor: 0.9),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return exercise.status == ExerciseStatus.completed
        ? _buildCompletedMedal(context)
        : _buildIncompleteMedal(context);
  }
}

class ProgressMedals extends StatelessWidget {
  static final route = "/exerciseMedals";
  final List<Exercise> exercises = AuthService().user.patient.exercises;

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
          (index) => ProgressMedalItem(exercises[index]),
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
