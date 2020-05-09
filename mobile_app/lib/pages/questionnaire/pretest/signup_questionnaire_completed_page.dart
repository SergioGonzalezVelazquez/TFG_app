import 'package:flutter/material.dart';
import 'package:tfg_app/pages/home_page.dart';
import 'package:tfg_app/widgets/buttons.dart';
import 'package:tfg_app/widgets/progress.dart';
import 'package:tfg_app/services/auth.dart';

class SignUpQuestionnaireCompleted extends StatefulWidget {
  /// Name use for navigate to this screen
  static const route = "/signUpQuestionnaireCompleted";

  ///Creates a StatelessElement to manage this widget's location in the tree.
  _SignUpQuestionnaireCompletedState createState() =>
      _SignUpQuestionnaireCompletedState();
}

class _SignUpQuestionnaireCompletedState
    extends State<SignUpQuestionnaireCompleted> {
  // Flag to render loading spinner UI.
  bool _isLoading = true;

  // Create a global key that uniquely identifies the Scaffold widget,
  // and allows to display snackbars.
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  AuthService _authService;

  /// Method called when this widget is inserted into the tree.
  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _createPatient();
  }

  /// Returns a string representation of this object.
  @override
  void dispose() {
    super.dispose();
  }

  /**
  * Functions used to handle events in this screen 
  */

  /// Creates document in 'patient' collection for current auth user
  Future<void> _createPatient() async {
    await _authService.createPatient();
    setState(() {
      _isLoading = false;
    });
  }

  /**
  * Widgets (ui components) used in this screen 
  */
  Widget _buildPage(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: width * 0.07, vertical: height * 0.01),
      child: ListView(
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          Text(
            "¡Cuestionario completado!",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline5,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          Image.asset(
            'assets/images/2154468_e.jpg',
            height: MediaQuery.of(context).size.height * 0.30,
            fit: BoxFit.contain,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.07,
          ),
          Text(
            "¡Genial " +
                AuthService().user.name.split(" ")[0] +
                "! Tus respuestas nos han ayudado a encontrar el perfil terapéutico que mejor encaja contigo.",
            textAlign: TextAlign.justify,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          Text(
            "Antes de empezar con la terapia, vamos a configurar algunas funcionalidades de la aplicación.",
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget _bottonNavigationBar(BuildContext parentContext) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: width * 0.07, vertical: height * 0.02),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          primaryButton(
              context,
              () => Navigator.pushNamed(context, HomePage.routeAuth),
              "Continuar",
              width: MediaQuery.of(context).size.width * 0.25),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor:  Color(0xffe8eaf6),
      key: _scaffoldKey,
      body: _isLoading ? circularProgress(context) : _buildPage(context),
      bottomNavigationBar: _isLoading ? null : _bottonNavigationBar(context),
    );
  }
}
