import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tfg_app/models/patient.dart';
import 'package:tfg_app/pages/chat/chat_page.dart';
import 'package:tfg_app/pages/exercises/exercises.dart';
import 'package:tfg_app/pages/more/more_page.dart';
import 'package:tfg_app/pages/progress/progress.dart';
import 'package:tfg_app/pages/questionnaire/pretest/signup_questionnaire_page.dart';
import 'package:tfg_app/pages/therapist/therapist.dart';
import 'package:tfg_app/pages/user/login_page.dart';
import 'package:tfg_app/widgets/progress.dart';
import 'package:tfg_app/services/auth.dart';
import 'package:tfg_app/themes/custom_icon_icons.dart';

/// This widget is the home page of the application,
/// this is the route that is displayed first when the application is started normally.
/// If no user is signed in, it will redirect to LoginPage
class HomePage extends StatefulWidget {
  /// Name use for navigate to this screen
  static const route = "/home";
  static const routeAuth = "/home-auth";

  // Flag used to determine wheter auth user must be checked or not
  // When HomePage is inserted into the tree from another widget, we pass a true value
  // for auth property, meaning that the user is authenticated.
  bool auth;

  HomePage({bool isAuth = false}) {
    this.auth = isAuth;
  }

  @override
  _HomePageState createState() => _HomePageState();
}

/// State object for HomePage that contains fields that affect
/// how it looks.
class _HomePageState extends State<HomePage> {
  bool _isAuth = false;

  // Flag to render loading spinner UI.
  bool _isLoading = true;

  PageController _pageController;
  int pageIndex = 0;

  AuthService _authService;

  /// Create a global key that uniquely identifies the Scaffold widget,
  /// and allows to display snackbars.
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  /// Method called when this widget is inserted into the tree.
  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // initialize AuthService class and check if
    // user is signed in or not
    _authService = AuthService();
    if (!widget.auth) {
      _checkAuth();
    } else {
      _isAuth = true;
      _isLoading = false;
    }
  }

  /// Called when this widget is removed from the tree permanently.
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Check if user is signed in or not, using a singleton instance of
  /// AuthService class. Auth status (signed in or not) is hold by
  /// _isAuth attribute.
  Future<void> _checkAuth() async {
    await _authService.init();

    setState(() {
      _isAuth = _authService.isAuth;
      _isLoading = false;
    });

    if (_isAuth) {
      print(_authService.user.toString());
    }
  }

  void onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  void onTap(int pageIndex) {
    _pageController.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildHomePage() {
    return Scaffold(
      key: _scaffoldKey,
      body: PageView(
        children: <Widget>[
          TherapistPage(),
          ExercisePage(),
          ProgressPage(),
          MorePage(),
        ],
        controller: _pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        backgroundColor: Colors.white,
        onTap: onTap,
        activeColor: Theme.of(context).primaryColor,
        items: [
          BottomNavigationBarItem(
            icon: Icon(CustomIcon.speech_bubble),
            title: Text('Terapeuta'),
          ),
          BottomNavigationBarItem(
            icon: Icon(CustomIcon.car2),
            title: Text('Retos'),
          ),
          BottomNavigationBarItem(
              icon: Icon(
                CustomIcon.line_chart2,
              ),
              title: Text('Progreso')),
          BottomNavigationBarItem(
            icon: Icon(CustomIcon.more),
            title: Text('Más'),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthScreen() {
    PatientStatus status = _authService.user.patient.status;

    if (status == PatientStatus.pretest_pending)
      return SignUpQuestionnairePage();
    else if (status == PatientStatus.pretest_in_progress)
      return SignUpQuestionnairePage(
        inProgress: true,
      );
    else if ([
      PatientStatus.identify_categories_in_progress,
      PatientStatus.identify_situations_in_progress,
      PatientStatus.identify_situations_in_progress,
      PatientStatus.identify_situations_pending
    ].contains(status)) {
      return ChatPage();
    } else {
      return _buildHomePage();
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
