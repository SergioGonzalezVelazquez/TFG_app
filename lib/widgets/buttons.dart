import 'package:flutter/material.dart';

Widget primaryButton(BuildContext context, Function onPressed, String text,
    {int fontSize, Color color, double width}) {
  return Container(
    width: MediaQuery.of(context).size.width,
    child: RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      onPressed: onPressed,
      padding: EdgeInsets.symmetric(vertical: 10),
      color: Theme.of(context).primaryColor,
      child: Text(text,
          style: TextStyle(
              color: Colors.white,
              fontSize: fontSize ?? 14,
              fontWeight: FontWeight.w800)),
    ),
  );
}
