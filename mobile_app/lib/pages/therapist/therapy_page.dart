import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tfg_app/models/patient.dart';
import 'package:tfg_app/pages/chat/chat_page.dart';
import 'package:tfg_app/pages/chat/chat_resume.dart';
import 'package:tfg_app/pages/therapist/hierarchy_page.dart';
import 'package:tfg_app/services/auth.dart';
import 'package:tfg_app/services/dialogflow.dart';
import 'package:tfg_app/themes/custom_icon_icons.dart';
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
  DateFormat formatter = new DateFormat("dd/MM/yyyy 'a las' HH:mm");
  bool _isLoading = true;

  StreamSubscription<PatientStatus> _patientStatusStream;

  /// TabBar Controller will control the movement between the Tabs
  PatientStatus _patientStatus;

  AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();

    _patientStatusStream = _authService.patientStatusStream.stream
        .asBroadcastStream()
        .listen(_onPatientStatusUpdated);

    _fetchPatientStatus();
  }

  @override
  void dispose() {
    super.dispose();
    if (_patientStatusStream != null) {
      _patientStatusStream.cancel();
    }
  }

  void _onPatientStatusUpdated(PatientStatus status) {
    print("on patient status updated");
    setState(() {
      _patientStatus = status;
    });
  }

  /**
   * Functions used to handle events in this screen 
   */

  Future<void> _fetchPatientStatus() async {
    setState(() {
      _isLoading = true;
    });
    PatientStatus status = await _authService.patietStatus;
    if (this.mounted) {
      setState(() {
        _patientStatus = status;
        _isLoading = false;
      });
    }
  }

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
          child: ListView(
            children: <Widget>[
              Text("Tienes " +
                  therapySessions.length.toString() +
                  " sesiones guardadas"),
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

  Widget _itemDetails(String title, RichText content,
      {bool inProgress = false,
      bool completed = false,
      String inProgressText = 'Empezar',
      String completedText = 'Ver Resultado',
      DateTime completedDate,
      Function inProgressAction,
      Function onCompletedAction}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 2,
            style:
                Theme.of(context).textTheme.bodyText2.apply(fontWeightDelta: 2),
          ),
          Container(
            constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height * 0.15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                content,
                Visibility(
                    visible: completed && completedDate != null,
                    child: Text(
                      completedDate != null
                          ? 'Completado el ' + formatter.format(completedDate)
                          : '',
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2
                          .apply(fontSizeFactor: 0.7),
                      textAlign: TextAlign.left,
                    )),
                Align(
                  alignment: Alignment.bottomRight,
                  child: inProgress
                      ? primaryButton(context, inProgressAction, inProgressText,
                          width: MediaQuery.of(context).size.width * 0.2,
                          fontSizeFactor: 0.7)
                      : completed
                          ? FlatButton(
                              onPressed: onCompletedAction,
                              padding: EdgeInsets.all(0),
                              child: Text(
                                completedText,
                                style: Theme.of(context).textTheme.button.apply(
                                    fontSizeFactor: 0.8,
                                    color: Theme.of(context).primaryColor),
                              ),
                            )
                          : Text(''),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepItem(int step, IconData icon, Widget info,
      {bool isLast = false, bool completed = false, bool inProgress = false}) {
    Color color = (completed)
        ? Colors.green
        : (inProgress ? Theme.of(context).primaryColor : Colors.grey);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width / 8,
                height: MediaQuery.of(context).size.width / 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color,
                    width: 2.0,
                  ),
                ),
                child: Center(child: Icon(icon, color: color)),
              ),
              // Separador vertical entre items
              Expanded(
                child: Container(
                  width: isLast ? 0 : 2,
                  color: Color(0xffE6E6E5),
                ),
              ),
            ],
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.05,
          ),
          info
        ],
      ),
    );
  }

  Widget _pageInfo() {
    return RichText(
      textAlign: TextAlign.justify,
      text: TextSpan(
        text: 'La aplicación de la ',
        style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1),
        children: <TextSpan>[
          TextSpan(
            text: 'Desensibilización Sistemática ',
            style: DefaultTextStyle.of(context).style.apply(fontWeightDelta: 2),
          ),
          TextSpan(
              text:
                  'requiere de unos pasos iniciales antes de comenzar con las sesiones de exposición.\n'),
        ],
      ),
    );
  }

  Widget _stepsPage() {
    // Build Item for Step 1
    RichText contentStep1 = RichText(
      textAlign: TextAlign.justify,
      text: TextSpan(
        text:
            'Habla con nuestro terapeuta virtual para construir un listado de ',
        style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 0.8),
        children: <TextSpan>[
          TextSpan(
            text: '11 a 16 ',
            style: DefaultTextStyle.of(context)
                .style
                .apply(fontWeightDelta: 2, fontSizeFactor: 0.8),
          ),
          TextSpan(
              text:
                  'situaciones relacionadas con la conducción que te provocan ansiedad.\n'),
        ],
      ),
    );

    bool inProgressStep1 =
        _patientStatus == PatientStatus.identify_situations_pending;
    bool completedStep1 = [
      PatientStatus.hierarchy_pending,
      PatientStatus.hierarchy_completed,
      PatientStatus.in_exercise
    ].contains(_patientStatus);

    // Build Item for Step 2
    RichText contentStep2 = RichText(
      textAlign: TextAlign.justify,
      text: TextSpan(
        text:
            'Ordena las situaciones temidas de menor a mayor ansiedad, utilizando una escala de ',
        style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 0.8),
        children: <TextSpan>[
          TextSpan(
            text: '0 a 100 USAs ',
            style: DefaultTextStyle.of(context)
                .style
                .apply(fontWeightDelta: 2, fontSizeFactor: 0.8),
          ),
          TextSpan(text: '(Unidades Subjetivas de Ansiedad).\n'),
        ],
      ),
    );

    bool inProgressStep2 = PatientStatus.hierarchy_pending == _patientStatus;
    bool completedStep2 = [
      PatientStatus.hierarchy_completed,
      PatientStatus.in_exercise
    ].contains(_patientStatus);

    // Build Item for Step 3
    RichText contentStep3 = RichText(
      textAlign: TextAlign.justify,
      text: TextSpan(
        text: 'Completa los ejercicios que te ayudan a exponerte de manera ',
        style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 0.8),
        children: <TextSpan>[
          TextSpan(
            text: 'progresiva ',
            style: DefaultTextStyle.of(context)
                .style
                .apply(fontWeightDelta: 2, fontSizeFactor: 0.8),
          ),
          TextSpan(text: 'a las sensaciones temidas\n'),
        ],
      ),
    );

    bool inProgressStep3 = PatientStatus.in_exercise == _patientStatus;

    return _isLoading
        ? circularProgress(context)
        : ListView(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05,
                vertical: MediaQuery.of(context).size.height * 0.02),
            children: [
              _pageInfo(),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              _stepItem(
                  1,
                  CustomIcon.doctor_icon,
                  _itemDetails("Identificar Situaciones Temidas", contentStep1,
                      inProgress: inProgressStep1,
                      completed: completedStep1,
                      onCompletedAction: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatResume(_authService
                                .user.patient.identifySituationsSessionId),
                          ),
                        );
                      },
                      completedDate:
                          _authService.user.patient.identifySituationsDate,
                      inProgressAction: () async {
                        await Navigator.of(context).pushNamed(ChatPage.route);
                      }),
                  inProgress: inProgressStep1,
                  completed: completedStep1),
              _stepItem(
                  2,
                  CustomIcon.list,
                  _itemDetails(
                      "Elaborar una jerarquía de ansiedad", contentStep2,
                      inProgress: inProgressStep2,
                      completed: completedStep2,
                      onCompletedAction: () {
                        Navigator.of(context)
                            .pushNamed(HierarchyPage.routeNoEditable);
                      },
                      completedDate:
                          _authService.user.patient.hierarchyCompletedDate,
                      inProgressAction: () async {
                        await Navigator.of(context)
                            .pushNamed(HierarchyPage.routeEditable);
                      }),
                  inProgress: _patientStatus == PatientStatus.hierarchy_pending,
                  completed: completedStep2),
              _stepItem(
                  3,
                  CustomIcon.car,
                  _itemDetails("Exposición en vivo", contentStep3,
                      inProgress: inProgressStep3,
                      inProgressText: 'Ejercicios'),
                  inProgress: inProgressStep3,
                  isLast: true)
            ],
          );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Terapia"),
        ),
        body: _stepsPage(),
      ),
    );
  }
}
