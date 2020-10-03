import 'package:flutter/material.dart';

import '../widgets/buttons.dart';
import '../widgets/progress.dart';
import '../widgets/slide_dots.dart';
import 'chat/chat_page.dart';
import 'home_page.dart';

class InitialPage extends StatefulWidget {
  /// Name use for navigate to this screen
  static const route = "/initial";

  ///Creates a StatelessElement to manage this widget's location in the tree.
  _InitialPageState createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  // Controller to manipulate which page is visible in a PageView
  final PageController _pageController = PageController();

  /// Flag to render loading spinner UI.
  final bool _isLoading = false;

  int _currentPage = 0;

  // Create a global key that uniquely identifies the Scaffold widget,
  // and allows to display snackbars.
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// Method called when this widget is inserted into the tree.
  @override
  void initState() {
    super.initState();
  }

  /// Returns a string representation of this object.
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Functions used to handle events in this screen

  ///  Widgets (ui components) used in this screen

  Widget _chatPage(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: width * 0.07, vertical: height * 0.01),
      child: ListView(
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.04,
          ),
          Text(
            "¡Ya tenemos todo preparado!",
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headline5
                .apply(fontSizeFactor: 1.1),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.03,
          ),
          Image.asset(
            'assets/images/3750965.png',
            height: MediaQuery.of(context).size.height * 0.3,
            fit: BoxFit.contain,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          Text(
            "Empieza la terapia con nuestro asistente virtual",
            textAlign: TextAlign.start,
            style: Theme.of(context)
                .textTheme
                .headline6
                .apply(fontSizeFactor: 0.8, fontWeightDelta: 2),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.01,
          ),
          Text(
            "STOPMiedo cuenta con un terapeuta virtual que te ayudará durante el primer paso del proceso de exposición a construir un listado con todos los temores o situaciones ansiógenas.",
            textAlign: TextAlign.justify,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          /*
          Text(
            "Más adelante .",
            textAlign: TextAlign.justify,
          ),
          */
        ],
      ),
    );
  }

  Widget _infoPage(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: width * 0.07, vertical: height * 0.01),
      child: ListView(
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.04,
          ),
          Text(
            "¡Ya tenemos todo preparado!",
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headline5
                .apply(fontSizeFactor: 1.1),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.03,
          ),
          Image.asset(
            'assets/images/15451.png',
            height: MediaQuery.of(context).size.height * 0.30,
            fit: BoxFit.contain,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          Text(
            "Conoce el método terapéutico que utilizamos",
            textAlign: TextAlign.start,
            style: Theme.of(context)
                .textTheme
                .headline6
                .apply(fontSizeFactor: 0.8, fontWeightDelta: 2),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.01,
          ),
          RichText(
            textAlign: TextAlign.justify,
            text: TextSpan(
              text:
                  "Para ayudarte a superar el miedo a conducir vamos a seguir un método de exposición conocido cómo ",
              style: Theme.of(context).textTheme.bodyText2,
              children: <TextSpan>[
                TextSpan(
                  text: 'desensibilización sistemática.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          Text(
            "Empezaremos definiendo una jerarquía de situaciones relacionadas con la conducción que te producen ansiedad.",
            textAlign: TextAlign.justify,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          Text(
            "Después, te asignaremos unos ejercicios que te ayudarán a exponerte de manera progresiva a las sensaciones temidas.",
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget _bottonNavigationBarChatPage(BuildContext parentContext, int items) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: width * 0.07, vertical: height * 0.02),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          FlatButton(
            padding: EdgeInsets.all(0),
            onPressed: () => Navigator.of(context)
                .pushNamedAndRemoveUntil(HomePage.route, (route) => false),
            child: Text(
              "Más tarde",
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold),
            ),
          ),
          _buildSlideDots(context, items),
          primaryButton(context, () {
            Navigator.of(context)
                .pushNamedAndRemoveUntil(HomePage.route, (route) => false);
            Navigator.of(context).pushNamed(ChatPage.route);
          }, "Empezar", width: MediaQuery.of(context).size.width * 0.25)
        ],
      ),
    );
  }

  Widget _bottonNavigationBarInfoPage(BuildContext parentContext, int items) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: width * 0.07, vertical: height * 0.02),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          FlatButton(
            padding: EdgeInsets.all(0),
            onPressed: () {
              /*...*/
            },
            child: Text(
              "Leer más",
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold),
            ),
          ),
          _buildSlideDots(context, items),
          primaryButton(context, () {
            setState(() {});
            _pageController.animateToPage(_currentPage + 1,
                duration: Duration(milliseconds: 500), curve: Curves.ease);
          }, "Siguiente", width: MediaQuery.of(context).size.width * 0.25),
        ],
      ),
    );
  }

  Widget _buildSlideDots(BuildContext parentContext, int items) {
    List<Widget> dots = [];
    for (int i = 0; i < items; i++) {
      dots.add(
        SlideDots(
          isActive: i == _currentPage,
        ),
      );
    }
    return Row(children: dots);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [_infoPage(context), _chatPage(context)];

    return Scaffold(
        //backgroundColor:  Color(0xffe8eaf6),
        key: _scaffoldKey,
        body: SafeArea(
          child: _isLoading
              ? circularProgress(context)
              : PageView(
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  controller: _pageController,
                  scrollDirection: Axis.horizontal,
                  children: pages,
                ),
        ),
        bottomNavigationBar: _isLoading
            ? null
            : (_currentPage != 0
                ? _bottonNavigationBarChatPage(context, pages.length)
                : _bottonNavigationBarInfoPage(context, pages.length)));
  }
}
