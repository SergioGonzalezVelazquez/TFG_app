import 'package:flutter/material.dart';

SnackBar customSnackbar(BuildContext context, String text,
    {String actionLabel,
    Function action,
    SnackBarBehavior behavior = SnackBarBehavior.fixed}) {
  return SnackBar(
    behavior: behavior,
    content: Text(
      text,
      style: TextStyle(fontSize: 12),
    ),
    action: actionLabel != null
        ? SnackBarAction(
            label: actionLabel,
            textColor: Theme.of(context).primaryColor,
            onPressed: action,
          )
        : null,
  );
}
