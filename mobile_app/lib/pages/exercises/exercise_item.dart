import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tfg_app/models/exercise.dart';
import 'package:tfg_app/pages/exercises/exercise_details.dart';

class ExerciseItem extends StatelessWidget {
  final Exercise exercise;

  ExerciseItem(this.exercise);

  Widget _buildImage(BuildContext context) {
    Widget children;
    if (exercise.image != null) {
      children = Container(
          width: double.maxFinite,
          child: CachedNetworkImage(
            imageUrl: exercise.image,
            fit: BoxFit.cover,
          ),
          height: MediaQuery.of(context).size.height * 0.16);
    } else {
      children = Container(
          width: double.maxFinite,
          child: Image.asset(
            "assets/images/noimage.jpg",
            fit: BoxFit.cover,
          ),
          height: MediaQuery.of(context).size.height * 0.16);
    }

    return children;
  }

  Widget _buildBlockedItem(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExerciseDetails(exercise),
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            foregroundDecoration: BoxDecoration(
              color: Colors.grey,
              backgroundBlendMode: BlendMode.saturation,
            ),
            child: Card(
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildImage(context),
                  SizedBox(
                    height: 3,
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    child: Text(
                      exercise.situationStr != null
                          ? exercise.situationStr
                          : '',
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2
                          .apply(fontSizeFactor: 0.65),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    child: Text(
                      exercise.itemStr,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2
                          .apply(fontSizeFactor: 0.8),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 8.0,
            right: 8.0,
            child: Container(
              height: 25.0,
              width: 25.0,
              decoration: new BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Image.asset("assets/images/padlock.png"),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCompletedItem(BuildContext context) {
    return Stack(
      children: [
        Container(
          child: Card(
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildImage(context),
                SizedBox(
                  height: 3,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  child: Text(
                    exercise.situationStr != null ? exercise.situationStr : '',
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .apply(fontSizeFactor: 0.65),
                    textAlign: TextAlign.justify,
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  child: Text(
                    exercise.itemStr,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .apply(fontSizeFactor: 0.8),
                    textAlign: TextAlign.justify,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 8.0,
          right: 8.0,
          child: Container(
            height: 25.0,
            width: 25.0,
            decoration: new BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Image.asset("assets/images/comprobar_verde.png"),
          ),
        )
      ],
    );
  }

  Widget _buildInProgressItem(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExerciseDetails(exercise),
          ),
        );
      },
      child: Container(
        child: Card(
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildImage(context),
              SizedBox(
                height: 3,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                child: Text(
                  exercise.situationStr != null ? exercise.situationStr : '',
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2
                      .apply(fontSizeFactor: 0.65),
                  textAlign: TextAlign.justify,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                child: Text(
                  exercise.itemStr,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      .apply(fontSizeFactor: 0.8),
                  textAlign: TextAlign.justify,
                ),
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (exercise.status == ExerciseStatus.waiting)
      child = _buildBlockedItem(context);
    else if (exercise.status == ExerciseStatus.completed)
      child = _buildCompletedItem(context);
    else
      child = _buildInProgressItem(context);

    return child;
  }
}
