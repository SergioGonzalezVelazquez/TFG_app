import 'package:flutter/material.dart';
import 'package:tfg_app/pages/home_page.dart';
import 'package:tfg_app/pages/user/signup_page.dart';
import 'package:tfg_app/pages/user/reset_password.dart';
import 'package:tfg_app/services/auth.dart';
import 'package:tfg_app/themes/custom_icon_icons.dart';
import 'package:tfg_app/widgets/buttons.dart';
import 'package:tfg_app/widgets/inputs.dart';
import 'package:tfg_app/widgets/login_background.dart';
import 'package:tfg_app/widgets/progress.dart';
import 'package:tfg_app/widgets/snackbar.dart';

class LoginPage extends StatefulWidget {
  final Color facebook = Color(0xff3b5998);
  final Color facebookDark = Color(0xff2f477a);
  final Color google = Color(0xffdb4a39);
  final Color googleDark = Color(0xffbb3222);

  ///Creates a StatelessElement to manage this widget's location in the tree.
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Create controllers for handle changes in email and pwd text fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool _isLoading = false;
  String _isLoadingMsg = "";

  @override
  void initState() {
    super.initState();

    // Detects when user signed in
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is removed from the
    // widget tree.
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  /**
   * Functions used to handle events in this screen 
   */

  void onSignInSocialError(BuildContext context, error) {
    setState(() {
      _isLoading = false;
    });
    String msg = signInCredentialsErrorMsg(error);
    print("error");

    final snackBar = customSnackbar(context, msg, actionLabel: "Reintentar",
        action: () async {
      await signInGoogle(context);
    });
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  void onSignInEmailError(BuildContext context, error) {
    setState(() {
      _isLoading = false;
    });
    String msg = signInEmailErrorMsg(error);
    print(error.code.toString());

    final snackBar = customSnackbar(context, msg, actionLabel: "Reintentar",
        action: () async {
      await signInGoogle(context);
    });
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  Future<void> signInFacebook(BuildContext context) async {
    setState(() {
      _isLoadingMsg = "Iniciando sesión con Facebook";
      _isLoading = true;
    });

    await signInWithFacebook()
        .catchError((error) => onSignInSocialError(context, error));

    if (isAuth()) {
      Route route = new MaterialPageRoute(
          builder: (context) => new HomePage(
                isauth: true,
              ));
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(context, route);
    }
    setState(() {
      _isLoading = false;
      _isLoadingMsg = "";
    });
  }

  Future<void> signInGoogle(BuildContext context) async {
    setState(() {
      _isLoadingMsg = "Iniciando sesión con Google";
      _isLoading = true;
    });
    await signInWithGoogle()
        .catchError((error) => onSignInSocialError(context, error));

    if (isAuth()) {
      Route route = new MaterialPageRoute(
          builder: (context) => new HomePage(
                isauth: true,
              ));
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(context, route);
    }
    setState(() {
      _isLoading = false;
      _isLoadingMsg = "";
    });
  }

  Future<void> signInEmail(BuildContext context) async {
    setState(() {
      _isLoadingMsg = "Iniciando sesión";
      _isLoading = true;
    });
    await signInWithEmail(_emailController.text.trim(), _passController.text)
        .catchError((error) => onSignInEmailError(context, error));

    if (isAuth()) {
      print("isAuth");
      Route route = new MaterialPageRoute(
          builder: (context) => new HomePage(
                isauth: true,
              ));
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(context, route);
    } else {
      print("no auth");
    }
    setState(() {
      _isLoading = false;
      _isLoadingMsg = "";
    });
  }

  /**
   * Widgets (ui components) used in this screen 
   */

  Widget _background() {
    return LoginBackground();
  }

  Widget _btnLogin() {
    return primaryButton(context, () async {
      await signInEmail(context);
    }, "Iniciar sesión");
  }

  Widget _linkToSignUp() {
    return InkWell(
      onTap: () {
        Route route =
            new MaterialPageRoute(builder: (context) => new SignUpPage());
        Navigator.push(context, route);
      },
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
        onTap: () {
          Route route = new MaterialPageRoute(
              builder: (context) => new ResetPasswordPage());
          Navigator.push(context, route);
        },
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
            Text(text,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
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
            _socialButton("Facebook", widget.facebook, widget.facebookDark,
                btnWidth, CustomIcon.facebook, () async {
              await signInFacebook(context);
            }),
            _socialButton("Google", widget.google, widget.googleDark, btnWidth,
                CustomIcon.google, () async {
              await signInGoogle(context);
            }),
          ],
        ),
      ],
    );
  }

  Widget _loginPage() {
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
          _linkResetPassword(),
          SizedBox(
            height: verticalPadding * 2,
          ),
          Align(child: _btnLogin()),
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

  ///Describes the part of the user interface represented by this widget.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: _isLoading
            ? circularProgress(context, text: _isLoadingMsg)
            : _loginPage());
  }
}
