import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfg_app/models/dialogflow_session.dart';
import 'package:tfg_app/services/auth.dart';

// Gets dialogflow-sessions collection reference
final dialogflowSessionsRef =
    Firestore.instance.collection('dialogflow_sessions');

List<TherapySession> therapySessions = [];

// Write 'dialogflow_session' document in firestore.
void createDialogflowSession(String uuid) {
  dialogflowSessionsRef
      .document(uuid)
      .setData({"user_id": user.id, "start_at": DateTime.now()});
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
