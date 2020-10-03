import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/driving_detection.dart';
import '../../widgets/buttons.dart';
import '../../widgets/progress.dart';
import '../../widgets/slide_dots.dart';
import '../root_page.dart';

class DrivingActivityAgreement extends StatefulWidget {
  static const route = "/drivingActivityAgreement";

  @override
  State<DrivingActivityAgreement> createState() =>
      DrivingActivityAgreementState();
}

class DrivingActivityAgreementState extends State<DrivingActivityAgreement> {
  // Controller to manipulate which page is visible in a PageView
  final PageController _pageController = PageController();

  bool _isLoading = false;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  /// Functions used to handle events in this screen
  Future<void> _activate() async {
    setState(() {
      _isLoading = true;
    });
    await DrivingDetectionService().startBackgroundService();
    Navigator.of(context)
        .pushNamedAndRemoveUntil(RootPage.route, (route) => false);
  }

  Future<void> _cancel() async {
    setState(() {
      _isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("drive_detection_enabled", false);
    Navigator.of(context)
        .pushNamedAndRemoveUntil(RootPage.route, (route) => false);
  }

  void _more() {
    setState(() {
      _pageController.animateToPage(_currentPage + 1,
          duration: Duration(milliseconds: 500), curve: Curves.ease);
    });
  }

  ///  Widgets (ui components) used in this screen

  Widget _infoPage() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: width * 0.07, vertical: height * 0.02),
      child: ListView(
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.1,
          ),
          Text(
            "Registrar conducción automáticamente",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline5,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.07,
          ),
          Text(
            """STOPMiedo puede detectar y registrar automáticamente en segundo plano eventos relacionados con la conducción.""",
            textAlign: TextAlign.justify,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.03,
          ),
          Text(
            """Conocer en qué lugares inicias y terminas las conducción, junto con algunos eventos cómo giros bruscos, distracciones con el móvil, acelerones, frenazos o aparcamientos""",
            textAlign: TextAlign.justify,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.03,
          ),
          Text(
            """Además, tendrás la posibilidad de ver sobre un mapa todas las rutas que has hecho conduciendo junto con sus eventos más significativos.""",
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget _locationPage() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: width * 0.07, vertical: height * 0.01),
      child: ListView(
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          Text(
            "Conocer tu ubicación",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline5,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.03,
          ),
          Image.asset(
            'assets/images/51541.png',
            height: MediaQuery.of(context).size.height * 0.30,
            fit: BoxFit.contain,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.07,
          ),
          Text(
            """Para poder detectar eventos relacionados con la conducción, permite que STOPMiedo pueda conocer tu ubicación en todo momento.
            """,
            textAlign: TextAlign.justify,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.03,
          ),
          Text(
            """Podrás desactivar esta característica en cualquier momento desde la pantalla de ajustes de la aplicación.""",
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget _bottonNavigationBar(BuildContext parentContext, int items) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: width * 0.07, vertical: height * 0.02),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Opacity(
            opacity: _currentPage != items - 1 ? 0 : 1,
            child: FlatButton(
              padding: EdgeInsets.all(0),
              onPressed: _currentPage != items - 1
                  ? null
                  : () async {
                      await _cancel();
                    },
              child: Text(
                "No, gracias",
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          _buildSlideDots(context, items),
          _currentPage != items - 1
              ? primaryButton(context, _more, "Más",
                  width: MediaQuery.of(context).size.width * 0.25)
              : primaryButton(context, _activate, "Aceptar",
                  width: MediaQuery.of(context).size.width * 0.25),
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
    List<Widget> pages = [_infoPage(), _locationPage()];
    return Scaffold(
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
                children: <Widget>[_infoPage(), _locationPage()],
              ),
      ),
      bottomNavigationBar:
          _isLoading ? null : _bottonNavigationBar(context, pages.length),
    );
  }
}
