import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dialogflow/dialogflow_v2.dart';
import 'package:tfg_app/models/dialogflow_session.dart';
import 'package:tfg_app/services/auth.dart';
import 'package:uuid/uuid.dart';

// Gets dialogflow-sessions collection reference
final dialogflowSessionsRef =
    Firestore.instance.collection('dialogflow_sessions');

List<TherapySession> therapySessions = [];

// Write 'dialogflow_session' document in firestore.
void _createDialogflowSession(String uuid) {
  dialogflowSessionsRef
      .document(uuid)
      .setData({"user_id": user.id, "start_at": DateTime.now()});
}

Future<Dialogflow> initializeSession(
    String googleCredentials, String language) async {
  String sessionId = Uuid().v4();

  AuthGoogle authGoogle = await AuthGoogle(
          fileJson: googleCredentials, sessionId: sessionId)
      .build();

  // Create document in 'dialogflow_sessions' document
  _createDialogflowSession(sessionId);

  return Dialogflow(authGoogle: authGoogle, language: language);
}

// Read 'dialogflow_session' documents for current user
Future<List<TherapySession>> getSessions() async {
  QuerySnapshot snapshot = await dialogflowSessionsRef
      .where("user_id", isEqualTo: user.id)
      .getDocuments();

  therapySessions = [];
  snapshot.documents.forEach((doc) {
    therapySessions.add(TherapySession.fromDocument(doc));
  });

  return therapySessions;
}
