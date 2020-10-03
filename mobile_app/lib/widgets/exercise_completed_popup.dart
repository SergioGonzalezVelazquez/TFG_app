import 'package:flutter/material.dart';

import '../models/exercise.dart';

class ExerciseCompletedDialog extends StatelessWidget {
  final Exercise exercise;
  ExerciseCompletedDialog(this.exercise);

  Widget dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        //...bottom card part,
        Container(
          padding: EdgeInsets.only(
            top: 52,
            bottom: 16,
            left: 16,
            right: 16,
          ),
          margin: EdgeInsets.only(top: 66),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // To make the card compact
            children: <Widget>[
              Text(
                "¡Ejercicio completado!",
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 14.0),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: '¡Muy bien! Has conseguido reducir la ansiedad de "',
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2
                      .apply(fontSizeFactor: 1),
                  children: <TextSpan>[
                    TextSpan(
                      text: exercise.itemStr,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                        text:
                            '" y sientes la suficiente confianza para afrontar el siguiente paso.'),
                  ],
                ),
              ),
              SizedBox(height: 14.0),
              Align(
                alignment: Alignment.bottomRight,
                child: FlatButton(
                  padding: EdgeInsets.zero,
                  textColor: Theme.of(context).primaryColor,
                  onPressed: () {
                    // To close the dialog
                    Navigator.of(context).pop();
                  },
                  child: Text("Aceptar"),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 15,
          left: 16,
          right: 16,
          child: Image.asset(
            "assets/images/medalla.png",
            height: 100,
          ),
        ),
        //...top circlular image part,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }
}
