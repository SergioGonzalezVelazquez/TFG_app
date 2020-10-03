import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dialogflow/dialogflow_v2.dart';
import 'package:uuid/uuid.dart';

import '../models/dialogflow_session.dart';
import 'auth.dart';

// Gets dialogflow-sessions collection reference
final dialogflowSessionsRef =
    FirebaseFirestore.instance.collection('dialogflow_sessions');

AuthService _authService = AuthService();

List<DialogflowSession> therapySessions = [];

// Write 'dialogflow_session' document in firestore.
Future<void> _createDialogflowSession(String uuid) async {
  await dialogflowSessionsRef
      .doc(uuid)
      .set({"user_id": _authService.user.id, "start_at": DateTime.now()});
}

Future<Dialogflow> initializeSession(
    String googleCredentials, String language) async {
  String sessionId = Uuid().v4();

  AuthGoogle authGoogle =
      await AuthGoogle(fileJson: googleCredentials, sessionId: sessionId)
          .build();

  // Create document in 'dialogflow_sessions' document
  await _createDialogflowSession(sessionId);

  return Dialogflow(authGoogle: authGoogle, language: language);
}

// Read 'dialogflow_session' documents for current user
Future<List<DialogflowSession>> getSessions() async {
  QuerySnapshot snapshot = await dialogflowSessionsRef
      .where("user_id", isEqualTo: _authService.user.id)
      .get();

  therapySessions = [];
  snapshot.docs.forEach((doc) {
    therapySessions.add(DialogflowSession.fromDocument(doc));
  });

  return therapySessions;
}

// Read 'dialogflow_session' documents for current user
Future<DialogflowSession> getDialogflowSessionById(String id) async {
  DocumentSnapshot doc = await dialogflowSessionsRef.doc(id).get();
  if (doc.exists) {
    DialogflowSession session = DialogflowSession.fromDocument(doc);

    // Get messages
    QuerySnapshot snapshot = await dialogflowSessionsRef
        .doc(id)
        .collection('messages')
        .orderBy("index")
        .orderBy("timestamp")
        .get();

    List<DialogflowMessage> messages = [];
    snapshot.docs.forEach((msgDoc) {
      messages.add(DialogflowMessage.fromDocument(msgDoc));
    });

    session.messages = messages;
    return session;
  }
  return null;
}
