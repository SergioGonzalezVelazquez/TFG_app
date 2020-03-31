import 'package:flutter/material.dart';
import 'package:tfg_app/pages/user/login_page.dart';
import 'package:tfg_app/pages/user/udpate_password.dart';
import 'package:tfg_app/widgets/buttons.dart';
import 'package:tfg_app/services/auth.dart';
import 'package:tfg_app/widgets/progress.dart';
import 'package:tfg_app/pages/user/profile.dart';

class MorePage extends StatefulWidget {
  ///Creates a StatelessElement to manage this widget's location in the tree
  _MorePageState createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  bool _isLoadingLogout = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
  /**
   * Functions used to handle events in this screen 
   */

  Future<void> _logout() async {
    setState(() {
      _isLoadingLogout = true;
    });

    Route loginRoute =
        new MaterialPageRoute(builder: (context) => new LoginPage());

    await signOut();
    Navigator.popUntil(context, (route) => route.isFirst);
    Navigator.pushReplacement(context, loginRoute);

    setState(() {
      _isLoadingLogout = false;
    });
  }

  void _routeToProfile() {
    Route route =
        new MaterialPageRoute(builder: (context) => new ProfilePage());
    Navigator.popUntil(context, (route) => route.isFirst);
    Navigator.push(context, route);
  }

  void _routeToUpdatePassword() {
    Route route =
        new MaterialPageRoute(builder: (context) => new UpdatePassword());
    Navigator.popUntil(context, (route) => route.isFirst);
    Navigator.push(context, route);
  }

  Widget _sectionHeader(
    String title,
  ) {
    return Text(title.toUpperCase(),
        style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w400,
            fontSize: 12));
  }

  Widget _sectionItem(String title, Function onTap, {String subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  title,
                ),
                Icon(
                  Icons.keyboard_arrow_right,
                  color: Colors.black45,
                  size: 20,
                ),
              ],
            ),
            subtitle != null
                ? Text(
                    subtitle,
                  )
                : SizedBox(height: 0),
          ],
        ),
      ),
    );
  }

  Widget _morePage() {
    double verticalPadding = MediaQuery.of(context).size.height * 0.02;
    return ListView(
      padding: const EdgeInsets.only(top: 12.0, left: 15, right: 15),
      children: <Widget>[
        _sectionHeader("Perfil"),
        _sectionItem("Mi cuenta", _routeToProfile),
        _sectionItem("Cambiar contraseña", _routeToUpdatePassword),
        Divider(
          height: verticalPadding,
        ),
        SizedBox(
          height: verticalPadding,
        ),
        _sectionHeader("Terapia"),
        _sectionItem("Sobre la amaxofobia", null),
        _sectionItem("Desensibilización sistemática", null),
        Divider(
          height: verticalPadding,
        ),
        SizedBox(
          height: verticalPadding,
        ),
        _sectionHeader("Preferencias"),
        _sectionItem("Idioma", null),
        _sectionItem("Notificaciones", null),
        Divider(
          height: verticalPadding,
        ),
        SizedBox(
          height: verticalPadding,
        ),
        _sectionHeader("Otros"),
        _sectionItem("Términos y condiciones", null),
        Divider(
          height: verticalPadding,
        ),
        SizedBox(
          height: verticalPadding,
        ),
        primaryButton(context, () async {
          await _logout();
        }, "Cerrar sesión"),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text('Más'),
        actions: <Widget>[],
      ),
      body: _isLoadingLogout
          ? circularProgress(context, text: "Cerrando sesión")
          : _morePage(),
    );
  }
}
