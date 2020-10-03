import 'package:flutter/material.dart';

import '../../services/auth.dart';
import '../../themes/custom_icon_icons.dart';
import '../../utils/validators.dart';
import '../../widgets/buttons.dart';
import '../../widgets/inputs.dart';
import '../../widgets/progress.dart';
import '../../widgets/snackbar.dart';
import '../root_page.dart';
import 'email_verification.dart';
import 'reset_password.dart';
import 'signup_page.dart';

final Color facebook = Color(0xff3b5998);
final Color facebookDark = Color(0xff2f477a);
final Color google = Color(0xffdb4a39);
final Color googleDark = Color(0xffbb3222);

class LoginPage extends StatefulWidget {
  /// Name use for navigate to this screen
  static const route = "/login";

  ///Creates a StatelessElement to manage this widget's location in the tree.
  _LoginPageState createState() => _LoginPageState();
}

/// State object for LoginPage that contains fields that affect
/// how it looks.
class _LoginPageState extends State<LoginPage> {
  // Create controllers for handle changes in email and pwd text fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  // Create a global key that uniquely identifies the Scaffold widget,
  // and allows to display snackbars.
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  final _formKey = GlobalKey<FormState>();

  // Flag to show/hide password
  bool _showPassword = false;

  // Flags to render loading spinner UI.
  bool _isLoading = false;
  String _isLoadingMsg = "";

  AuthService _authService;

  /// Method called when this widget is inserted into the tree.
  @override
  void initState() {
    _authService = AuthService();
    super.initState();
  }

  /// Clean up the controllers when the widget is removed from the
  /// widget tree.
  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  /*
   * Functions used to handle events in this screen 
   */

  /// Display a message to the user when social sign
  /// in failed
  void _onSignInSocialError(BuildContext context, error) {
    setState(() {
      _isLoading = false;
    });

    String authError;
    switch (error.code.toString().toUpperCase()) {
      case 'NETWORK_ERROR':
        authError = """No se pudo conectar. Compruebe su conexión a Internet e 
            intentelo de nuevo más tarde.""";
        break;
      case 'ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL':
        authError =
            """Esta cuenta de correo electrónico ya está asociada a otro método
            de acceso. """;
        break;
      case 'ERROR_OPERATION_NOT_ALLOWED':
        authError = 'ERROR_OPERATION_NOT_ALLOWED';
        break;
      case 'ERROR_INVALID_ACTION_CODE':
        authError = 'ERROR_INVALID_ACTION_CODE';
        break;
      default:
        authError = """No se pudo iniciar sesión. Inténtelo de nuevo más 
        tarde""";
        break;
    }

    final snackBar = customSnackbar(context, authError);
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  /// Display a message to the user when email and password
  /// login failed
  void _onSignInEmailError(BuildContext context, error) {
    setState(() {
      _isLoading = false;
      _passController.clear();
    });
    String authError;
    switch (error.code.toString().toUpperCase()) {
      case 'ERROR_NETWORK_REQUEST_FAILED':
        authError = """No se pudo conectar. Compruebe su conexión a Internet e 
            intentelo de nuevo más tarde.""";
        break;
      case 'ERROR_INVALID_EMAIL':
        authError = 'Introduce una cuenta de correo electrónico válida';
        break;
      case 'ERROR_WRONG_PASSWORD':
        authError = 'La contraseña que has introducido es incorrecta';
        break;
      case 'ERROR_USER_NOT_FOUND':
        authError =
            """El correo electrónico que has introducido no coincide con ninguna 
            cuenta""";
        break;
      case 'ERROR_USER_DISABLED':
        authError =
            'El usuario vinculado a esa cuenta de correo ha sido desactivado';
        break;
      default:
        authError = 'Error';
        break;
    }

    final snackBar = customSnackbar(context, authError);
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  /// Authenticate Using Facebook account
  Future<void> _signInFacebook(BuildContext context) async {
    setState(() {
      _isLoadingMsg = "Iniciando sesión con Facebook";
      _isLoading = true;
    });

    await _authService.signInWithFacebook().catchError(
          (error) => _onSignInSocialError(context, error),
        );

    if (_authService.isAuth) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(RootPage.route, (route) => false);
    }

    setState(() {
      _isLoading = false;
      _isLoadingMsg = "";
    });
  }

  /// Authenticate Using Google Sign-In
  Future<void> _signInGoogle(BuildContext context) async {
    setState(() {
      _isLoadingMsg = "Iniciando sesión con Google";
      _isLoading = true;
    });
    await _authService
        .signInWithGoogle()
        .catchError((error) => _onSignInSocialError(context, error));

    if (_authService.isAuth) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(RootPage.route, (route) => false);
    }
    setState(() {
      _isLoading = false;
      _isLoadingMsg = "";
    });
  }

  /// Authenticate Using Email and Password
  Future<void> signInEmail(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      setState(() {
        _isLoadingMsg = "Iniciando sesión";
        _isLoading = true;
      });

      await _authService
          .signInWithEmail(_emailController.text.trim(), _passController.text)
          .catchError((error) => _onSignInEmailError(context, error));

      if (_authService.isAuth) {
        if (await _authService.isEmailVerified()) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil(RootPage.route, (route) => false);
        } else {
          Navigator.popUntil(context, (route) => route.isFirst);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => EmailVerificationPage(
                _emailController.text.trim(),
              ),
            ),
          );
        }
      }

      setState(() {
        _isLoading = false;
        _isLoadingMsg = "";
      });
    }
  }

  /// Widgets (ui components) used in this screen

  Widget _linkToSignUp() {
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(SignUpPage.route),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "¿Aún no tienes cuenta?",
          ),
          SizedBox(width: 5),
          Text(
            "Regístrate",
            style: TextStyle(
                color: (Theme.of(context).primaryColor),
                fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }

  Widget _linkResetPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, ResetPasswordPage.route),
        child: Text(
          "¿Has olvidado tu contraseña?",
        ),
      ),
    );
  }

  Widget _socialButton(String text, Color color, Color colorDark, double width,
      IconData icon, Function onPressed) {
    return Container(
      width: width,
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        color: color,
        onPressed: onPressed,
        padding: EdgeInsets.symmetric(vertical: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: width * 0.3,
              decoration: BoxDecoration(
                color: colorDark,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  topLeft: Radius.circular(10),
                ),
              ),
              child: Icon(
                icon,
                size: 18,
              ),
              padding: EdgeInsets.symmetric(vertical: 10),
            ),
            SizedBox(
              width: width * 0.1,
            ),
            Text(
              text,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _socialLogin(BuildContext context) {
    double btnWidth = MediaQuery.of(context).size.width * 0.37;

    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            //Horizontal line
            Container(
              width: MediaQuery.of(context).size.width / 5,
              height: 1.0,
              color: Colors.black26.withOpacity(.2),
            ),
            Text("O entra con"),
            Container(
              width: MediaQuery.of(context).size.width / 5,
              height: 1.0,
              color: Colors.black26.withOpacity(.2),
            ),
          ],
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.01,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _socialButton("Facebook", facebook, facebookDark, btnWidth,
                CustomIcon.facebook, () async {
              await _signInFacebook(context);
            }),
            _socialButton(
                "Google", google, googleDark, btnWidth, CustomIcon.google,
                () async {
              await _signInGoogle(context);
            }),
          ],
        ),
      ],
    );
  }

  /// Adds a form to sign in existing users with their email and password
  /// and validates them
  Form _signInForm(BuildContext context, double verticalPadding) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          customTextInput("Correo Electrónico", CustomIcon.mail,
              controller: _emailController,
              validator: Validator.email,
              keyboardType: TextInputType.emailAddress),
          SizedBox(
            height: verticalPadding,
          ),
          customPasswordInput(
            "Contraseña",
            CustomIcon.lock,
            controller: _passController,
            validator: Validator.passwordPresent,
            visible: _showPassword,
            visibleController: () {
              setState(
                () {
                  _showPassword = !_showPassword;
                },
              );
            },
          ),
        ],
      ),
    );
  }

  /// Build login screen widgets
  Widget _loginPage() {
    final double witdth = MediaQuery.of(context).size.width;
    final double verticalPadding = MediaQuery.of(context).size.height * 0.02;
    final double horizontalPadding = witdth * 0.1;
    final double imageWidth = witdth * 0.49;
    return SafeArea(
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height * 0.3,
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.02),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  width: witdth - horizontalPadding - imageWidth,
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
          _signInForm(context, verticalPadding),
          SizedBox(
            height: verticalPadding,
          ),
          _linkResetPassword(),
          SizedBox(
            height: verticalPadding * 2,
          ),
          // Sign in button
          primaryButton(context, () async {
            await signInEmail(context);
          }, "Iniciar sesión"),
          SizedBox(
            height: verticalPadding,
          ),
          _linkToSignUp(),
          SizedBox(
            height: verticalPadding * 3,
          ),
          _socialLogin(context),
        ],
      ),
    );
  }

  /// Describes the part of the user interface represented by this widget.
  /// The given BuildContext contains information about the location in the
  /// tree at which this widget is being built.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: _isLoading
          ? circularProgress(context, text: _isLoadingMsg)
          : _loginPage(),
    );
  }
}
