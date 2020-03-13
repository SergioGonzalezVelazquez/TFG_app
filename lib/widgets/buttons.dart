import 'package:flutter/material.dart';

Widget primaryButton(BuildContext context, Function onPressed, String text,
    {int fontSize, Color color, double width}) {
  return Container(
    width: width ?? MediaQuery.of(context).size.width,
    margin: EdgeInsets.symmetric(horizontal: 100),
    child: RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      onPressed: onPressed,
      padding: EdgeInsets.symmetric(vertical: 15),
      color: Theme.of(context).primaryColor,
      child: color ??
          Text(text,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize ?? 16,
                  fontWeight: FontWeight.w800)),
    ),
  );
}
