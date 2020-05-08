import 'package:flutter/material.dart';
import 'package:tfg_app/pages/chat/chat_page.dart';
import 'package:tfg_app/services/dialogflow.dart';
import 'package:tfg_app/widgets/buttons.dart';
import 'package:tfg_app/widgets/progress.dart';

class TherapistPage extends StatefulWidget {
  /// Creates a StatelessElement to manage this widget's location in the tree.
  _TherapistPageState createState() => _TherapistPageState();
}

class _TherapistPageState extends State<TherapistPage> {
  // Create a global key that uniquely identifies the Scaffold widget,
  // and allows to display snackbars.
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  /**
   * Functions used to handle events in this screen 
   */

  /**
   * Widgets (ui components) used in this screen 
   */
  Widget _therapistPage(BuildContext parentContext) {
    return FutureBuilder(
      future: getSessions(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress(parentContext);
        }

        return Container(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.1),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Text("Tienes " +
                  therapySessions.length.toString() +
                  " sesiones guardadas"),
              Spacer(),
              Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.height * 0.05),
                child: primaryButton(context, () {
                  Navigator.pushNamed(
                    context,
                    ChatPage.route,
                  );
                }, "Empezar sesión"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Terapia'),
        actions: <Widget>[],
      ),
      body: _therapistPage(context),
    );
  }
}
