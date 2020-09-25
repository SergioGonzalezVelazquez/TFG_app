import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tfg_app/models/patient.dart';
import 'package:tfg_app/pages/driving_activity/driving_activity_agreement.dart';
import 'package:tfg_app/pages/home_page.dart';
import 'package:tfg_app/pages/initial_page.dart';
import 'package:tfg_app/pages/phy_activity/phy_activity_agreement.dart';
import 'package:tfg_app/pages/questionnaire/pretest/signup_questionnaire_page.dart';
import 'package:tfg_app/pages/user/login_page.dart';
import 'package:tfg_app/widgets/progress.dart';
import 'package:tfg_app/services/auth.dart';
import 'package:intl/date_symbol_data_local.dart';

/// This widget is the root page of the application,
/// this is the route that is displayed first when the application is started normally.
/// If user is signed in, it will redirect to HomePage. Else, LoginPage will be rendered
class RootPage extends StatefulWidget {
  /// Name use for navigate to this screen
  static const route = "/";

  @override
  _RootPageState createState() => _RootPageState();
}

/// State object for HomePage that contains fields that affect
/// how it looks.
class _RootPageState extends State<RootPage> {
  bool _isAuth = false;

  Patient _patient;
  PatientStatus _status;

  // Flag to render loading spinner UI.
  bool _isLoading = true;

  bool showAutoDriveDetectionAgreement;
  bool showPhyActivityAgreement;
  AuthService _authService;

  /// Create a global key that uniquely identifies the Scaffold widget,
  /// and allows to display snackbars.
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  /// Method called when this widget is inserted into the tree.
  @override
  void initState() {
    super.initState();

    initializeDateFormatting('es_ES', null);

    // initialize AuthService class and check if
    // user is signed in or not
    _authService = AuthService();
    _checkAuth();
    _checkSettings();
  }

  /// Called when this widget is removed from the tree permanently.
  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _checkSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool autoDriveDetection = prefs.getBool("drive_detection_enabled");
    bool phyActivity = prefs.getBool("phy_activity_enabled");

    setState(() {
      showAutoDriveDetectionAgreement = autoDriveDetection;
      showPhyActivityAgreement = phyActivity;
    });
  }

  /// Check if user is signed in or not, using a singleton instance of
  /// AuthService class. Auth status (signed in or not) is hold by
  /// _isAuth attribute.
  Future<void> _checkAuth() async {
    await _authService.init();

    setState(() {
      _isAuth = _authService.isAuth;
      if (_isAuth) {
        _patient = _authService.user.patient;
        _status = _patient.status;
      }
      _isLoading = false;
    });
  }

  Widget _buildAuthScreen() {
    print(_status);
    _status = _authService.patietStatus;

    if (_status == PatientStatus.pretest_pending)
      return SignUpQuestionnairePage();
    else if (_status == PatientStatus.pretest_in_progress)
      return SignUpQuestionnairePage(
        inProgress: true,
      );

    if (showAutoDriveDetectionAgreement == null)
      return DrivingActivityAgreement();
    else if (showPhyActivityAgreement == null) return PhyActivityAgreement();

    if ([
      PatientStatus.identify_categories_pending,
      PatientStatus.identify_situations_pending,
      PatientStatus.pretest_completed
    ].contains(_status)) {
      return InitialPage();
    } else {
      return HomePage();
    }
  }

  /// Describes the part of the user interface represented by this widget.
  /// The given BuildContext contains information about the location in the
  /// tree at which this widget is being built.
  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Scaffold(key: _scaffoldKey, body: circularProgress(context))
        : (_isAuth ? _buildAuthScreen() : LoginPage());
  }
}
