import 'package:flutter/cupertino.dart';
import 'package:tfg_app/models/phy_activity.dart';
import 'package:tfg_app/pages/chat/chat_page.dart';
import 'package:tfg_app/pages/driving_activity/driving_activity_settings.dart';
import 'package:tfg_app/pages/home_page.dart';
import 'package:tfg_app/pages/initial_page.dart';
import 'package:tfg_app/pages/phy_activity/bluetooth_connection_page.dart';
import 'package:tfg_app/pages/phy_activity/daily_heart_rate.dart';
import 'package:tfg_app/pages/phy_activity/phy_activity_agreement.dart';
import 'package:tfg_app/pages/phy_activity/phy_activity_settings.dart';
import 'package:tfg_app/pages/questionnaire/pretest/signup_questionnaire_completed_page.dart';
import 'package:tfg_app/pages/questionnaire/pretest/signup_questionnaire_page.dart';
import 'package:tfg_app/pages/user/login_page.dart';
import 'package:tfg_app/pages/user/udpate_password.dart';
import 'package:tfg_app/pages/user/profile.dart';
import 'package:tfg_app/pages/user/reset_password.dart';
import 'package:tfg_app/pages/user/signup_page.dart';
import 'package:tfg_app/pages/driving_activity/driving_activity_agreement.dart';

/// The application's top-level routing table.
///
/// When a named route is pushed with Navigator.pushNamed,
/// the route name is looked up in this map.
final appRoutes = {
  HomePage.route: (BuildContext context) => HomePage(),
  HomePage.routeAuth: (BuildContext context) => HomePage(
        isAuth: true,
      ),

  // User
  LoginPage.route: (BuildContext context) => LoginPage(),
  SignUpPage.route: (BuildContext context) => SignUpPage(),
  ResetPasswordPage.route: (BuildContext context) => ResetPasswordPage(),
  ProfilePage.route: (BuildContext context) => ProfilePage(),
  UpdatePassword.route: (BuildContext context) => UpdatePassword(),

  // Pretest - Questionnaire
  SignUpQuestionnairePage.route: (BuildContext context) =>
      SignUpQuestionnairePage(),
  SignUpQuestionnaireCompleted.route: (BuildContext context) =>
      SignUpQuestionnaireCompleted(),

  // Initial Page
  InitialPage.route: (BuildContext context) => InitialPage(),

  // Therapy
  ChatPage.route: (BuildContext context) => ChatPage(),

  // Driving Activity Detection
  DrivingActivityAgreement.route: (BuildContext context) =>
      DrivingActivityAgreement(),
  DrivingActivitySettings.route: (BuildContext context) =>
      DrivingActivitySettings(),

  // eMOVI
  BluetoothConnectionInterface.route: (BuildContext context) =>
      BluetoothConnectionInterface(),
  PhyActivityAgreement.route: (BuildContext context) => PhyActivityAgreement(),
  DailyHeartRatePage.route: (BuildContext context) => DailyHeartRatePage(),
  PhyActivitySettings.route: (BuildContext context) => PhyActivitySettings(),
};
