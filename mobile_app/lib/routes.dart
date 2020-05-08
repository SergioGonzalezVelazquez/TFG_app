import 'package:flutter/cupertino.dart';
import 'package:tfg_app/pages/chat/chat_page.dart';
import 'package:tfg_app/pages/home_page.dart';
import 'package:tfg_app/pages/questionnaire/pretest/signup_questionnaire_completed_page.dart';
import 'package:tfg_app/pages/questionnaire/pretest/signup_questionnaire_page.dart';
import 'package:tfg_app/pages/user/login_page.dart';
import 'package:tfg_app/pages/user/udpate_password.dart';
import 'package:tfg_app/pages/user/profile.dart';
import 'package:tfg_app/pages/user/reset_password.dart';
import 'package:tfg_app/pages/user/signup_page.dart';

/// The application's top-level routing table.
///
/// When a named route is pushed with Navigator.pushNamed,
/// the route name is looked up in this map.
final appRoutes = {
  HomePage.route: (BuildContext context) => HomePage(),
  HomePage.routeAuth: (BuildContext context) => HomePage(
        isAuth: true,
      ),
  LoginPage.route: (BuildContext context) => LoginPage(),
  SignUpPage.route: (BuildContext context) => SignUpPage(),
  ResetPasswordPage.route: (BuildContext context) => ResetPasswordPage(),
  SignUpQuestionnairePage.route: (BuildContext context) =>
      SignUpQuestionnairePage(),
  SignUpQuestionnaireCompleted.route: (BuildContext context) =>
      SignUpQuestionnaireCompleted(),
  ChatPage.route: (BuildContext context) => ChatPage(),
  ProfilePage.route: (BuildContext context) => ProfilePage(),
  UpdatePassword.route: (BuildContext context) => UpdatePassword(),
};
