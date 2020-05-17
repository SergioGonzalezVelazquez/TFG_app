import 'package:flutter/material.dart';

Widget primaryButton(BuildContext context, Function onPressed, String text,
    {double fontSizeFactor = 1.0,
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
        style: Theme.of(context).textTheme.button.apply(
          color: !light ? Colors.white : primaryColor,
          fontWeightDelta: 1,
          fontSizeFactor: fontSizeFactor
        )
      ),
    ),
  );
}
