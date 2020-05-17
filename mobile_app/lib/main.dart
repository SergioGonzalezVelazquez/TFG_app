import 'package:flutter/material.dart';
import 'package:tfg_app/pages/home_page.dart';
import 'package:tfg_app/pages/phy_activity/phy_activity_agreement.dart';
import 'package:tfg_app/routes.dart';
import 'package:tfg_app/themes/style.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stop Miedo',
      debugShowCheckedModeBanner: false,
      routes: appRoutes,
      theme: CustomTheme.buildPurpleTheme(),
      home: HomePage(),
    );
  }
}
