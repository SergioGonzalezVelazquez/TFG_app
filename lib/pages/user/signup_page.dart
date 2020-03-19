import 'package:flutter/material.dart';
import 'package:tfg_app/pages/user/login_page.dart';
import 'package:tfg_app/pages/user/email_verification.dart';
import 'package:tfg_app/services/auth.dart';
import 'package:tfg_app/themes/custom_icon_icons.dart';
import 'package:tfg_app/widgets/buttons.dart';
import 'package:tfg_app/widgets/inputs.dart';
import 'package:tfg_app/widgets/progress.dart';
import 'package:tfg_app/widgets/snackbar.dart';

class SignUpPage extends StatefulWidget {
  ///Creates a StatelessElement to manage this widget's location in the tree.
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // Create controllers for handle changes in email and pwd text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _passConfirmController = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Detects when user signed in
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is removed from the
    // widget tree.
    _nameController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _passConfirmController.dispose();
    super.dispose();
  }

  /**
   * Functions used to handle events in this screen 
   */

  void onSignUpError(BuildContext context, error) {
    setState(() {
      _isLoading = false;
    });
    String msg = signUpErrorMsg(error);
    print(msg);

    final snackBar = customSnackbar(context, msg, actionLabel: "Reintentar",
        action: () async {
      await signUp(context);
    });
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  Future<void> signUp(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    bool register = await registerWithEmail(_nameController.text.trim(),
            _emailController.text.trim(), _passController.text)
        .catchError((error) => onSignUpError(context, error));

    if (register) {
      Route route = new MaterialPageRoute(
          builder: (context) =>
              new EmailVerificationPage(_emailController.text.trim()));
      Navigator.pushReplacement(context, route);
    }
    setState(() {
      _isLoading = false;
    });
  }

  /**
   * Widgets (ui components) used in this screen 
   */

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

  Widget _signUpPage() {
    double verticalPadding = MediaQuery.of(context).size.height * 0.02;
    return ListView(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.1),
      children: <Widget>[
        Container(
            height: MediaQuery.of(context).size.height * 0.3,
            color: Colors.black12
            //child: _background(),
            ),
        SizedBox(
          height: verticalPadding,
        ),
        customTextInput("Nombre y apellidos", CustomIcon.user,
            controller: _nameController),
        SizedBox(
          height: verticalPadding,
        ),
        customTextInput("Correo Electrónico", CustomIcon.mail,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress),
        SizedBox(
          height: verticalPadding,
        ),
        customPasswordInput("Contraseña", CustomIcon.lock,
            controller: _passController),
        SizedBox(
          height: verticalPadding,
        ),
        customPasswordInput("Confirmar contraseña", CustomIcon.lock,
            controller: _passConfirmController),
        SizedBox(
          height: verticalPadding,
        ),
        primaryButton(context, () async {
          await signUp(context);
        }, "Crear cuenta"),
        _linkToLogin()
      ],
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
