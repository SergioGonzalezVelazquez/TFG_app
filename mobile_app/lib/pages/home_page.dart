import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tfg_app/pages/driving_activity/driving_activity_page.dart';
import 'package:tfg_app/pages/exercises/exercises_page.dart';
import 'package:tfg_app/pages/more/more_page.dart';
import 'package:tfg_app/pages/progress/progress.dart';
import 'package:tfg_app/pages/therapist/hierarchy_page.dart';
import 'package:tfg_app/pages/therapist/therapy_page.dart';
import 'package:tfg_app/themes/custom_icon_icons.dart';

/// This widget is the home page of the application,
/// this is the route that is displayed first when the application is started normally.
/// If no user is signed in, it will redirect to LoginPage
class HomePage extends StatefulWidget {
  /// Name use for navigate to this screen
  static const route = "/home";

  @override
  _HomePageState createState() => _HomePageState();
}

/// State object for HomePage that contains fields that affect
/// how it looks.
class _HomePageState extends State<HomePage> {
  // Flag to render loading spinner UI.

  bool showAutoDriveDetectionAgreement;
  bool showPhyActivityAgreement;

  PageController _pageController;
  int pageIndex = 2;

  /// Create a global key that uniquely identifies the Scaffold widget,
  /// and allows to display snackbars.
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  /// Method called when this widget is inserted into the tree.
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: pageIndex);
  }

  /// Called when this widget is removed from the tree permanently.
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
          ExercisePage(),
          ProgressPage(),
          TherapistPage(),
          DrivingActivityPage(),
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
            icon: Icon(CustomIcon.ejercicios),
            title: Text('Ejercicios'),
          ),
          BottomNavigationBarItem(
            icon: Icon(
             // CustomIcon.line_chart2,
             CustomIcon.goal
            ),
            title: Text('Progreso'),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              //CustomIcon.speech_bubble
              CustomIcon.meditacion
            ),
            title: Text('Terapia'),
          ),
          BottomNavigationBarItem(
            icon: Icon(CustomIcon.car2),
            title: Text('Rutas'),
          ),
          BottomNavigationBarItem(
            icon: Icon(CustomIcon.more),
            title: Text('Más'),
          ),
        ],
      ),
    );
  }

  /// Describes the part of the user interface represented by this widget.
  /// The given BuildContext contains information about the location in the
  /// tree at which this widget is being built.
  @override
  Widget build(BuildContext context) {
    return _buildHomePage();
  }
}
