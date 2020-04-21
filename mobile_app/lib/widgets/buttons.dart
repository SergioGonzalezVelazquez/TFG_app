import 'package:flutter/material.dart';

Widget primaryButton(BuildContext context, Function onPressed, String text,
    {int fontSize,
    Color color,
    double width,
    bool light = false,
    bool enabled = true}) {
  Color primaryColor = Theme.of(context).primaryColor;
  return Container(
    width: width ?? MediaQuery.of(context).size.width,
    child: RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: enabled ? primaryColor : Colors.grey),
      ),
      onPressed: enabled ? onPressed : null,
      padding: EdgeInsets.symmetric(vertical: 10),
      color: !light ? primaryColor : Colors.white,
      child: Text(
        text,
        style: TextStyle(
            color: !light ? Colors.white : primaryColor,
            //fontSize: fontSize ?? 14,
            fontWeight: FontWeight.w800),
      ),
    ),
  );
}
