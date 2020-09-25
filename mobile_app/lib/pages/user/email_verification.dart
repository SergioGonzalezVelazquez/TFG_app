import 'dart:async';
import 'dart:io';
// import 'package:android_intent/android_intent.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tfg_app/pages/questionnaire/pretest/signup_questionnaire_page.dart';
import 'package:tfg_app/pages/user/login_page.dart';
import 'package:tfg_app/services/auth.dart';
import 'package:tfg_app/widgets/buttons.dart';
import 'package:tfg_app/widgets/progress.dart';
import 'package:tfg_app/widgets/snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

class EmailVerificationPage extends StatefulWidget {
  /// Creates a StatelessElement to manage this widget's location in the tree.
  final String email;

  EmailVerificationPage(this.email);

  ///Creates a StatelessElement to manage this widget's location in the tree.
  _EmailVerificationPageState createState() => _EmailVerificationPageState();
}

/// State object for EmailVerificationPage that contains fields that affect
/// how it looks.
class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  // Flags to render loading spinner UI.
  bool _isLoading = false;

  // Repeating timer used to check if user has verified the email
  Timer _timer;

  /// Method called when this widget is inserted into the tree.
  @override
  void initState() {
    super.initState();
    _checkEmailVerification();
  }

  /// Cancels the timer when the widget is removed from the
  /// widget tree.
  @override
  void dispose() {
    super.dispose();
    if (_timer != null) {
      _timer.cancel();
    }
  }

  /**
   * Functions used to handle events in this screen 
   */

  /// Use a periodic timer to hold de app until the e-mail is verified.
  /// Reference:
  /// https://stackoverflow.com/questions/57192651/flutter-how-to-listen-to-the-firebaseuser-is-email-verified-boolean
  ///
  void _checkEmailVerification() async {
    _timer = Timer.periodic(
      Duration(seconds: 5),
      (timer) async {
        await FirebaseAuth.instance.currentUser()
          ..reload();
        var user = await FirebaseAuth.instance.currentUser();
        if (user.isEmailVerified) {
          setState(() {
            _isLoading = true;
            timer.cancel();
          });

          await AuthService().createUserDocument();
          Navigator.of(context).pushNamedAndRemoveUntil(
              SignUpQuestionnairePage.route, (Route<dynamic> route) => false);
        }
      },
    );
  }

  /// Open default email app
  /*
  void _openEmailApp() {
    final snackBar = customSnackbar(
        context, "No se pudo abrir ninguna aplicación de correo electrónico");

    if (Platform.isAndroid) {
      AndroidIntent intent = AndroidIntent(
        action: 'android.intent.action.MAIN',
        category: 'android.intent.category.APP_EMAIL',
      );
      intent.launch().catchError(
        (e) {
          _scaffoldKey.currentState.showSnackBar(snackBar);
        },
      );
    } else if (Platform.isIOS) {
      launch("message://").catchError(
        (e) {
          _scaffoldKey.currentState.showSnackBar(snackBar);
        },
      );
    }
  }
  */

  /**
   * Widgets (ui components) used in this screen 
   */

  Widget _linkToLogin() {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, LoginPage.route),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Volver a ",
          ),
          SizedBox(width: 5),
          Text(
            "Inicio de Sesión",
            style: TextStyle(
                color: (Theme.of(context).primaryColor),
                fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }

  Widget _emailVerificationPage() {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            'assets/images/correo.png',
            height: MediaQuery.of(context).size.height * 0.15,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          Text(
            "Verifica tu correo electrónico",
            style: Theme.of(context).textTheme.headline6,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          RichText(
            textAlign: TextAlign.justify,
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyText2,
              children: <TextSpan>[
                TextSpan(
                    text:
                        "Hemos enviado un correo electrónico de verificación a "),
                TextSpan(
                    text: widget.email,
                    style: TextStyle(fontWeight: FontWeight.bold))
              ],
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.01,
          ),
          Text(
            "¡Haz click en el enlace que has recibido para empezar!",
            textAlign: TextAlign.justify,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          primaryButton(context, () => print(""), "Abrir correo electónico"),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          _linkToLogin(),
        ],
      ),
    );
  }

  ///Describes the part of the user interface represented by this widget.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Email de verificación"),
        automaticallyImplyLeading: false, // Used for removing back buttoon.
      ),
      backgroundColor: Colors.white,
      body: _isLoading
          ? circularProgress(context, text: "Entrando")
          : _emailVerificationPage(),
    );
  }
}
