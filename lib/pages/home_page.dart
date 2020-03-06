import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tfg_app/pages/chat/chat_page.dart';
import 'package:tfg_app/pages/exercises/exercises.dart';
import 'package:tfg_app/pages/more/more_page.dart';
import 'package:tfg_app/pages/progress/progress.dart';
import 'package:tfg_app/themes/custom_icon_icons.dart';

/// This widget is the home page of the application.
class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isAuth = true; //Cambiar a false cuando se implemente la autenticación de usuarios
  PageController pageController;
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

    onTap(int pageIndex) {
    pageController.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Scaffold buildAuthScreen() {
    return Scaffold(
      body: PageView(
        children: <Widget>[
          ChatPage(),
          ExercisePage(),
          ProgressPage(),
          MorePage(),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
          currentIndex: pageIndex,
          backgroundColor: Colors.white,
          onTap: onTap,
          activeColor: Theme.of(context).primaryColor,
          items: [
            BottomNavigationBarItem(icon: Icon(CustomIcon.speech_bubble), title: Text('Terapeuta')),
            BottomNavigationBarItem(icon: Icon(CustomIcon.car), title: Text('Retos')),
            BottomNavigationBarItem(icon: Icon(CustomIcon.line_chart2,),title: Text('Progreso')),
            BottomNavigationBarItem(icon: Icon(CustomIcon.more), title: Text('Más')),
          ]),
    );
  }

  Text buildUnAuthScreen() {
    return Text('unauthScreen');
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
