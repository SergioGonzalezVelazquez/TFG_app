// Import the firebase_core plugin
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

import 'routes.dart';
import 'themes/style.dart';

final DateFormat dateFormatter = DateFormat('dd-MM-yyyy');
final DateFormat timeFormatter = DateFormat(DateFormat.HOUR24_MINUTE);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('es', 'ES'),
      ],
    );
  }
}
