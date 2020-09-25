import 'package:flutter/material.dart';

class ExerciseHelp extends StatelessWidget {
  static const route = "exerciseHelp";

  Widget _buildHeader(BuildContext context, String title) {
    return Text(
      title,
      textAlign: TextAlign.start,
      style: Theme.of(context)
          .textTheme
          .headline6
          .apply(fontSizeFactor: 0.7, fontWeightDelta: 2),
    );
  }

  Widget _buildPage(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final TextStyle textStyle =
        Theme.of(context).textTheme.bodyText2.apply(fontSizeFactor: 0.9);

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: width * 0.07, vertical: height * 0.01),
      child: ListView(
        children: <Widget>[
          SizedBox(
            height: height * 0.02,
          ),
          RichText(
            textAlign: TextAlign.justify,
            text: TextSpan(
              text:
                  "La técnica que utilizamos para ayudarte a superar tu ansiedad al volante se basa en la ",
              style: textStyle,
              children: <TextSpan>[
                TextSpan(
                  text: 'exposición real',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: ', de manera'),
                TextSpan(
                  text: ' gradual, ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: 'al estímulo temido. ',
                ),
              ],
            ),
          ),
          SizedBox(
            height: height * 0.01,
          ),
          RichText(
            textAlign: TextAlign.justify,
            text: TextSpan(
              text: "Se conoce cómo ",
              style: textStyle,
              children: <TextSpan>[
                TextSpan(
                  text: 'exposición en vivo, ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      'y ha demostrado ser hasta el momento actual el procedimiento más eficaz y efectivo para el abordaje de algunos trastornos de ansiedad. ',
                ),
              ],
            ),
          ),
          SizedBox(
            height: height * 0.03,
          ),
          _buildHeader(context, "Duración de la exposición"),
          Text(
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec efficitur ante at massa porta faucibus. Morbi tellus orci, blandit sed.",
            textAlign: TextAlign.justify,
            style: textStyle,
          ),
          SizedBox(
            height: height * 0.03,
          ),
          _buildHeader(context, "Criterio para dar por superado un paso"),
          Text(
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec efficitur ante at massa porta faucibus. Morbi tellus orci, blandit sed.",
            textAlign: TextAlign.justify,
            style: textStyle,
          ),
          SizedBox(
            height: height * 0.03,
          ),
          _buildHeader(context, "Periocidad de la exposición"),
          Text(
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec efficitur ante at massa porta faucibus. Morbi tellus orci, blandit sed.",
            textAlign: TextAlign.justify,
            style: textStyle,
          ),
          SizedBox(
            height: height * 0.03,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exposición en vivo'),
      ),
      body: _buildPage(context),
    );
  }
}
