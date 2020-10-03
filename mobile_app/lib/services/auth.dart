import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/exercise.dart';
import '../models/patient.dart';
import '../models/therapy.dart';
import '../models/user.dart';
import '../utils/datetime_extensions.dart';
import 'firestore.dart';

// Gets user and patient collections references
final usersRef = FirebaseFirestore.instance.collection('users');
final patientRef = FirebaseFirestore.instance.collection('patient');

class AuthService {
  /// Entry point of the Firebase Authentication SDK.
  FirebaseAuth _firebaseAuth;

  MUser _user;

  /// Factory constructor which returns a singleton instance of the service
  AuthService._();
  static final AuthService _instance = AuthService._();
  factory AuthService() => _instance;
  bool _initialized = false;

  /// Getters.
  MUser get user => _user;
  bool get isAuth => _user != null;
  PatientStatus get patietStatus => _user?.patient?.status;
  StreamSubscription<DocumentSnapshot> _patientSubscription;
  final StreamController<PatientStatus> _patientStatusStream =
      StreamController<PatientStatus>.broadcast();
  StreamController<PatientStatus> get patientStatusStream =>
      _patientStatusStream;

  Future<void> _initializePatientListener(String userId) async {
    // Get patient Data
    DocumentSnapshot patientDoc = await patientRef.doc(userId).get();
    await _getPatientData(patientDoc);

    // Check daily streak
    DateTime lastExposure = _user.patient.lastExerciseCompleted;
    if (lastExposure != null &&
        !isToday(lastExposure) &&
        !isYesterday(lastExposure)) {
      _user.patient.currentDailyStreak = 0;
      await updatePatient({"currentDailyStreak": 0});
    }

    // initialize subscription
    _patientSubscription =
        patientRef.doc(_user.id).snapshots().listen((doc) async {
      await _getPatientData(doc);
    });
  }

  Future<void> _getPatientData(DocumentSnapshot doc) async {
    _user.patient = Patient.fromDocument(doc);
    _patientStatusStream.sink.add(_user?.patient?.status);

    if ([
      PatientStatus.hierarchy_pending,
      PatientStatus.hierarchy_completed,
      PatientStatus.in_exercise
    ].contains(_user.patient.status)) {
      Therapy therapy = await getPatientCurrentTherapy();
      _user.patient.currentTherapy = therapy;

      // CAMBIAR PARA QUE LOS EJERCICIOS SEAN UN STREAM BUILDER
      if (_user.patient.status == PatientStatus.in_exercise) {
        List<Exercise> exercises = await getPatientExercises();
        _user.patient.exercises = exercises;
      }
    }
  }

  /// Initialize service
  Future<void> init() async {
    if (!_initialized) {
      _initialized = true;

      // Obtain an instance of FirebaseAuth
      _firebaseAuth = FirebaseAuth.instance;

      // Get the currently signed-in user
      await _getSignedInUser();

      if (isAuth) {
        print("isAuth");
        await _initializePatientListener(_user.id);
      } else {
        print("no auth");
      }
    }
  }

  void dispose() {
    print("auth dispose");
    _initialized = false;
    _patientSubscription.cancel();
    _patientStatusStream.close();
  }

  /// Get the currently signed-in user
  /// According to Google's official documentation, the recommended way to get
  /// the current user is by calling the getCurrentUser method.
  /// If no user is signed in, getCurrentUser returns null
  Future<void> _getSignedInUser() async {
    User currentUser = _firebaseAuth.currentUser;

    if (currentUser != null) {
      // MUser is signed in
      DocumentSnapshot doc = await usersRef.doc(currentUser.uid).get();

      if (doc.exists) {
        _user = MUser.fromDocument(doc);
        // Get patient data for this user
        // await _getPatientData();
      }
    }
  }

  /// create doc in 'patient' collection for current auth user
  /// firebase cloud functions trigger this event and will calculate
  /// the type of patient based on pretest questionnaire answers
  Future<void> _createPatientDocument(String userId) async {
    String status = PatientStatus.pretest_pending.toString().split(".")[1];
    await patientRef
        .doc(userId)
        .set({"status": status, "bestDailyStreak": 0, "currentDailyStreak": 0});
    //await _initializePatientListener(userId);
  }

  Future<void> updatePatient(Map<String, dynamic> data) async {
    await patientRef.doc(_user.id).update(data);
  }

  Future<void> updatePatientStatus(PatientStatus status) async {
    String strStatus = status.toString().split(".")[1];
    await patientRef
        .doc(_user.id)
        .update({"status": strStatus}).then((value) async {
      //await this._getPatientData();
    });
  }

  /// Use the Google sign in data to authenticate a
  /// User and then return that user.
  /// https://firebase.google.com/docs/auth/android/google-signin
  /// https://fireship.io/lessons/flutter-firebase-google-oauth-firestore/
  Future<void> signInWithGoogle() async {
    print("singInWithGoogle");
    // Step 1. Login with Google. This shows Google’s native login screen and provides
    // the idToken and accessToken
    GoogleSignIn googleSignIn = GoogleSignIn();
    GoogleSignInAccount googleUser = await googleSignIn.signIn();

    if (googleUser != null) {
      /// Step 2. Login to Firebase. Get an ID token from the GoogleSignInAccount object,
      /// exchange it for a Firebase credential, and authenticate with Firebase
      /// using the Firebase credential
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _firebaseAuth.signInWithCredential(credential);

      User currentUser = _firebaseAuth.currentUser;
      assert(currentUser.email != null);
      assert(!currentUser.isAnonymous);
      assert(await currentUser.getIdToken() != null);

      /// Step 3: Create Firestore if user doc does not exists.
      await createUserDocument();
    }
  }

  /// Use the Facebook sign in data to authenticate a
  /// User and then return that user.
  Future<void> signInWithFacebook() async {
    // Step 1. Login with Facebook. This shows Facebook native login screen and provides
    // the idToken and accessToken
    final facebookLogin = FacebookLogin();
    final facebookAuth = await facebookLogin.logIn(['email']);

    if (facebookAuth.status != FacebookLoginStatus.loggedIn) return null;

    /// Step 2. Login to Firebase. Get an ID token from the FacebookLogin object,
    /// exchange it for a Firebase credential, and authenticate with Firebase
    /// using the Firebase credential
    AuthCredential credential =
        FacebookAuthProvider.credential(facebookAuth.accessToken.token);

    await _firebaseAuth.signInWithCredential(credential);

    final User currentUser = _firebaseAuth.currentUser;
    assert(currentUser.email != null);
    assert(!currentUser.isAnonymous);
    assert(await currentUser.getIdToken() != null);

    /// Step 3: Create Firestore if user doc does not exists.
    await createUserDocument();
  }

  /// Method which takes in an email address and password,
  /// validates them, and then signs a user in with the
  /// signInWithEmailAndPassword method.
  Future<void> signInWithEmail(String email, String password) async {
    // If successful, it also signs the user in into the app
    await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);

    User currentUser = _firebaseAuth.currentUser;
    assert(currentUser.email != null);
    assert(!currentUser.isAnonymous);

    await createUserDocument();
  }

  /// Register users with their email addresses and passwords.
  /// Then send an email verification
  Future<bool> registerWithEmail(
      String name, String email, String password) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);

    final User currentUser = _firebaseAuth.currentUser;
    assert(currentUser.email != null);
    assert(!currentUser.isAnonymous);
    await currentUser.sendEmailVerification();

    // Update the name field of the user
    currentUser.updateProfile(displayName: name);

    // MUser doc will be created when email is verified
    return true;
  }

  Future<void> createUserDocument() async {
    print("create user doc");
    User currentUser = _firebaseAuth.currentUser;

    print("currentUser Id: " + currentUser.uid);

    DocumentSnapshot doc = await usersRef.doc(currentUser.uid).get();
    bool exists = doc.exists;
    // Firt time user is logged-in
    if (!doc.exists) {
      print("doc exists");
      await usersRef.doc(currentUser.uid).set({
        "id": currentUser.uid,
        "photo": currentUser.photoURL,
        "email": currentUser.email,
        "name": currentUser.displayName,
        "created_at": DateTime.now()
      });
    } else {
      print("doc exists");
    }

    doc = await usersRef.doc(currentUser.uid).get();
    _user = MUser.fromDocument(doc);
    if (!exists) {
      await _createPatientDocument(currentUser.uid);
    }
    await _initializePatientListener(_user.id);

    // Save user id in shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', user.id);
  }

  /// Returns true if the user's email is verified.
  Future<bool> isEmailVerified() async {
    User user = _firebaseAuth.currentUser;
    return user.emailVerified;
  }

  /// Send email to the user for verification after they have signed up
  Future<void> sendEmailVerification() async {
    User user = _firebaseAuth.currentUser;
    user.sendEmailVerification();
  }

  /// Send email to reset password it user forget it
  Future<void> resetPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  /// Update a user's basic profile information—the user's
  /// display name and profile photo URL—with the Firebase updateProfile method
  Future<void> updateProfile({String name, String photo}) async {
    final User currentUser = await _firebaseAuth.currentUser;

    Map<String, dynamic> updatedData = {};
    if (name != null) updatedData['name'] = name;

    usersRef.doc(currentUser.uid).update(updatedData);

    DocumentSnapshot doc = await usersRef.doc(currentUser.uid).get();
    _user = MUser.fromDocument(doc);
  }

  /// Signs out the current user
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    _user = null;

    // Delete user id in shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('userId');
  }
}
