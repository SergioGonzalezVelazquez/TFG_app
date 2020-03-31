import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

Widget passwordStrengthPercent(BuildContext context, double passwordStrength) {
  Color color;
  String text;
  if (passwordStrength < 0.3) {
    color = Color(0xffb30000);
    text = "Poco segura";
  } else if (passwordStrength < 0.7) {
    color = Color(0xffff9900);
    text = "Segura";
  } else {
    color = Color(0xff008000);
    text = "Muy segura";
  }

  return Padding(
    padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.02, vertical: 5),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        LinearPercentIndicator(
            lineHeight: 4.0,
            padding: EdgeInsets.all(0),
            percent: passwordStrength,
            backgroundColor: Colors.black12,
            progressColor: color),
        Text(
          text,
          style: TextStyle(fontSize: 11),
        ),
      ],
    ),
  );
}
