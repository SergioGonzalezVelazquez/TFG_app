import 'dart:io';
import 'package:tfg_app/services/auth.dart';
import 'package:android_intent/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:tfg_app/pages/user/login_page.dart';
import 'package:tfg_app/themes/custom_icon_icons.dart';
import 'package:tfg_app/widgets/buttons.dart';
import 'package:tfg_app/widgets/inputs.dart';
import 'package:tfg_app/widgets/progress.dart';
import 'package:tfg_app/widgets/snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

class ResetPasswordPage extends StatefulWidget {
  ///Creates a StatelessElement to manage this widget's location in the tree.
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  // Create controller for handle changes in email field
  TextEditingController _emailController = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is removed from the
    // widget tree.
    _emailController.dispose();
    super.dispose();
  }

  /**
   * Functions used to handle events in this screen 
   */

  Future<void> _sendResetPasswordEmail() async {
    setState(() {
      _isLoading = true;
    });
    await resetPassword(_emailController.text.trim()).catchError((error) {
      print("error");
    }).then((value) {
      setState(() {
        _emailSent = true;
      });
    });
    setState(() {
      _isLoading = false;
    });
  }

  /// Open default email app
  void _openEmailApp() {
    Route loginRoute =
        new MaterialPageRoute(builder: (context) => new LoginPage());

    final snackBar = customSnackbar(
        context, "No se pudo abrir ninguna aplicación de correo electrónico");

    if (Platform.isAndroid) {
      AndroidIntent intent = AndroidIntent(
        action: 'android.intent.action.MAIN',
        category: 'android.intent.category.APP_EMAIL',
      );
      intent.launch().catchError((e) {
        _scaffoldKey.currentState.showSnackBar(snackBar);
      }).then((value) {
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacement(context, loginRoute);
      });
    } else if (Platform.isIOS) {
      launch("message://").catchError((e) {
        _scaffoldKey.currentState.showSnackBar(snackBar);
      }).then((value) {
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacement(context, loginRoute);
      });
    }
  }

  Widget _linkToLogin() {
    return InkWell(
      onTap: () {
        Route route =
            new MaterialPageRoute(builder: (context) => new LoginPage());
        Navigator.push(context, route);
      },
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

  Widget _emailSentPage() {
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
            "¡Comprueba tu bandeja de entrada!",
            style: Theme.of(context).textTheme.headline6.copyWith(fontSize: 18),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          Text(
            "Te hemos enviado un correo con un enlace para recuperar tu contraseña",
            textAlign: TextAlign.justify,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          primaryButton(context, _openEmailApp, "Abrir correo electónico"),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          _linkToLogin(),
        ],
      ),
    );
  }

  Widget _resetPwdPage() {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.1),
      child: ListView(
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.10,
          ),
          Image.asset(
            'assets/images/olvido.png',
            height: MediaQuery.of(context).size.height * 0.15,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          Text(
            "Recuperación de contraseña",
            style: Theme.of(context).textTheme.headline6,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          Text(
            "Escribe tu correo electrónico. Recibirás un enlace para establecer una nueva contraseña",
            textAlign: TextAlign.justify,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          customTextInput("Correo Electrónico", CustomIcon.mail,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.1,
          ),
          primaryButton(
              context, _sendResetPasswordEmail, "Recuperar contraseña"),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          _linkToLogin(),
        ],
      ),
    );
  }

  /**
   * Widgets (ui components) used in this screen 
   */

  @override
  Widget build(BuildContext context) {
    Widget children;

    if (_isLoading)
      children = circularProgress(context, text: 'Enviando correo electrónico');
    else if (_emailSent)
      children = _emailSentPage();
    else
      children = _resetPwdPage();
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Recuperar contraseña'),
        actions: <Widget>[],
      ),
      body: children,
    );
  }
}
