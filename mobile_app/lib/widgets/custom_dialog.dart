import 'package:flutter/material.dart';

/// Custom Dialog in Flutter
/// https://medium.com/@excogitatr/custom-dialog-in-flutter-d00e0441f1d5
class CustomDialog extends StatelessWidget {
  final String title, description, buttonText1, buttonText2;
  final Image image;
  final Function buttonFunction1;
  final Function buttonFunction2;

  CustomDialog({
    this.title,
    this.description,
    this.buttonText1,
    this.buttonText2,
    this.buttonFunction1,
    this.buttonFunction2,
    this.image,
  });

  Widget _dialogContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(
        16.0,
      ),
      decoration: new BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(16.0),
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
          Text(title, style: Theme.of(context).textTheme.headline6),
          SizedBox(height: 16.0),
          Text(description,
              textAlign: TextAlign.justify,
              style: Theme.of(context).textTheme.bodyText2),
          SizedBox(height: 24.0),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Visibility(
                visible: buttonText2 != null && buttonFunction2 != null,
                child: InkWell(
                  onTap: buttonFunction2,
                  child: Text(buttonText2),
                ),
              ),
              SizedBox(
                width: 40,
              ),
              InkWell(
                onTap: buttonFunction1,
                child: Text(
                  buttonText1,
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: _dialogContent(context),
    );
  }
}
