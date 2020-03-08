import 'package:flutter/material.dart';

abstract class CustomTheme {
  // Define the default brightness and colors.
  //https://dribbble.com/shots/3470934-Chat-App-Freebies

  //static const Color primaryColor = Color(0xff8B66E5);
  static const Color primaryColor = Color(0xff6A5F99);

  //static const Color primaryColorDark = Color(0xff16164A);
  static const Color primaryColorDark = Color(0xff433D55);
  
  //static const Color primaryColorLight = Color(0xffBCB1FF);
  static const Color primaryColorLight = Color(0xffD3D2D5);
  static const Color backgroundColor = Colors.white; //Color(0xffF5F5F6);

  // Define the default font family
  static const String fontFamily = 'Nunito';

  // Define the default TextTheme. Use this to specify the default
  // text styling for headlines, titles, bodies of text, and more.

  static ThemeData buildPurpleTheme() {
    final ThemeData base = ThemeData.light();
    final TextTheme textBase = base.textTheme;
    return base.copyWith(
        primaryColor: primaryColor,
        primaryColorDark: primaryColorDark,
        primaryColorLight: primaryColorLight,
        accentColor: primaryColorLight,
        scaffoldBackgroundColor: backgroundColor,
        textTheme: textBase.apply(fontFamily: fontFamily),
        buttonTheme: ButtonThemeData(
          buttonColor: primaryColor,
          shape: RoundedRectangleBorder(),
          textTheme: ButtonTextTheme.primary,
        ),
        appBarTheme: AppBarTheme(
            elevation: 2.0,
            color: Colors.white,
            iconTheme: IconThemeData(
              color: primaryColor,
            ),
            textTheme: TextTheme(
                title: TextStyle(
                    color: primaryColor,
                    fontFamily: fontFamily,
                    fontSize: 20,
                    fontWeight: FontWeight.w600))));
  }
}
