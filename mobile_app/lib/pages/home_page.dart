import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tfg_app/pages/exercises/exercises.dart';
import 'package:tfg_app/pages/more/more_page.dart';
import 'package:tfg_app/pages/progress/progress.dart';
import 'package:tfg_app/pages/questionnaire/pretest/signup_questionnaire_page.dart';
import 'package:tfg_app/pages/therapist/therapist.dart';
import 'package:tfg_app/pages/user/login_page.dart';
import 'package:tfg_app/services/firestore.dart';
import 'package:tfg_app/widgets/progress.dart';
import 'package:tfg_app/services/auth.dart';
import 'package:tfg_app/themes/custom_icon_icons.dart';

import '../services/auth.dart';

/// This widget is the home page of the application.
class HomePage extends StatefulWidget {
  bool auth;

  HomePage({bool isauth = false}) {
    this.auth = isauth;
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isAuth = false;
  bool _patientExists = false;
  bool _isCheckingAuth = true;
  bool _isCheckingPatientExists = true;
  PageController _pageController;
  int pageIndex = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    checkAuth();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  checkAuth() async {
    bool auth = !widget.auth ? await isAuth() : true;
    setState(() {
      _isAuth = auth;
      _isCheckingAuth = false;
    });

    if (_isAuth) {
      print(user.toString());
      await _checkPatient();
    }
  }

  Future<void> _checkPatient() async {
    bool exist = await patientExists();
    setState(() {
      _patientExists = exist;
      _isCheckingPatientExists = false;
    });
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

  Widget buildAuthScreen() {
    if (_isCheckingPatientExists)
      return Scaffold(key: _scaffoldKey, body: circularProgress(context));
    else if (!_patientExists)
      return SignUpQuestionnairePage();
    else {
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
                icon: Icon(CustomIcon.speech_bubble), title: Text('Terapeuta')),
            BottomNavigationBarItem(
                icon: Icon(CustomIcon.car2), title: Text('Retos')),
            BottomNavigationBarItem(
                icon: Icon(
                  CustomIcon.line_chart2,
                ),
                title: Text('Progreso')),
            BottomNavigationBarItem(
                icon: Icon(CustomIcon.more), title: Text('Más')),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isCheckingAuth
        ? circularProgress(context)
        : (_isAuth ? buildAuthScreen() : LoginPage());
  }
}
