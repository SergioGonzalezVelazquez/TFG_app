import 'package:flutter/material.dart';

///
/// UI Desing Reference:
/// https://github.com/SubirZ/Awesome_Flutter_UI/
///
class LoginBackground extends StatelessWidget {
  Widget _wavyHeader(BuildContext context) {
    return ClipPath(
      clipper: TopWaveClipper(),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: purpleGradients(context),
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        height: MediaQuery.of(context).size.height * 0.4,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          new Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              _wavyHeader(context),
            ],
          ),
        ],
      ),
    );
  }
}

List<Color> purpleGradients(BuildContext context) {
  return [
    Theme.of(context).primaryColor,
    Theme.of(context).primaryColorDark,
  ];
}

class TopWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // A Path is used to define the path on which we want to draw.
    var path = Path();
    path.lineTo(0.0, size.height * 0.70);

    var firstControlPoint = new Offset(size.width * 0.45, size.height);
    var firstEndPoint = new Offset(size.width * 0.55, size.height * 0.7);

    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint = new Offset(size.width * 0.65, size.height * 0.4);
    var secondEndPoint = new Offset(size.width, size.height * 0.8);

    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    ///move from bottom right to top
    path.lineTo(size.width, 0.0);

    ///finally close the path by reaching start point from top right corner
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
