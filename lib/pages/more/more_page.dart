import 'package:flutter/material.dart';
import 'package:tfg_app/pages/user/login_page.dart';
import 'package:tfg_app/widgets/buttons.dart';
import 'package:tfg_app/services/auth.dart';
import 'package:tfg_app/widgets/progress.dart';

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

  Widget _itemHeader(
    String title,
  ) {
    return Text(title.toUpperCase(),
        style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w400,
            fontSize: 12));
  }

  Widget _morePage() {
    return ListView(
      padding: const EdgeInsets.only(top: 12.0, left: 15, right: 15),
      children: <Widget>[
        _itemHeader("Perfil"),
        _itemHeader("Notificaciones"),
        _itemHeader("Terapia"),
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
