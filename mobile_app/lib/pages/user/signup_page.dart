import 'package:flutter/material.dart';
import 'package:tfg_app/pages/user/login_page.dart';
import 'package:tfg_app/pages/user/email_verification.dart';
import 'package:tfg_app/services/auth.dart';
import 'package:tfg_app/themes/custom_icon_icons.dart';
import 'package:tfg_app/utils/validators.dart';
import 'package:tfg_app/widgets/buttons.dart';
import 'package:tfg_app/widgets/inputs.dart';
import 'package:tfg_app/widgets/password_strength.dart';
import 'package:tfg_app/widgets/progress.dart';
import 'package:tfg_app/widgets/snackbar.dart';

class SignUpPage extends StatefulWidget {
  /// Name use for navigate to this screen
  static const route = "/signup";

  /// Creates a StatelessElement to manage this widget's location in the tree.
  _SignUpPageState createState() => _SignUpPageState();
}

/// State object for SignUpPage that contains fields that affect
/// how it looks.
class _SignUpPageState extends State<SignUpPage> {
  // Create controllers for handle changes in email and pwd text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _passConfirmController = TextEditingController();

  // Create a global key that uniquely identifies the Scaffold widget,
  // and allows to display snackbars.
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  final _formKey = GlobalKey<FormState>();

  // password strength estimator
  double _passwordStrength = 0;

  //Flags to show/hide passwords
  bool _showPassword1 = false;
  bool _showPassword2 = false;

  // Flags to render loading spinner UI.
  bool _isLoading = false;

  AuthService _authService;

  /// Method called when this widget is inserted into the tree.
  @override
  void initState() {
    super.initState();
    _authService = AuthService();
  }

  // Clean up the controllers when the widget is removed from the
  // widget tree.
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _passConfirmController.dispose();
    super.dispose();
  }

  /**
   * Functions used to handle events in this screen 
   */

  /// Display a message to the user when sign up
  /// failed
  void _onSignUpError(BuildContext context, error) {
    setState(() {
      _isLoading = false;
    });
    String authError;
    switch (error.code.toString().toUpperCase()) {
      case 'ERROR_NETWORK_REQUEST_FAILED':
        authError =
            'No se pudo conectar. Compruebe su conexión a Internet e intentelo de nuevo más tarde.';
        break;
      case 'ERROR_WEAK_PASSWORD':
        authError = 'Tu contraseña debe tener al menos 6 caracteres';
        break;
      case 'ERROR_INVALID_EMAIL':
        authError = 'Introduce una cuenta de correo electrónico válida';
        break;
      case 'ERROR_EMAIL_ALREADY_IN_USE':
        authError = 'Ya hay una cuenta registrada con esa dirección de correo';
        break;
      default:
        authError =
            'No se pudo completar el registro. Inténtalo de nuevo más tarde.';
        break;
    }

    final snackBar = customSnackbar(context, authError);
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  /// Sign up new users
  Future<void> _signUp(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      setState(() {
        _isLoading = true;
      });

      bool register = await _authService
          .registerWithEmail(_nameController.text.trim(),
              _emailController.text.trim(), _passController.text)
          .catchError((error) => _onSignUpError(context, error));

      if (register) {
        Route route = new MaterialPageRoute(
          builder: (context) => new EmailVerificationPage(
            _emailController.text.trim(),
          ),
        );
        Navigator.pushReplacement(context, route);
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  /**
   * Widgets (ui components) used in this screen 
   */

  Widget _linkToLogin() {
    return InkWell(
      onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(
          LoginPage.route, (Route<dynamic> route) => false),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "¿Ya estás registrado?",
          ),
          SizedBox(width: 5),
          Text(
            "Inicia Sesión",
            style: TextStyle(
                color: (Theme.of(context).primaryColor),
                fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }

  /// Adds a form to sign up new users their email and password
  Form _signUpForm(BuildContext context, double verticalPadding) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          customTextInput("Nombre y apellidos", CustomIcon.user,
              validator: (val) => Validator.username(val),
              controller: _nameController),
          SizedBox(
            height: verticalPadding,
          ),
          customTextInput("Correo Electrónico", CustomIcon.mail,
              controller: _emailController,
              validator: (val) => Validator.email(val),
              keyboardType: TextInputType.emailAddress),
          SizedBox(
            height: verticalPadding,
          ),
          customPasswordInput("Contraseña", CustomIcon.lock,
              controller: _passController,
              validator: (val) => Validator.validPassword(val),
              visible: _showPassword1,
              visibleController: () {
                setState(() {
                  _showPassword1 = !_showPassword1;
                });
              },
              onChanged: (val) {
                setState(() {
                  _passwordStrength = Validator.passwordStrength(val);
                });
              }),
          Visibility(
            child: passwordStrengthPercent(context, _passwordStrength),
            visible:
                _passController.text != null && _passController.text.isNotEmpty,
          ),
          SizedBox(
            height: verticalPadding,
          ),
          customPasswordInput(
            "Confirmar contraseña",
            CustomIcon.lock,
            controller: _passConfirmController,
            validator: (val) =>
                Validator.confirmPassword(_passController.text, val),
            visible: _showPassword2,
            visibleController: () {
              setState(
                () {
                  _showPassword2 = !_showPassword2;
                },
              );
            },
          ),
        ],
      ),
    );
  }

  /// Build signup screen widgets
  Widget _signUpPage() {
    double verticalPadding = MediaQuery.of(context).size.height * 0.02;
    return SafeArea(
      child: ListView(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.1),
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height * 0.3,
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.02),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: Text(
                    "Supera la ansiedad al volante",
                    style: Theme.of(context).textTheme.headline6.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                //Stop Image
                Image.asset(
                  'assets/images/stop.png',
                ),
              ],
            ),
          ),
          _signUpForm(context, verticalPadding),
          SizedBox(
            height: verticalPadding * 2,
          ),
          primaryButton(context, () async {
            await _signUp(context);
          }, "Crear cuenta"),
          SizedBox(
            height: verticalPadding,
          ),
          _linkToLogin()
        ],
      ),
    );
  }

  ///Describes the part of the user interface represented by this widget.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: _isLoading
            ? circularProgress(context, text: "Creando cuenta")
            : _signUpPage());
  }
}
