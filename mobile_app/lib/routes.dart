import 'pages/chat/chat_page.dart';
import 'pages/driving_activity/driving_activity_agreement.dart';
import 'pages/driving_activity/driving_activity_settings.dart';
import 'pages/exercises/exercises_help.dart';
import 'pages/home_page.dart';
import 'pages/initial_page.dart';
import 'pages/phy_activity/bluetooth_connection_page.dart';
import 'pages/phy_activity/daily_heart_rate.dart';
import 'pages/phy_activity/phy_activity_agreement.dart';
import 'pages/phy_activity/phy_activity_settings.dart';
import 'pages/progress/progress_medals.dart';
import 'pages/questionnaire/pretest/signup_questionnaire_completed_page.dart';
import 'pages/questionnaire/pretest/signup_questionnaire_page.dart';
import 'pages/root_page.dart';
import 'pages/therapist/hierarchy_page.dart';
import 'pages/user/aviso_legal.dart';
import 'pages/user/login_page.dart';
import 'pages/user/profile.dart';
import 'pages/user/reset_password.dart';
import 'pages/user/signup_page.dart';
import 'pages/user/udpate_password.dart';

/// The application's top-level routing table.
///
/// When a named route is pushed with Navigator.pushNamed,
/// the route name is looked up in this map.
final appRoutes = {
  RootPage.route: (context) => RootPage(),

  HomePage.route: (context) => HomePage(),

  // User
  LoginPage.route: (context) => LoginPage(),
  SignUpPage.route: (context) => SignUpPage(),
  ResetPasswordPage.route: (context) => ResetPasswordPage(),
  ProfilePage.route: (context) => ProfilePage(),
  UpdatePassword.route: (context) => UpdatePassword(),

  // Pretest - Questionnaire
  SignUpQuestionnairePage.route: (context) => SignUpQuestionnairePage(),
  SignUpQuestionnaireCompleted.route: (context) =>
      SignUpQuestionnaireCompleted(),

  // Initial Page
  InitialPage.route: (context) => InitialPage(),

  // Therapy
  ChatPage.route: (context) => ChatPage(),
  HierarchyPage.routeEditable: (context) => HierarchyPage(
        editable: true,
      ),
  HierarchyPage.routeNoEditable: (context) => HierarchyPage(
        editable: false,
      ),
  ExerciseHelp.route: (context) => ExerciseHelp(),
  ProgressMedals.route: (context) => ProgressMedals(),

  // Driving Activity Detection
  DrivingActivityAgreement.route: (context) => DrivingActivityAgreement(),
  DrivingActivitySettings.route: (context) => DrivingActivitySettings(),

  // eMOVI
  BluetoothConnectionInterface.route: (context) =>
      BluetoothConnectionInterface(),
  PhyActivityAgreement.route: (context) => PhyActivityAgreement(),
  DailyHeartRatePage.route: (context) => DailyHeartRatePage(),
  PhyActivitySettings.route: (context) => PhyActivitySettings(),

  AvisoLegalPage.route: (context) => AvisoLegalPage(),
};
