import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tfg_app/models/app_settings.dart';
import 'package:tfg_app/routes.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tfg_app/themes/style.dart';
// Import the firebase_core plugin
import 'package:firebase_core/firebase_core.dart';

final DateFormat dateFormatter = new DateFormat('dd-MM-yyyy');
final DateFormat timeFormatter = DateFormat(DateFormat.HOUR24_MINUTE);

// App entry point
void main() async {
  AppSettings settings = AppSettings();

  // Initialized Firebase app
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(STOPMiedo());
}

class STOPMiedo extends StatelessWidget {
  final AppSettings settings;

  const STOPMiedo({Key key, this.settings}) : super(key: key);

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
