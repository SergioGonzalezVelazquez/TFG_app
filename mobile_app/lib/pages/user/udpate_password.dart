import 'package:flutter/material.dart';
import 'package:tfg_app/themes/custom_icon_icons.dart';
import 'package:tfg_app/utils/validators.dart';
import 'package:tfg_app/widgets/buttons.dart';
import 'package:tfg_app/widgets/inputs.dart';
import 'package:tfg_app/widgets/password_strength.dart';
import 'package:tfg_app/widgets/progress.dart';

class UpdatePassword extends StatefulWidget {
  /// Name use for navigate to this screen
  static const route = "/update-password";

  ///Creates a StatelessElement to manage this widget's location in the tree.
  _UpdatePasswordState createState() => _UpdatePasswordState();
}

class _UpdatePasswordState extends State<UpdatePassword> {
  // Create controllers for handle changes in pwd text fields
  final TextEditingController _oldPwdController = TextEditingController();
  final TextEditingController _newPwd1Controller = TextEditingController();
  final TextEditingController _newPwd2Controller = TextEditingController();

  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  final _formKey = GlobalKey<FormState>();

  //Flags to show/hide passwords
  bool _showPasswordOld = false;
  bool _showPasswordNew = false;
  bool _showPasswordNew2 = false;

  // password strength estimator
  double _passwordStrength = 0;

  bool _isLoading = false;

  // Create a global key that uniquely identifies the Scaffold widget,
  // and allows to display snackbars.
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is removed from the
    // widget tree.
    _oldPwdController.dispose();
    _newPwd1Controller.dispose();
    _newPwd2Controller.dispose();
    super.dispose();
  }

  /**
  * Functions used to handle events in this screen 
  */
  void _changePassword() {
    if (_formKey.currentState.validate()) {}
  }

  /**
  * Widgets (ui components) used in this screen 
  */
  Widget _changePasswordPage(BuildContext context) {
    double verticalPadding = MediaQuery.of(context).size.height * 0.02;
    return Form(
      key: _formKey,
      child: Center(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.only(top: 12.0, left: 15, right: 15),
          children: <Widget>[
            customPasswordInput(
              "Contraseña actual",
              CustomIcon.lock,
              controller: _oldPwdController,
              validator: (val) => Validator.passwordPresent(val),
              visible: _showPasswordOld,
              visibleController: () {
                setState(
                  () {
                    _showPasswordOld = !_showPasswordOld;
                  },
                );
              },
            ),
            SizedBox(
              height: verticalPadding,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Elige una contraseña segura y no la utilices en otras cuentas.",
                textAlign: TextAlign.justify,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height / 40),
            Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Si cambias la contraseña, cerrarás sesión en todos los dispositivos, incluido tu teléfono. Será necesario que introduzcas la nueva contraseña en todos tus dispositivos.",
                  textAlign: TextAlign.justify,
                )),
            SizedBox(height: MediaQuery.of(context).size.height / 40),
            customPasswordInput("Nueva contraseña", CustomIcon.lock,
                controller: _newPwd1Controller,
                validator: (val) => Validator.validPassword(val),
                visible: _showPasswordNew,
                visibleController: () {
                  setState(() {
                    _showPasswordNew = !_showPasswordNew;
                  });
                },
                onChanged: (val) {
                  setState(() {
                    _passwordStrength = Validator.passwordStrength(val);
                  });
                }),
            Visibility(
              child: passwordStrengthPercent(context, _passwordStrength),
              visible: _newPwd1Controller.text != null &&
                  _newPwd1Controller.text.isNotEmpty,
            ),
            SizedBox(
              height: verticalPadding,
            ),
            customPasswordInput(
                "Confirmar tu nueva contraseña", CustomIcon.lock,
                controller: _newPwd2Controller,
                validator: (val) =>
                    Validator.confirmPassword(_newPwd1Controller.text, val),
                visible: _showPasswordNew2,
                visibleController: () {
                  setState(() {
                    _showPasswordNew2 = !_showPasswordNew2;
                  });
                }),
            SizedBox(
              height: verticalPadding * 3,
            ),
            primaryButton(context, () async {
              await _changePassword();
            }, "Cambiar contraseña"),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Cambiar contraseña'),
        actions: <Widget>[],
      ),
      body: _isLoading
          ? circularProgress(context, text: "Actualizando contraseña")
          : _changePasswordPage(context),
    );
  }
}
