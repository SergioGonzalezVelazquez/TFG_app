import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tfg_app/routes.dart';
import 'package:tfg_app/themes/style.dart';

final DateFormat dateFormatter = new DateFormat('dd-MM-yyyy');
final DateFormat timeFormatter = DateFormat(DateFormat.HOUR24_MINUTE);

void main() {
  runApp(STOPMiedo());
}

class STOPMiedo extends StatelessWidget {
  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stop Miedo',
      debugShowCheckedModeBanner: false,
      routes: appRoutes,
      theme: CustomTheme.buildPurpleTheme(),
    );
  }
}
